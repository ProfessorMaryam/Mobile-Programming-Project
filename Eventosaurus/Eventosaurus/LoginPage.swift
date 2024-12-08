//
//  LoginPage.swift
//  EventosaurusUITests
//
//  Created by BP-36-201-23 on 08/12/2024.
//

import UIKit

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
        
        // If the form is valid, proceed to the next screen
        if isValid {
            // Perform segue to the next screen (for example, "toHomePage")
          //  self.performSegue(withIdentifier: "toHomePage", sender: self)
            print("Login successful. Proceeding to next page...")
        } else {
            // If validation fails, show an alert
            let alertController = UIAlertController(title: "Invalid Input", message: "Please enter both email and password.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    

}
