import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol EventDetailsDelegate: AnyObject {
    func didJoinEvent(eventData: [String: Any])
}

class EventDetailsViewController: UIViewController {
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    
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
        
        let userEmail = User.loggeduser
        
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
                
                // Pass the event data to the NotificationViewController
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
    
    @IBAction func leaveButtonTapped(_ sender: UIButton) {
        guard let eventData = eventData,
              let eventID = eventData["eventID"] as? String else {
            print("Event data is invalid.")
            return
        }
        
        // Function to show a popup notification
        func showPopupNotification(title: String, message: String) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        let userEmail = User.loggeduser
        
        // Remove the event from the Firestore Event_User collection
        db.collection("Event_User")
            .whereField("email", isEqualTo: userEmail)
            .whereField("event_id", isEqualTo: eventID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error finding the event to leave: \(error)")
                    DispatchQueue.main.async {
                        showPopupNotification(title: "Error", message: "Unable to leave the event. Please try again.")
                    }
                    return
                }
                
                guard let documents = snapshot?.documents, let document = documents.first else {
                    print("No matching event found to leave.")
                    DispatchQueue.main.async {
                        showPopupNotification(title: "Error", message: "No matching event found to leave.")
                    }
                    return
                }
                
                // Delete the document
                self.db.collection("Event_User").document(document.documentID).delete { error in
                    if let error = error {
                        print("Error leaving event: \(error)")
                        DispatchQueue.main.async {
                            showPopupNotification(title: "Error", message: "Unable to leave the event. Please try again.")
                        }
                    } else {
                        print("Event left successfully!")
                        
                        // Show success notification
                        showPopupNotification(title: "Success", message: "You have successfully left the event!")
                        
                        // Pass the updated data to the NotificationViewController
                        if let navigationController = self.navigationController,
                           let notificationVC = navigationController.viewControllers.last as? NotificationViewController {
                            if let index = notificationVC.joinedEvents.firstIndex(where: { $0["eventID"] as? String == eventID }) {
                                let event = notificationVC.joinedEvents.remove(at: index)
                                notificationVC.upcomingEvents.append(event) // Move event back to upcoming
                                DispatchQueue.main.async {
                                    notificationVC.tableView.reloadData() // Reload the table view
                                }
                            }
                        }
                        
                        // Dismiss the current view controller
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
    }
}
