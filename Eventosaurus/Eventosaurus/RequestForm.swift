import UIKit
import FirebaseFirestore

class RequestForm: UIViewController {

    @IBOutlet weak var qualificationsTextField: UITextView!
    @IBOutlet weak var WDYWTBOTextField: UITextView!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var FullNameTextField: UITextField!
    
    // Firestore reference
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
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

        // Check if the email exists in the "Users" collection and if the user is an organizer
        checkEmailExistsAndOrganizer(email: email) { exists, isOrganizer in
            if exists {
                if isOrganizer {
                    // User is already an organizer, show an alert
                    self.showAlert(message: "You are already an organizer.")
                } else {
                    // Email exists and user is not an organizer, save the request data
                    self.saveRequestData(email: email, fullName: fullName, qualifications: qualifications, WDYWTBO: WDYWTBO)
                }
            } else {
                // Email does not exist, show an alert
                self.showAlert(message: "You need to create an account first.")
            }
        }
    }
    
    // Function to check if the email exists in the Users collection and if the user is an organizer
    func checkEmailExistsAndOrganizer(email: String, completion: @escaping (Bool, Bool) -> Void) {
        let usersRef = db.collection("Users")
        
        // Query the "Users" collection for the given email (Field is 'Email' in Firestore)
        usersRef.whereField("Email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking email: \(error.localizedDescription)")
                completion(false, false)
            } else {
                // If the snapshot is not empty, the email exists
                if let snapshot = snapshot, !snapshot.isEmpty {
                    // If the user is found, check the 'Is Organizer' field
                    if let document = snapshot.documents.first,
                       let isOrganizer = document.get("Is Organizer") as? Bool, isOrganizer {
                        // User is an organizer
                        completion(true, true)
                    } else {
                        // User exists, but not an organizer
                        completion(true, false)
                    }
                } else {
                    // Email does not exist in the Users collection
                    completion(false, false)
                }
            }
        }
    }
    
    // Function to save the request data to Firestore
    func saveRequestData(email: String, fullName: String, qualifications: String, WDYWTBO: String) {
        // Create a dictionary with the form data
        let requestData: [String: Any] = [
            "qualifications": qualifications,
            "WDYWTBO": WDYWTBO,
            "email": email,
            "fullName": fullName,
            "timestamp": FieldValue.serverTimestamp() // Automatically adds the current timestamp
        ]
        
        // Save the data to Firestore in the "Requests" collection
        db.collection("Requests").addDocument(data: requestData) { error in
            if let error = error {
                // Show an error alert if something goes wrong
                self.showAlert(message: "Error saving data: \(error.localizedDescription)")
            } else {
                // Show a success alert or navigate to another screen
                self.showAlert(message: "Request submitted successfully!")
            }
        }
    }
    
    // Helper function to show alerts
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
}
