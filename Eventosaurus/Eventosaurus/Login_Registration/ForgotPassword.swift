import UIKit
import FirebaseAuth
import FirebaseFirestore

class ForgotPassword: UIViewController {

    
    //Text fields outlets and their corresponding labels
    @IBOutlet weak var emailReqLabel: UILabel!
    @IBOutlet weak var passwordReqLabel: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var confirmPasswordTxtField: UITextField!
    
    let db = Firestore.firestore()  // Firestore reference
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hidden initially
        emailReqLabel.isHidden = true
        passwordReqLabel.isHidden = true
    }
    
    @IBAction func changePassTapped(_ sender: Any) {
        var isValid = true // initially true
        
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
                passwordReqLabel.text = "Passwords do not match"
                passwordReqLabel.isHidden = false // Show the label with the message
                isValid = false
            }
        }
        
        // If the form is valid, proceed with updating the password
        if isValid {
            guard let email = emailTxtField.text else { return }

            // First, check if the email exists in Firestore Users collection
            let usersRef = db.collection("Users") //references Users collection
            usersRef.whereField("Email", isEqualTo: email).getDocuments { (snapshot, error) in //looking through the email fields in the Users collection and checking if any of the emails match the one in the text field
                if let error = error {
                    // Handle Firestore error before proceeding
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                // if user is found in Firestore, proceed with password update
                if let document = snapshot?.documents.first { //store the document in the snapshot
                    // User exists in Firestore, now update password
                    self.updatePasswordInFirestore(email: email, newPassword: self.passwordTxtField.text!, firestoreDocument: document)
                } else {
                    // Email does not exist in Firestore
                    let alertController = UIAlertController(title: "Error", message: "Email does not exist", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            // If validation fails, show an alert
            let alertController = UIAlertController(title: "Invalid Input", message: "Please enter all required fields and ensure passwords match.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    // Function to update the user's password field in Firestore (in the User collection)
    func updatePasswordInFirestore(email: String, newPassword: String, firestoreDocument: DocumentSnapshot) { //passes the email, the new password, and the email that is found and stored in the snapshot
        // Update password field in Firestore
        firestoreDocument.reference.updateData(["Password": newPassword]) { error in //replacing old password with the new password
            if let error = error {
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                // Successfully updated the password in Firestore
                self.showSuccessAlert()
            }
        }
    }

    // Success alert function
    func showSuccessAlert() {
        let alertController = UIAlertController(title: "Success", message: "Your password has been updated successfully.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            
            //once password is updated successfully, the text fields are cleared
                self.emailTxtField.text = ""
            self.passwordTxtField.text = ""
            self.confirmPasswordTxtField.text = ""
        }))
        self.present(alertController, animated: true, completion: nil)
    }

}


