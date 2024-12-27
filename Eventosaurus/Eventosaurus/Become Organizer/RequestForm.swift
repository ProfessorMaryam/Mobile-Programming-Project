import UIKit
import FirebaseFirestore

class RequestForm: UIViewController, UITextViewDelegate {

    @IBOutlet weak var qualificationsTextField: UITextView!
    @IBOutlet weak var WDYWTBOTextField: UITextView!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var FullNameTextField: UITextField!
    
    // Firestore reference
    let db = Firestore.firestore()

    // Character limits for the text fields
    let qualificationsTextLimit = 100  // Limit for qualifications text
    let WDYWTBOTextLimit = 100        // Limit for WDYWTBO message text

    // Placeholder text for the text views
    let qualificationsPlaceholder = "Max characters: 100"
    let WDYWTBOPlaceholder = "Max characters: 100"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate for the UITextViews
        qualificationsTextField.delegate = self
        WDYWTBOTextField.delegate = self
        
        // Set initial placeholders if text views are empty
        setPlaceholderForTextView(qualificationsTextField, placeholder: qualificationsPlaceholder)
        setPlaceholderForTextView(WDYWTBOTextField, placeholder: WDYWTBOPlaceholder)
    }

    // Function to save the data to Firestore
    @IBAction func submitForm(_ sender: UIButton) {
        // Validate the inputs
        guard let qualifications = qualificationsTextField.text, !qualifications.isEmpty,
              let WDYWTBO = WDYWTBOTextField.text, !WDYWTBO.isEmpty,
              let email = EmailTextField.text, !email.isEmpty,
              let fullName = FullNameTextField.text, !fullName.isEmpty else {
            // Show an alert if any field is empty
            showAlert(message: "Please fill out all fields.")
            return
        }
        
        // Check if the email exists in the "Requests" collection
        checkEmailExistsInRequests(email: email) { exists in
            if exists {
                // Email already exists in Requests collection, show alert
                self.showAlert(message: "You have already sent a request. Please wait for approval.")
            } else {
                // Check if the email exists in the "Users" collection and if the user is an organizer
                self.checkEmailExistsAndOrganizer(email: email) { exists, isOrganizer in
                    if exists {
                        if isOrganizer {
                            // User is already an organizer, show an alert
                            self.showAlert(message: "You're already an organizer.")
                        } else {
                            // Email exists and user is not an organizer, save the request data
                            self.saveRequestData(email: email, fullName: fullName, qualifications: qualifications, WDYWTBO: WDYWTBO)
                        }
                    } else {
                        // Email does not exist, show an alert
                        self.showAlert(message: "You need to register first.")
                    }
                }
            }
        }
    }
    
    // Function to check if email exists and if the user is an organizer
    func checkEmailExistsAndOrganizer(email: String, completion: @escaping (Bool, Bool) -> Void) {
        let usersRef = db.collection("Users")
        
        // Query the "Users" collection for the given email
        usersRef.whereField("Email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking email: \(error.localizedDescription)")
                completion(false, false)  // If there's an error, return false for both existence and organizer status
                return
            }
            
            // If a document with the email is found
            if let document = snapshot?.documents.first {
                // Check if the "Is Organizer" field exists for that user
                let isOrganizer = document.get("Is Organizer") as? Bool ?? false
                // Return true if user exists, and whether they are an organizer
                completion(true, isOrganizer)
            } else {
                // If no document is found with the email, the user doesn't exist
                completion(false, false)
            }
        }
    }
    
    // Function to save the request data to Firestore
    func saveRequestData(email: String, fullName: String, qualifications: String, WDYWTBO: String) {
        // Create a dictionary with the form data
        let requestData: [String: Any] = [
            "Qualifications": qualifications,
            "Message": WDYWTBO,
            "Email": email,
            "Full Name": fullName
        ]
        
        // Save the data to Firestore in the "Requests" collection
        db.collection("Requests").addDocument(data: requestData) { error in
            if let error = error {
                // Show an error alert if something goes wrong
                self.showAlert(message: "Error saving data: \(error.localizedDescription)")
            } else {
                // Show a success alert or navigate to another screen
                self.showAlert(message: "Request submitted successfully!") {
                    // Perform the unwind segue to go back to the startup screen
                    self.FullNameTextField.text = ""
                    self.EmailTextField.text = ""
                    self.WDYWTBOTextField.text = ""
                    self.qualificationsTextField.text = ""
                }
            }
        }
    }
    
    // Helper function to show alerts
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Call the completion block after alert is dismissed
            completion?()
        })
        self.present(alertController, animated: true, completion: nil)
    }

    // Function to set placeholder for UITextView
    func setPlaceholderForTextView(_ textView: UITextView, placeholder: String) {
        // Set the textView's text to the placeholder when it's empty
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray // Placeholder color
        }
    }

    // UITextViewDelegate method to limit character input
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Get the new length of the text after change
        let newLength = (textView.text.count - range.length) + text.count
        
        // Handle the text limit based on which UITextView is being edited
        if textView == qualificationsTextField {
            // Limit the number of characters in qualificationsTextField
            return newLength <= qualificationsTextLimit
        } else if textView == WDYWTBOTextField {
            // Limit the number of characters in WDYWTBOTextField
            return newLength <= WDYWTBOTextLimit
        }
        
        return true
    }

    // UITextViewDelegate method when editing begins (to hide the placeholder)
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black // Change to normal text color
        }
    }

    // UITextViewDelegate method when editing ends (to restore the placeholder if necessary)
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            // Set the placeholder text if the text view is empty
            setPlaceholderForTextView(textView, placeholder: textView == qualificationsTextField ? qualificationsPlaceholder : WDYWTBOPlaceholder)
        }
    }

    // Function to check if email exists in "Requests" collection
    func checkEmailExistsInRequests(email: String, completion: @escaping (Bool) -> Void) {
        let requestsRef = db.collection("Requests")
        
        // Query the "Requests" collection for the given email
        requestsRef.whereField("Email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking email in Requests: \(error.localizedDescription)")
                completion(false)  // If there's an error, return false
                return
            }
            
            // If a document with the email is found, return true
            if (snapshot?.documents.first) != nil {
                completion(true)  // Email already exists in the Requests collection
            } else {
                completion(false)  // Email does not exist in the Requests collection
            }
        }
    }
}
