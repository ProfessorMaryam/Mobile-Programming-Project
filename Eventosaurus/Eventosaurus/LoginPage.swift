import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginPage: UIViewController {
    
    // Declaring label and text field outlets
    @IBOutlet weak var emailReqLabel: UILabel!
    @IBOutlet weak var passwordReqLabel: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    let db = Firestore.firestore()  // Firestore reference
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keeping labels hidden on load because they are responsible to show the user where their error is
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
                    // After successful login, check Firestore for the "Is Admin" field
                    guard let user = authResult?.user else {
                        return
                    }
                    
                    // Query Firestore to get the "Is Admin" field and password
                    let usersRef = self.db.collection("Users")
                    usersRef.whereField("Email", isEqualTo: user.email ?? "").getDocuments { snapshot, error in
                        if let error = error {
                            self.showAlert(title: "Error", message: error.localizedDescription)
                            return
                        }
                        
                        // Check if the document exists and if the "Is Admin" field is true
                        if let document = snapshot?.documents.first {
                            let isAdmin = document.get("Is Admin") as? Bool ?? false
                            let storedPassword = document.get("Password") as? String ?? ""
                            
                            if isAdmin {
                                // Check if the entered password matches the one stored in Firestore
                                if password == storedPassword {
                                    // If the user is an admin and the password matches, perform the segue
                                    print("Admin login successful. Proceeding to Admin page...")
                                    self.performSegue(withIdentifier: "toAdminPage", sender: self)
                                } else {
                                    // Password mismatch error
                                    self.showAlert(title: "Login Error", message: "Incorrect password. Please try again.")
                                }
                            } else {
                                // If not an admin, proceed to the regular user home page
                                print("Login successful. Proceeding to user home page...")
                                self.performSegue(withIdentifier: "toHomePage", sender: self)
                            }
                        } else {
                            // No user found in Firestore, handle error
                            self.showAlert(title: "Error", message: "User not found in the system.")
                        }
                    }
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
