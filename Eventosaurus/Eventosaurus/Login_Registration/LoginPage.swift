import UIKit
import FirebaseFirestore

class LoginPage: UIViewController {
    
    // outlets for text fields and their corresponding labels
    @IBOutlet weak var emailReqLabel: UILabel!
    @IBOutlet weak var passwordReqLabel: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    let db = Firestore.firestore()  // Firestore reference
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initially hide validation labels
        emailReqLabel.isHidden = true
        passwordReqLabel.isHidden = true
        
        // Check if the user is already logged in
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            // If logged in, fetch user data and navigate to the appropriate screen
            navigateToAppropriatePage()
        }
    }
    
    // Login button action
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        var isValid = true
        emailReqLabel.isHidden = true
        passwordReqLabel.isHidden = true
        
        // Validate email
        if let email = emailTxtField.text, email.isEmpty {
            emailReqLabel.isHidden = false
            emailReqLabel.text = "Email is required."
            isValid = false
        } else if let email = emailTxtField.text, !isValidEmail(email) {  //uses the regex checking method defined below, if regex is invalid then...
            emailReqLabel.isHidden = false // ... show label
            emailReqLabel.text = "Invalid email format." // change label text to error message
            isValid = false // nnot valid
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
                        
                        // Save the login state and user role in UserDefaults
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(isAdmin, forKey: "isAdmin") // Store whether the user is an admin
                        UserDefaults.standard.synchronize()
                        
                        User.loggedInemail = email
                        if isAdmin {
                            // Admin login successful, navigate to the AdminPage
                            self.navigateToAdminPage()
                        } else {
                            // Non-Admin User: Navigate to UserPage (you should implement this view)
                           self.navigateToUserPage()
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
    
    // Custom alert
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Navigate to AdminPage view controller
    func navigateToAdminPage() {
        let adminStoryboard = UIStoryboard(name: "AdminPage", bundle: nil)
        if let adminVC = adminStoryboard.instantiateViewController(withIdentifier: "adminPage") as? AdminPageTableViewController {
            if let navigationController = self.navigationController {
                navigationController.pushViewController(adminVC, animated: true)
                adminVC.navigationItem.hidesBackButton = true
            } else {
                self.present(adminVC, animated: true, completion: nil)
            }
        } else {
            self.showAlert(title: "Error", message: "Unable to load Admin Page.")
        }
    }
    
    // Navigate to UserPage view controller (for non-admin users)
    func navigateToUserPage() {
        // Implement this navigation for non-admin users
        let userStoryboard = UIStoryboard(name: "HomePage ", bundle: nil)  // Remove extra space in storyboard name
        
        if let userVC = userStoryboard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
            // Set the modal presentation style to full screen
            userVC.modalPresentationStyle = .fullScreen
            
            // Present the view controller modally
            self.present(userVC, animated: true, completion: nil)
        } else {
            self.showAlert(title: "Error", message: "Unable to load User Page.")
        }
    }

    
    // Navigate to the appropriate page based on user type
    func navigateToAppropriatePage() {
        if let isAdmin = UserDefaults.standard.value(forKey: "isAdmin") as? Bool, isAdmin {
            // If the user is an admin, navigate to AdminPage
            navigateToAdminPage()
        } else {
            navigateToUserPage()
        }
    }
}
