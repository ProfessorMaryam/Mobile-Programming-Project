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
        
        //hidden initiallay
        emailReqLabel.isHidden = true
        passwordReqLabel.isHidden = true
    }
    
    
    
    //Login button action
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
         
                            
                            
                            
//                        Non-Admin User segues to be handled here
                            
                            
                            
                            
                            
                            
                        }
                    } else {
                        self.showAlert(title: "Login Error", message: "Incorrect password. Please try again.") //wrong password
                    }
                } else {
                    self.showAlert(title: "Login Error", message: "Account does not exist. Please sign up.") //account doesnt exist
                }
            }
        } else {
            self.showAlert(title: "Invalid Input", message: "Please enter both email and password.") // empty fields
        }
    }
    
    // Function to validate email format using regex
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    // custom alert
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Function to navigate to the AdminPage view controller in another storyboard
    func navigateToAdminPage() {
        // Load the "AdminPage" storyboard
        let adminStoryboard = UIStoryboard(name: "AdminPage", bundle: nil)
        
        // Instantiate the AdminPage view controller using its Storyboard ID
        if let adminVC = adminStoryboard.instantiateViewController(withIdentifier: "adminPage") as? AdminPageTableViewController {
            
            // Check if the current view controller is inside a navigation controller
            if let navigationController = self.navigationController {
                // Push the AdminPage view controller
                navigationController.pushViewController(adminVC, animated: true)
                
                // Remove the back button from the navigation bar so the user cannot go back to login page
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







//
//
//import Security
//
//class KeychainHelper {
//    static func save(key: String, value: String) {
//        if let data = value.data(using: .utf8) {
//            let query: [CFString: Any] = [
//                kSecClass: kSecClassGenericPassword,
//                kSecAttrAccount: key,
//                kSecValueData: data
//            ]
//            
//            // Delete any existing item with the same key
//            SecItemDelete(query as CFDictionary)
//            
//            // Add new item
//            let status = SecItemAdd(query as CFDictionary, nil)
//            if status != errSecSuccess {
//                print("Error saving to keychain: \(status)")
//            }
//        }
//    }
//    
//    static func load(key: String) -> String? {
//        let query: [CFString: Any] = [
//            kSecClass: kSecClassGenericPassword,
//            kSecAttrAccount: key,
//            kSecReturnData: true,
//            kSecMatchLimit: kSecMatchLimitOne
//        ]
//        
//        var result: AnyObject?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//        
//        if status == errSecSuccess, let data = result as? Data, let value = String(data: data, encoding: .utf8) {
//            return value
//        } else {
//            print("Error loading from keychain: \(status)")
//            return nil
//        }
//    }
//    
//    static func delete(key: String) {
//        let query: [CFString: Any] = [
//            kSecClass: kSecClassGenericPassword,
//            kSecAttrAccount: key
//        ]
//        let status = SecItemDelete(query as CFDictionary)
//        if status != errSecSuccess {
//            print("Error deleting from keychain: \(status)")
//        }
//    }
//}
//
//
//import UIKit
//import FirebaseFirestore
//
//class LoginPage: UIViewController {
//    
//    // Outlets for text fields and their corresponding labels
//    @IBOutlet weak var emailReqLabel: UILabel!
//    @IBOutlet weak var passwordReqLabel: UILabel!
//    @IBOutlet weak var emailTxtField: UITextField!
//    @IBOutlet weak var passwordTxtField: UITextField!
//    
//    let db = Firestore.firestore()  // Firestore reference
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Check if the user is already logged in
//        if let loggedInUserID = KeychainHelper.load(key: "loggedInUserID") {
//            // If the user is logged in, fetch their data and navigate to the appropriate screen
//            fetchUserData(userID: loggedInUserID)
//        } else {
//            // No logged-in user, show login form
//            print("No user is logged in.")
//        }
//        
//        // Initially hide validation labels
//        emailReqLabel.isHidden = true
//        passwordReqLabel.isHidden = true
//    }
//    
//    // Login button action
//    @IBAction func loginButtonTapped(_ sender: Any) {
//        var isValid = true
//        emailReqLabel.isHidden = true
//        passwordReqLabel.isHidden = true
//        
//        // Validate email
//        if let email = emailTxtField.text, email.isEmpty {
//            emailReqLabel.isHidden = false
//            emailReqLabel.text = "Email is required."
//            isValid = false
//        } else if let email = emailTxtField.text, !isValidEmail(email) {
//            emailReqLabel.isHidden = false
//            emailReqLabel.text = "Invalid email format."
//            isValid = false
//        }
//        
//        // Validate password
//        if let password = passwordTxtField.text, password.isEmpty {
//            passwordReqLabel.isHidden = false
//            passwordReqLabel.text = "Password is required."
//            isValid = false
//        }
//        
//        if isValid {
//            guard let email = emailTxtField.text, let password = passwordTxtField.text else {
//                return
//            }
//            
//            // Query Firestore to check if the email exists
//            let usersRef = self.db.collection("Users")
//            usersRef.whereField("Email", isEqualTo: email).getDocuments { snapshot, error in
//                if let error = error {
//                    self.showAlert(title: "Error", message: "Error accessing user data: \(error.localizedDescription)")
//                    return
//                }
//                
//                if let document = snapshot?.documents.first {
//                    let storedPassword = document.get("Password") as? String ?? ""
//                    
//                    if password == storedPassword {
//                        // Save user ID to Keychain for login persistence
//                        let userID = document.documentID
//                        KeychainHelper.save(key: "loggedInUserID", value: userID)
//                        
//                        let isAdmin = document.get("Is Admin") as? Bool ?? false
//                        
//                        if isAdmin {
//                            // Admin login successful, navigate to Admin page immediately
//                            self.navigateToAdminPage()
//                        } else {
//                            // Non-admin user login successful, navigate to User page
//                          //  self.navigateToUserPage()
//                        }
//                    } else {
//                        self.showAlert(title: "Login Error", message: "Incorrect password. Please try again.")
//                    }
//                } else {
//                    self.showAlert(title: "Login Error", message: "Account does not exist. Please sign up.")
//                }
//            }
//        } else {
//            self.showAlert(title: "Invalid Input", message: "Please enter both email and password.")
//        }
//    }
//    
//    // Function to validate email format using regex
//    func isValidEmail(_ email: String) -> Bool {
//        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
//        return emailTest.evaluate(with: email)
//    }
//    
//    // Custom alert
//    func showAlert(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(alertController, animated: true, completion: nil)
//    }
//    
//    // Function to navigate to the AdminPage view controller in another storyboard
//    func navigateToAdminPage() {
//        // Load the "AdminPage" storyboard
//        let adminStoryboard = UIStoryboard(name: "AdminPage", bundle: nil)
//        
//        // Instantiate the AdminPage view controller using its Storyboard ID
//        if let adminVC = adminStoryboard.instantiateViewController(withIdentifier: "adminPage") as? AdminPageTableViewController {
//            
//            // Check if the current view controller is inside a navigation controller
//            if let navigationController = self.navigationController {
//                // Push the AdminPage view controller
//                navigationController.pushViewController(adminVC, animated: true)
//                
//                // Remove the back button from the navigation bar so the user cannot go back to login page
//                adminVC.navigationItem.hidesBackButton = true
//            } else {
//                // If not inside a navigation controller, present the AdminPage modally
//                self.present(adminVC, animated: true, completion: nil)
//            }
//        } else {
//            self.showAlert(title: "Error", message: "Unable to load the Admin Page.")
//        }
//    }
//    
//    // Function to navigate to the User's page
////    func navigateToUserPage() {
////        // Load the "UserPage" storyboard (you should create this storyboard if not already done)
////        let userStoryboard = UIStoryboard(name: "UserPage", bundle: nil)
////
////        // Instantiate the UserPage view controller using its Storyboard ID
////        if let userVC = userStoryboard.instantiateViewController(withIdentifier: "userPage") {
////            self.present(userVC, animated: true, completion: nil)
////        } else {
////            self.showAlert(title: "Error", message: "Unable to load the User Page.")
////        }
////    }
//    
//    // Fetch user data from Firestore using userID and navigate to appropriate page
//    func fetchUserData(userID: String) {
//        let usersRef = db.collection("Users")
//        usersRef.document(userID).getDocument { (document, error) in
//            if let error = error {
//                self.showAlert(title: "Error", message: "Error fetching user data: \(error.localizedDescription)")
//                return
//            }
//            
//            if let document = document, document.exists {
//                let isAdmin = document.get("Is Admin") as? Bool ?? false
//                if isAdmin {
//                    // Navigate to Admin page immediately
//                    self.navigateToAdminPage()
//                } else {
//                    // Navigate to User page immediately
//                   // self.navigateToUserPage()
//                }
//            } else {
//                self.showAlert(title: "Error", message: "Failed to fetch user data.")
//            }
//        }
//    }
//    
//    // Logout button action
//    @IBAction func logoutButtonTapped(_ sender: Any) {
//        // Delete the user ID from Keychain to log out
//        KeychainHelper.delete(key: "loggedInUserID")
//        
//        // Navigate back to the login screen
//        if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginPage") {
//            // You can present the login view controller modally
//            self.present(loginVC, animated: true, completion: nil)
//        }
//    }
//}
