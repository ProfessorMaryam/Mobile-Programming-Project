//
//  Register.swift
//  Eventosaurus
//
//  Created by BP-36-201-23 on 08/12/2024.
//

import UIKit
import FirebaseFirestore
import Firebase

class Register: UIViewController {
    
    
    ///These are the outlets for the labels. they are initially hidden until the user skips the
    ///input fir one of the text fields. only then they are made visible to let them know that input is required
    
    @IBOutlet weak var fnReqLabel: UILabel!
    
    @IBOutlet weak var emailReqLabel: UILabel!
    
    @IBOutlet weak var dobReqLabel: UILabel!
    
    @IBOutlet weak var confirmPassReqLabel: UILabel!
    
    ///These are outlets for the textfields
    
    @IBOutlet weak var fullnameTxtField: UITextField!
    
    @IBOutlet weak var emailTxtField: UITextField!
    
    @IBOutlet weak var dateTxtField: UITextField!
    
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
        // Check for empty fields and show corresponding labels
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toInterests" {
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var v = true
        if identifier == "toInterests" {
            // Add your condition to abort the segue
            v = isValid()
            if v {
                // Proceed with the segue (navigate to the next view controller)
                print("All fields are filled and passwords match. Proceeding to next page...")
                
//                let fullName = fullnameTxtField.text
//                let email = emailTxtField.text
//                let dateOfBirth = dateTxtField.text
//                let password = passwordTxtfield.text
                
                let newUser = User(fullName: fullnameTxtField.text!, email: emailTxtField.text ?? "", dateOfBirth:dateTxtField.text ?? "", password: passwordTxtfield.text ?? "")
                
               // Firestore.firestore().collection("users").addDocument(data: Firestore.Encoder.encode(newUser))
                
                
            } else {
                // If fields are not filled correctly, stay on the current page and show an alert
                print("Please fill in all the required fields or check password confirmation.")
                
                // Show an alert to inform the user
                let alertController = UIAlertController(title: "Invalid Input", message: "Please fill in all the required fields and make sure the passwords match.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
        
        return v
    }
    
    
    func isValid () -> Bool{
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
        }
        
        // Check Date of Birth
        if let dateOfBirth = dateTxtField.text, dateOfBirth.isEmpty {
            dobReqLabel.isHidden = false
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
            confirmPassReqLabel.text = "Passwords do not match!"
            isValid = false
        }
        
        // If all fields are valid, proceed to the next screen
        return isValid
    }
    
    
    
    
    
    
    
}
