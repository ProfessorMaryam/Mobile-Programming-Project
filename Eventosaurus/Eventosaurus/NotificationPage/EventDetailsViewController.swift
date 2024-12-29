import UIKit
import FirebaseFirestore
import FirebaseAuth

class EventDetailsViewController: UIViewController {
    @IBOutlet weak var joinButton: UIButton!
    
    let db = Firestore.firestore()
    var eventData: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let eventName = eventData?["Event Name"] as? String {
            self.title = eventName
        }
    }

    @IBAction func joinButtonTapped(_ sender: UIButton) {
        guard let user = Auth.auth().currentUser else {
            print("Error: User not logged in.")
            return
        }
        
        guard let eventData = eventData, let eventID = eventData["eventID"] as? String else {
            print("Error: Invalid event data.")
            return
        }
        
        let userEmail = user.email ?? "unknown"
        
        db.collection("Event_User").addDocument(data: [
            "email": userEmail,
            "event_id": eventID
        ]) { error in
            if let error = error {
                print("Error joining event: \(error)")
            } else {
                print("Event joined successfully!")
                NotificationCenter.default.post(name: Notification.Name("EventJoined"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
