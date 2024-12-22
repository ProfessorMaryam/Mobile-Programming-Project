import UIKit
import FirebaseFirestore

class LoginPage: UIViewController {
    
    @IBOutlet weak var emailReqLabel: UILabel!
    @IBOutlet weak var passwordReqLabel: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    let db = Firestore.firestore()  // Firestore reference
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailReqLabel.isHidden = true
        passwordReqLabel.isHidden = true
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        var isValid = true
        emailReqLabel.isHidden = true
        passwordReqLabel.isHidden = true
        
        // Validate email
        if let email = emailTxtField.text, email.isEmpty {
            emailReqLabel.isHidden = false
            emailReqLabel.text = "Email is required."
            isValid = false
        } else if let email = emailTxtField.text, !isValidEmail(email) {
            emailReqLabel.isHidden = false
            emailReqLabel.text = "Invalid email format."
            isValid = false
        }
        
        // Validate password
        if let password = passwordTxtField.text, password.isEmpty {
            passwordReqLabel.isHidden = false
            passwordReqLabel.text = "Password is required."
            isValid = false
        }
        
        if isValid {
            guard let email = emailTxtField.text, let password = passwordTxtField.text else {
                return
            }
            
            // Query Firestore to check if the email exists
            let usersRef = self.db.collection("Users")
            usersRef.whereField("Email", isEqualTo: email).getDocuments { snapshot, error in
                if let error = error {
                    self.showAlert(title: "Error", message: "Error accessing user data: \(error.localizedDescription)")
                    return
                }
                
                if let document = snapshot?.documents.first {
                    let storedPassword = document.get("Password") as? String ?? ""
                    
                    if password == storedPassword {
                        let isAdmin = document.get("Is Admin") as? Bool ?? false
                        
                        if isAdmin {
                            // Admin login successful, instantiate AdminPage from the "Admin Page" storyboard
                            self.navigateToAdminPage()
                        } else {
//                            // Handle non-admin user login if necessary
                            
                            
                            
                            
//                            self.showAlert(title: "Login Error", message: "You do not have admin access.")
                            
                            
                            
                            
                            
                            
                        }
                    } else {
                        self.showAlert(title: "Login Error", message: "Incorrect password. Please try again.")
                    }
                } else {
                    self.showAlert(title: "Login Error", message: "Account does not exist. Please sign up.")
                }
            }
        } else {
            self.showAlert(title: "Invalid Input", message: "Please enter both email and password.")
        }
    }
    
    // Function to validate email format using regex
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    // Function to show custom alert
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Function to navigate to the AdminPage view controller in another storyboard
    func navigateToAdminPage() {
        // Load the "Admin Page" storyboard
        let adminStoryboard = UIStoryboard(name: "AdminPage", bundle: nil)
        
        // Instantiate the AdminPage view controller using its Storyboard ID
        if let adminVC = adminStoryboard.instantiateViewController(withIdentifier: "adminPage") as? AdminPageTableViewController {
            
            // Check if the current view controller is inside a navigation controller
            if let navigationController = self.navigationController {
                // Push the AdminPage view controller
                navigationController.pushViewController(adminVC, animated: true)
                
                // Remove the back button from the navigation bar (so the user can't go back to login page)
                adminVC.navigationItem.hidesBackButton = true
            } else {
                // If not inside a navigation controller, present the AdminPage modally
                self.present(adminVC, animated: true, completion: nil)
            }
        } else {
            self.showAlert(title: "Error", message: "Unable to load the Admin Page.")
        }
    }

}
