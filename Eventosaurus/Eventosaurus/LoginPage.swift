////
////  LoginPage.swift
////  EventosaurusUITests
////
////  Created by BP-36-201-23 on 08/12/2024.
////
//
//import UIKit
//
//class LoginPage: UIViewController {
//
//    @IBOutlet weak var emailReqLabel: UILabel!
//    
//    @IBOutlet weak var passwordReqLabel: UILabel!
//    
//    
//    @IBOutlet weak var emailTxtField: UITextField!
//    
//    
//    @IBOutlet weak var passwordTxtField: UITextField!
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        emailReqLabel.isHidden = true
//        passwordReqLabel.isHidden = true
//
//    }
//    
//    
//    @IBAction func loginButtonTapped(_ sender: Any) {
//        // Assume the form is valid initially
//        var isValid = true
//        
//        // Check if email is empty
//        if let email = emailTxtField.text, email.isEmpty {
//            emailReqLabel.isHidden = false // Show the required label
//            isValid = false
//        }
//        
//        // Check if password is empty
//        if let password = passwordTxtField.text, password.isEmpty {
//            passwordReqLabel.isHidden = false // Show the required label
//            isValid = false
//        }
//        
//        // If the form is valid, proceed to the next screen
//        if isValid {
//            // Perform segue to the next screen (for example, "toHomePage")
//          //  self.performSegue(withIdentifier: "toHomePage", sender: self)
//            print("Login successful. Proceeding to next page...")
//        } else {
//            // If validation fails, show an alert
//            let alertController = UIAlertController(title: "Invalid Input", message: "Please enter both email and password.", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alertController, animated: true, completion: nil)
//        }
//    }
//
//    
//
//}


import UIKit
import FirebaseAuth

class LoginPage: UIViewController {

    @IBOutlet weak var emailReqLabel: UILabel!
    @IBOutlet weak var passwordReqLabel: UILabel!
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailReqLabel.isHidden = true
        passwordReqLabel.isHidden = true
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        // Assume the form is valid initially
        var isValid = true
        
        // Check if email is empty
        if let email = emailTxtField.text, email.isEmpty {
            emailReqLabel.isHidden = false // Show the required label
            isValid = false
        }
        
        // Check if password is empty
        if let password = passwordTxtField.text, password.isEmpty {
            passwordReqLabel.isHidden = false // Show the required label
            isValid = false
        }
        
        // If the form is valid, proceed to authenticate the user
        if isValid {
            // Get email and password from text fields
            guard let email = emailTxtField.text, let password = passwordTxtField.text else {
                return
            }
            
            // Firebase Authentication: Sign in the user
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    // If there's an error (e.g., wrong credentials), show an alert
                    let errorCode = (error as NSError).code
                    
                    // Handle specific error codes
                    if errorCode == AuthErrorCode.userNotFound.rawValue {
                        // Show alert if the user doesn't exist
                        self.showAlert(title: "Login Error", message: "Account does not exist. Please sign up.")
                    } else if errorCode == AuthErrorCode.wrongPassword.rawValue {
                        // Show alert if the password is incorrect
                        self.showAlert(title: "Login Error", message: "Incorrect password. Please try again.")
                    } else {
                        // General error handling
                        self.showAlert(title: "Login Error", message: error.localizedDescription)
                    }
                } else {
                    // If login is successful, proceed to the next screen
                    print("Login successful. Proceeding to next page...")
                    self.performSegue(withIdentifier: "toHomePage", sender: self)
                }
            }
        } else {
            // If validation fails, show an alert
            self.showAlert(title: "Invalid Input", message: "Please enter both email and password.")
        }
    }

    // Function to show custom alert
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
