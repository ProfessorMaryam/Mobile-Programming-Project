import UIKit
import FirebaseFirestore
import Firebase

class Register: UIViewController {

    @IBOutlet weak var fnReqLabel: UILabel!
    @IBOutlet weak var emailReqLabel: UILabel!
    @IBOutlet weak var dobReqLabel: UILabel!
    @IBOutlet weak var confirmPassReqLabel: UILabel!
    
    @IBOutlet weak var fullnameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var passwordTxtfield: UITextField!
    @IBOutlet weak var confirmPasswordTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hiding validation labels initially
        fnReqLabel.isHidden = true
        emailReqLabel.isHidden = true
        dobReqLabel.isHidden = true
        confirmPassReqLabel.isHidden = true
    }

    @IBAction func didTapSignUp(_ sender: Any) {
        // Step 1: Validate all input fields first
        if isValid() {
            // Step 2: If validation is successful, get the selected date from the UIDatePicker
            let selectedDate = DatePicker.date
            
            // Create new user with all the details (password is stored directly)
            let newUser = User(
                fullName: fullnameTxtField.text!,
                email: emailTxtField.text ?? "",
                dateOfBirth: selectedDate,
                password: passwordTxtfield.text ?? "",
                isOrganizer: false,
                isAdmin: false
            )
            
            // Step 3: Check if the email already exists in Firestore
            checkIfEmailExists(newUser.email) { emailExists in
                if emailExists {
                    // Step 4: If email exists, show error message and don't perform segue
                    self.emailReqLabel.isHidden = false
                    self.emailReqLabel.text = "Email already exists. Please try another."
                } else {
                    // Step 5: If email doesn't exist, store user in Firestore and navigate to the Interests screen
                    self.storeUserInFirestore(newUser)
                }
            }
        } else {
            // Step 6: Show error message if input validation failed
            showAlert(title: "Invalid Input", message: "Please fill in all the required fields and make sure the passwords match.")
        }
    }

    // Function to validate all input fields
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

    // Function to check if the email already exists in Firestore
    func checkIfEmailExists(_ email: String, completion: @escaping (Bool) -> Void) {
        Firestore.firestore().collection("Users")
            .whereField("Email", isEqualTo: email)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(false)
                } else {
                    // If documents exist, it means the email already exists
                    completion(snapshot?.documents.isEmpty == false)
                }
            }
    }

    // Function to store user data in Firestore
    func storeUserInFirestore(_ newUser: User) {
        let userDict = newUser.toDictionary()
        
        Firestore.firestore().collection("Users").document().setData(userDict) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save user data to Firestore. \(error.localizedDescription)")
                return
            }
            
            // Successfully stored user in Firestore, proceed to the next screen
            print("User successfully added to Firestore!")
            self.navigateToUserInterests()  // Navigate to the UserInterests screen
        }
    }

    // Display a custom alert
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    // Function to navigate to the UserInterests view controller in another storyboard
    func navigateToUserInterests() {
        // Load the "Interests" storyboard
        let interestsStoryboard = UIStoryboard(name: "Interests", bundle: nil)
        
        // Instantiate the UserInterests view controller using its Storyboard ID
        if let userInterestsVC = interestsStoryboard.instantiateViewController(withIdentifier: "UserInterests") as? UserInterestsViewController {
            
            // Check if the current view controller is inside a navigation controller
            if let navigationController = self.navigationController {
                // Push the UserInterests view controller
                navigationController.pushViewController(userInterestsVC, animated: true)
                
                // Remove the back button from the navigation bar (so the user can't go back to register page)
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
