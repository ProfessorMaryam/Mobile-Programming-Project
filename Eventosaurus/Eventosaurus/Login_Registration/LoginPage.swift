import UIKit
import FirebaseFirestore

class CurrentLoginUser {
    static let shared = CurrentLoginUser()  // Singleton instance
    
    var currentUserID: String?  // This will store the current logged-in user ID
    
    private init() {}  // Private initializer to prevent creating another instance
    
    // Use `shared` instance to access this class throughout the app.
    
    // Function to set the user ID
    func setUserID(_ userID: String) {
        self.currentUserID = userID
        print("Logged in user ID set to: \(userID)")  // Debugging line to verify the user ID
    }
    
    // Function to get the user ID
    func getUserID() -> String? {
        return self.currentUserID
    }
}


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
            } else {
                print("No user is logged in.") // Debugging line to check if the user is logged in
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
                            let currentUserID = document.documentID  // This gets the document ID (user's ID)
                            
                            // Save the user ID in the CurrentLoginUser singleton
                            CurrentLoginUser.shared.setUserID(currentUserID)
                            
                            // You can still save the user ID in UserDefaults if you want to persist across app restarts
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            UserDefaults.standard.set(currentUserID, forKey: "currentUserID")
                            UserDefaults.standard.synchronize()
                            
                            // Log the saved user ID
                            print("Successfully logged in! Current User ID: \(currentUserID)")  // <-- This prints the currentUserID

                            // Navigate to the appropriate page
                            let isAdmin = document.get("Is Admin") as? Bool ?? false
                            if isAdmin {
                                self.navigateToAdminPage()
                            } else {
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
      
        // Email regex validation
        func isValidEmail(_ email: String) -> Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return emailTest.evaluate(with: email)
        }
        
        // Custom alert function
        func showAlert(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        // Navigate to AdminPage view controller
        func navigateToAdminPage() {
            let adminStoryboard = UIStoryboard(name: "AdminPage", bundle: nil) // Store storyboard in a variable
            if let adminVC = adminStoryboard.instantiateViewController(withIdentifier: "adminPage") as? AdminPageTableViewController {
                if let navigationController = self.navigationController { // Referencing the current navigation controller
                    navigationController.pushViewController(adminVC, animated: true)
                    adminVC.navigationItem.hidesBackButton = true // Hide back button after login
                } else {
                    self.present(adminVC, animated: true, completion: nil) // If not in navigation controller, present modally
                }
            } else {
                self.showAlert(title: "Error", message: "Unable to load Admin Page.")
            }
        }
        
        // Navigate to UserPage view controller (for non-admin users)
        func navigateToUserPage() {
            let userStoryboard = UIStoryboard(name: "HomePage ", bundle: nil) // Ensure there's no extra space in the storyboard name
            
            if let userVC = userStoryboard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
                userVC.modalPresentationStyle = .fullScreen
                self.present(userVC, animated: true, completion: nil)
            } else {
                self.showAlert(title: "Error", message: "Unable to load User Page.")
            }
        }

        // Navigate to the appropriate page based on user type
        func navigateToAppropriatePage() {
            if let currentUserID = CurrentLoginUser.shared.getUserID() {
                print("Current logged-in user ID: \(currentUserID)")  // Debugging line to show current user ID
                if let isAdmin = UserDefaults.standard.value(forKey: "isAdmin") as? Bool, isAdmin {
                    // If the user is an admin, navigate to AdminPage
                    navigateToAdminPage()
                } else {
                    navigateToUserPage()
                }
            } else {
                print("No logged-in user found in shared instance.")  // Debugging line if no user is logged in
            }
        }
    }
