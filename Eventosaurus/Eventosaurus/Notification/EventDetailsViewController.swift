import UIKit
import FirebaseFirestore
import FirebaseAuth
protocol EventDetailsDelegate: AnyObject {
    func didJoinEvent(eventData: [String: Any])
}
class EventDetailsViewController: UIViewController {
    @IBOutlet weak var joinButton: UIButton!
    
    let db = Firestore.firestore()
    var eventData: [String: Any]?
    weak var delegate: EventDetailsDelegate?

    @IBAction func joinButtonTapped(_ sender: UIButton) {
        guard let eventData = eventData,
              let eventID = eventData["eventID"] as? String else {
            print("Event data is invalid.")
            return
        }
        
        // Function to show a popup notification
        func showPopupNotification(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        let user = Auth.auth().currentUser
        let userEmail = user?.email ?? "unknown"
        
        // Add the event to the Firestore Event_User collection
        db.collection("Event_User").addDocument(data: [
            "email": userEmail,
            "event_id": eventID
        ]) { error in
            if let error = error {
                print("Error joining event: \(error)")
            } else {
                print("Event joined successfully!")
                
                // Show success notification
                showPopupNotification(title: "Success", message: "You have successfully joined the event!")
                
                // Pass the event data to the JoinedEventsViewController
                if let navigationController = self.navigationController,
                               let notificationVC = navigationController.viewControllers.last as? NotificationViewController {
                                notificationVC.joinedEvents.append(eventData) // Add the event to the list
                                notificationVC.tableView.reloadData() // Reload the table view
                            }
                                // Dismiss the current view controller
                       self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
