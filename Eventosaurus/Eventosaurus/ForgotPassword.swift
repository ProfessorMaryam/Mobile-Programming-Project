//
//  forgotPassword.swift
//  EventosaurusUITests
//
//  Created by BP-36-201-23 on 08/12/2024.
//

import UIKit

class ForgotPassword: UIViewController {
    
    
    @IBOutlet weak var emailReqLabel: UILabel!
    
    @IBOutlet weak var passwordReqLabel: UILabel!
    
    @IBOutlet weak var emailTxtField: UITextField!
    
    @IBOutlet weak var passwordTxtField: UITextField!
    
    @IBOutlet weak var confirmPasswordTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailReqLabel.isHidden = true
        passwordReqLabel.isHidden = true
    }
    
    @IBAction func changePassTapped(_ sender: Any) {
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
            passwordReqLabel.text = "Required"
            isValid = false
        }
        
        // Check if confirm password is empty
        if let confirmPassword = confirmPasswordTxtField.text, confirmPassword.isEmpty {
            passwordReqLabel.text = "Required"
            passwordReqLabel.isHidden = false // Show the required label
            isValid = false
        }
        
        // Check if password and confirm password match
        if let password = passwordTxtField.text, let confirmPassword = confirmPasswordTxtField.text {
            if password != confirmPassword {
                passwordReqLabel.text = "Passwords do not match!"
                passwordReqLabel.isHidden = false // Show the label with the message
                isValid = false
            }
        }
        
        // If the form is valid, proceed to the next screen
        if isValid {
            // Perform segue to the next screen (replace with your actual segue identifier)
            self.performSegue(withIdentifier: "toHomePage", sender: self)
            print("Password change is valid. Proceeding to next page...")
        } else {
            // If validation fails, show an alert
            let alertController = UIAlertController(title: "Invalid Input", message: "Please enter all required fields and ensure passwords match.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }




}
