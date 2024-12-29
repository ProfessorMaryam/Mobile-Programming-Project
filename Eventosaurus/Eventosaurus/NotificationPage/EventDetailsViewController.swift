import UIKit
import FirebaseFirestore
import FirebaseAuth

class EventDetailsViewController: UIViewController {
    @IBOutlet weak var joinButton: UIButton!
    
    let db = Firestore.firestore()
    var eventData: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Optionally, you can set up UI elements to display event details
        if let eventName = eventData?["Event Name"] as? String {
            self.title = eventName // Set the navigation title to the event name
        }
    }

    @IBAction func joinButtonTapped(_ sender: UIButton) {
        guard let user = Auth.auth().currentUser,
              let eventData = eventData,
              let eventID = eventData["eventID"] as? String else {
            print("User not logged in or eventData is invalid.")
            return
        }
        
        let userEmail = user.email ?? "unknown"
        
        // Add the event to the Event_User collection
        db.collection("Event_User").addDocument(data: [
            "email": userEmail,
            "event_id": eventID
        ]) { error in
            if let error = error {
                print("Error joining event: \(error)")
            } else {
                print("Event joined successfully!")
                
                // Navigate back to NotificationViewController
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
