import UIKit
import FirebaseFirestore
import FirebaseAuth

class joinEventPageViewController: UIViewController {
    
    let db = Firestore.firestore()
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // Assuming you have the event ID you want the user to join
    var eventID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    
    }
    
    @IBAction func payBtn(_ sender: UIButton) {
        // Check if the user is logged in
        guard let userID = currentUserID, let eventID = eventID else {
            // Handle the case where user is not logged in or event ID is missing
            let alertController = UIAlertController(title: "Error", message: "User is not logged in or event ID is missing.", preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "Done", style: .default, handler: nil)
            alertController.addAction(doneAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        // Update the user's document in Firestore to include the event they are joining
        let userRef = db.collection("Users").document(userID)
        
        userRef.updateData([
            "joinedEvents": FieldValue.arrayUnion([eventID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
                let alertController = UIAlertController(title: "Error", message: "Failed to join event. Please try again.", preferredStyle: .alert)
                let doneAction = UIAlertAction(title: "Done", style: .default, handler: nil)
                alertController.addAction(doneAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // Show success alert
                let alertController = UIAlertController(title: "Payment Successful", message: "You have successfully joined the event.", preferredStyle: .alert)
                let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
                    // Optionally navigate back or perform another action
                    print("User joined event: \(eventID)")
                }
                alertController.addAction(doneAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
