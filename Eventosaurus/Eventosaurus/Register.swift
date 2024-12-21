////
////  Register.swift
////  Eventosaurus
////
////  Created by BP-36-201-23 on 08/12/2024.
////

import UIKit
import FirebaseFirestore
import Firebase
import FirebaseAuth

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
        
        fnReqLabel.isHidden = true
        emailReqLabel.isHidden = true
        dobReqLabel.isHidden = true
        confirmPassReqLabel.isHidden = true
    }

    @IBAction func didTapSignUp(_ sender: Any) {
        // Validate the input fields first
        if isValid() {
            // Get the selected date from the UIDatePicker
            let selectedDate = DatePicker.date
            
            // Create newUser with the correct date format (Date object)
            let newUser = User(
                fullName: fullnameTxtField.text!,
                email: emailTxtField.text ?? "",
                dateOfBirth: selectedDate, // Pass Date object instead of string
                password: passwordTxtfield.text ?? "",
                isOrganizer: false,
                isAdmin: false
            )
            
            // Check if email already exists
            checkIfEmailExists(newUser.email) { emailExists in
                if emailExists {
                    // Show an error message if the email already exists
                    self.emailReqLabel.isHidden = false
                    self.emailReqLabel.text = "Email already exists"
                } else {
                    // Proceed to register the user if email doesn't exist
                    self.registerUser(newUser)
                }
            }
        } else {
            print("Please fill in all the required fields or check password confirmation.")
            showAlert(title: "Invalid Input", message: "Please fill in all the required fields and make sure the passwords match.")
        }
    }

    // Check if the fields are valid
    func isValid() -> Bool {
        var isValid = true
        
        // Check Full Name
        if let fullName = fullnameTxtField.text, fullName.isEmpty {
            fnReqLabel.isHidden = false
            isValid = false
        }
        
        // Check Email
        if let email = emailTxtField.text, email.isEmpty {
            emailReqLabel.isHidden = false
            isValid = false
        } else if let email = emailTxtField.text, !isValidEmail(email) {
            emailReqLabel.isHidden = false
            emailReqLabel.text = "Invalid email format"
            isValid = false
        }
        
        // Check Password
        if let password = passwordTxtfield.text, password.isEmpty {
            confirmPassReqLabel.isHidden = false
            isValid = false
        }
        
        // Check Confirm Password
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

    // Validate email format using a regex
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    // Function to check if the email already exists in Firestore
    func checkIfEmailExists(_ email: String, completion: @escaping (Bool) -> Void) {
        let usersRef = Firestore.firestore().collection("Users")
        
        // Query Firestore for the email
        usersRef.whereField("Email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking email in Firestore: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // If any documents are found, it means the email already exists
            if let snapshot = snapshot, snapshot.count > 0 {
                completion(true) // Email exists
            } else {
                completion(false) // Email does not exist
            }
        }
    }
    
    // Register user with Firebase Authentication
    func registerUser(_ newUser: User) {
        guard let password = passwordTxtfield.text, password.count >= 6 else {
            // Display custom alert for password too short
            showAlert(title: "Password Error", message: "Password must be at least 6 characters.")
            return
        }

        Auth.auth().createUser(withEmail: newUser.email, password: newUser.password) { authResult, error in
            if let error = error {
                // Handle Firebase errors here (other than password issues)
                self.handleFirebaseError(error)
                return
            }
            
            guard let authResult = authResult else {
                self.showAlert(title: "Error", message: "Failed to create account.")
                return
            }
            
            newUser.userID = authResult.user.uid
            self.storeUserInFirestore(newUser)
        }
    }

    // Store user data in Firestore
    func storeUserInFirestore(_ newUser: User) {
        let userDict = newUser.toDictionary()
        
        Firestore.firestore().collection("Users").document(newUser.userID).setData(userDict) { error in
            if error != nil {
                self.showAlert(title: "Error", message: "Failed to save user data to Firestore.")
                return
            }
            
            // Successfully stored user in Firestore, proceed to next screen
            print("User successfully added to Firestore!")
            self.performSegue(withIdentifier: "toInterests", sender: self)
        }
    }

    // Handle Firebase specific errors
    func handleFirebaseError(_ error: Error) {
        let nsError = error as NSError
        if nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
            showAlert(title: "Registration Error", message: "The email is already in use. Please try a different email.")
        } else if nsError.code == AuthErrorCode.invalidEmail.rawValue {
            showAlert(title: "Invalid Email", message: "The email address is not valid.")
        } else if nsError.code == AuthErrorCode.networkError.rawValue {
            showAlert(title: "Network Error", message: "Please check your network connection.")
        } else {
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    // Display a custom alert
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
