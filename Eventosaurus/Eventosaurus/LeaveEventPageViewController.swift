import UIKit
import FirebaseFirestore
import FirebaseAuth

class LeaveEventPageViewController: UIViewController {

    let db = Firestore.firestore()
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // Assuming you have the event ID you want the user to leave
    var eventID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    @IBAction func leaveBtn(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Withdraw", message: "Are you sure you want to withdraw from this event?", preferredStyle: .alert)
        
        let withdrawAction = UIAlertAction(title: "Withdraw", style: .destructive) { _ in
            self.withdrawFromEvent()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Withdrawing from event canceled.")
        }
        
        alertController.addAction(withdrawAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func withdrawFromEvent() {
        guard let userID = currentUserID, let eventID = eventID else {
            // Handle the case where user is not logged in or event ID is missing
            let alertController = UIAlertController(title: "Error", message: "User is not logged in or event ID is missing.", preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "Done", style: .default, handler: nil)
            alertController.addAction(doneAction)
            present(alertController, animated: true, completion: nil)
            return
        }

        // Update the user's document in Firestore to remove the event they are leaving
        let userRef = db.collection("Users").document(userID)
        
        userRef.updateData([
            "joinedEvents": FieldValue.arrayRemove([eventID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
                let alertController = UIAlertController(title: "Error", message: "Failed to withdraw from event. Please try again.", preferredStyle: .alert)
                let doneAction = UIAlertAction(title: "Done", style: .default, handler: nil)
                alertController.addAction(doneAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // Show success alert
                let alertController = UIAlertController(title: "Withdrawn", message: "You have successfully withdrawn from the event.", preferredStyle: .alert)
                let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
                    // Optionally navigate back or perform another action
                    print("User withdrew from event: \(eventID)")
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(doneAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
