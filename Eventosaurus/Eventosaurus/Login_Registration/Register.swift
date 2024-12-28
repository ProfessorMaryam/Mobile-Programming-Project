import UIKit
import FirebaseFirestore
import Firebase

class Register: UIViewController {

    
    //outlets to the labels that point out the errors to their corresponding text fields
    
    @IBOutlet weak var fnReqLabel: UILabel!
    @IBOutlet weak var emailReqLabel: UILabel!
    @IBOutlet weak var dobReqLabel: UILabel!
    @IBOutlet weak var confirmPassReqLabel: UILabel!
    
    //text field outlets
    @IBOutlet weak var fullnameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var passwordTxtfield: UITextField!
    @IBOutlet weak var confirmPasswordTxtField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // labels hidden initially
        fnReqLabel.isHidden = true
        emailReqLabel.isHidden = true
        dobReqLabel.isHidden = true
        confirmPassReqLabel.isHidden = true
    }

    @IBAction func didTapSignUp(_ sender: Any) {
        
        //if everything is valid:
        if isValid() {
        
            //save the date fromt the date picker
            let selectedDate = DatePicker.date
            
            //create a new user object
            let newUser = User(
                fullName: fullnameTxtField.text!,
                email: emailTxtField.text ?? "",
                dateOfBirth: selectedDate,
                password: passwordTxtfield.text ?? "",
                isOrganizer: false,
                isAdmin: false
            )
            
            //  Check if the email already exists in Firestore, calls the function created below
            checkIfEmailExists(newUser.email) { emailExists in
                if emailExists {
                    // If email exists, show error message and don't perform segue
                    self.emailReqLabel.isHidden = false //label is unhidden
                    self.emailReqLabel.text = "Email already exists. Please try another."
                } else {
                    // If email doesn't exist, store user in Firestore
              
                    self.storeUserInFirestore(newUser)
                }
            }
        } else {
            // Step 6: Show error message if input validation failed
            showAlert(title: "Invalid Input", message: "Please fill in all the required fields and make sure the passwords match.")
        }
    }

    // this function is used to validate all the text fields and check email regex
    func isValid() -> Bool {
        var isValid = true
        
        // Validate Full Name
        if let fullName = fullnameTxtField.text, fullName.isEmpty {
            fnReqLabel.isHidden = false
            isValid = false
        }
        
        // Validate Email
        if let email = emailTxtField.text, email.isEmpty {
            emailReqLabel.isHidden = false
            isValid = false
        } else if let email = emailTxtField.text, !isValidEmail(email) {
            emailReqLabel.isHidden = false
            emailReqLabel.text = "Invalid email format"
            isValid = false
        }
        
        // Validate Password
        if let password = passwordTxtfield.text, password.isEmpty {
            confirmPassReqLabel.isHidden = false
            isValid = false
        }
        
        // Validate Confirm Password
        if let confirmPassword = confirmPasswordTxtField.text, confirmPassword.isEmpty {
            confirmPassReqLabel.isHidden = false
            isValid = false
        }
        
        // Check if Password and Confirm Password match
        if let password = passwordTxtfield.text, let confirmPassword = confirmPasswordTxtField.text, password != confirmPassword {
            confirmPassReqLabel.isHidden = false
            confirmPassReqLabel.text = "Passwords do not match"
            isValid = false
        }
        
        return isValid
    }

    // Validate email format using regex
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }

    // this function checks if the email already exists in Firestore
    func checkIfEmailExists(_ email: String, completion: @escaping (Bool) -> Void) {
        Firestore.firestore().collection("Users") //refers to the Users collection
        //refers to the Email field. this fetches all the email fields where the field matches the email passed in the parameter
            .whereField("Email", isEqualTo: email)
            .getDocuments { snapshot, error in //getting documents, the snapshot contains the documents that match the query. Error is not nil if there are any errors that may arise
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(false) //completion is false in case of error
                } else {
                    // If documents exist, it means the email already exists
                    completion(snapshot?.documents.isEmpty == false) //isEmpty == false due to the the snapshot containing the matched document.
                }
            }
    }

    // this function stores the user in firestore
    func storeUserInFirestore(_ newUser: User) {
        let userDict = newUser.toDictionary() //storing the dictionary ina variable using dictionary method in from the user object
        
        
        
        //the following gets the Firestore instance and specifies where the data will be stored (in Users collection)
        Firestore.firestore().collection("Users").document().setData(userDict) { error in
            if let error = error { //error handling
                self.showAlert(title: "Error", message: "Failed to save user data to Firestore. \(error.localizedDescription)")
                return
            } //end of error handling
            
            // Successfully stored user in Firestore, proceed to the next screen
            print("User successfully added to Firestore!")
            //save user email for access in other storyboards
            User.loggedInemail = self.emailTxtField.text ?? ""
            self.navigateToUserInterests()  // Navigate to the UserInterests screen
        }
    }

    // create a custom alert
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    // this function navigates to UserInterests view controller in the Interests storyboard
    func navigateToUserInterests() {
        // store "Interests" storyboard in a variable
        let interestsStoryboard = UIStoryboard(name: "Interests", bundle: nil)
        
        // Instantiate the UserInterests view controller using its Storyboard ID. store the Interests page reference in "userInterestsVC" variable
        if let userInterestsVC = interestsStoryboard.instantiateViewController(withIdentifier: "UserInterests") as? UserInterestsViewController {
            
            // Pass the email from this view controller to the UserInterests view controller to use it to store the interests as references to the documents corresponding to them in the Categories collection
            userInterestsVC.userEmail = emailTxtField.text //whatever email is there in the emailTxtField, it will be assigned to the optional variable "userEmail" in the UserInterestsViewController

            // Check if the current view controller is inside a navigation controller
            if let navigationController = self.navigationController {
                // Push the UserInterests view controller
                navigationController.pushViewController(userInterestsVC, animated: true)
                
                // Remove the back button from the navigation bar in UserInterestsViewController so the user cannot go back to register page
                userInterestsVC.navigationItem.hidesBackButton = true
            } else {
                // If not inside a navigation controller, present the UserInterests view controller modally
                self.present(userInterestsVC, animated: true, completion: nil)
            }
        } else {
            // If unable to instantiate the UserInterests view controller, show an error
            self.showAlert(title: "Error", message: "Unable to load the User Interests page.")
        }
    }
}
