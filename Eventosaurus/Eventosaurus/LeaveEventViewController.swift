import UIKit
import FirebaseFirestore
import FirebaseAuth

class LeaveEventPageViewController: UIViewController {

    // Create an instance of Firestore for database operations
    let db = Firestore.firestore()
    
    // Property to get the current user's ID if they are logged in
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // Property to hold the event ID for the event the user wants to leave
    var eventID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup can be done here after the view has loaded
    }
    
    // Action triggered when the leave button is pressed
    @IBAction func leaveBtn(_ sender: UIButton) {
        // Show an alert asking for confirmation to withdraw from the event
        let alertController = UIAlertController(title: "Withdraw", message: "Are you sure you want to withdraw from this event?", preferredStyle: .alert)
        
        // Action to confirm withdrawal
        let withdrawAction = UIAlertAction(title: "Withdraw", style: .destructive) { _ in
            self.withdrawFromEvent() // Call method to handle withdrawal
        }
        
        // Action to cancel the withdrawal
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Withdrawing from event canceled.") // Log cancellation
        }
        
        // Add actions to the alert controller
        alertController.addAction(withdrawAction)
        alertController.addAction(cancelAction)
        
        // Present the alert to the user
        present(alertController, animated: true, completion: nil)
    }
    
    // Method to handle user's withdrawal from an event
    func withdrawFromEvent() {
        // Ensure the user is logged in and the event ID is valid
        guard let userID = currentUserID, let eventID = eventID else {
            // Show an error alert if the user is not logged in or the event ID is missing
            let alertController = UIAlertController(title: "Error", message: "User is not logged in or event ID is missing.", preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "Done", style: .default, handler: nil)
            alertController.addAction(doneAction)
            present(alertController, animated: true, completion: nil)
            return
        }

        // Reference to the user's document in Firestore
        let userRef = db.collection("Users").document(userID)
        
        // Update the user's document to remove the event they are leaving
        userRef.updateData([
            "joinedEvents": FieldValue.arrayRemove([eventID]) // Use arrayRemove to remove eventID from joinedEvents array
        ]) { error in
            if let error = error {
                // Handle error and show an alert if the update fails
                print("Error updating document: \(error)")
                let alertController = UIAlertController(title: "Error", message: "Failed to withdraw from event. Please try again.", preferredStyle: .alert)
                let doneAction = UIAlertAction(title: "Done", style: .default, handler: nil)
                alertController.addAction(doneAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // Show success alert if the user successfully withdrew from the event
                let alertController = UIAlertController(title: "Withdrawn", message: "You have successfully withdrawn from the event.", preferredStyle: .alert)
                let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
                    // Optionally navigate back or perform another action after withdrawal
                    print("User withdrew from event: \(eventID)")
                    self.navigationController?.popViewController(animated: true) // Navigate back to the previous view
                }
                alertController.addAction(doneAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
