import UIKit
import FirebaseFirestore
import FirebaseAuth

class joinEventPageViewController: UIViewController {
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var eventNameLabel: UILabel!
    
    @IBOutlet weak var eventDescText: UITextView!
    
    // Create an instance of Firestore to interact with the database
    let db = Firestore.firestore()
    
    // Property to get the current user's ID if they are logged in
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // Property to hold the event ID for the event the user wants to join
    var eventID: String?
    var eventName: String?
    var eventCatg: String?
    var eventDesc: String?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure data is set before updating the UI
        eventID = EventCurrentSelection.shared.getEventID()
        eventName = EventCurrentSelection.shared.getEventName()
        eventDesc = EventCurrentSelection.shared.getEventDescription()
        eventCatg = EventCurrentSelection.shared.getEventCategory()

        // Debugging log to check if the values are correctly set
        print("eventID: \(eventID ?? "nil")")
        print("eventName: \(eventName ?? "nil")")
        print("eventDesc: \(eventDesc ?? "nil")")
        print("eventCatg: \(eventCatg ?? "nil")")

        // Set the UI elements with the event data
        eventNameLabel.text = eventName
        eventDescText.text = eventDesc

        // Set the image for the category
        if let category = eventCatg {
            setImageForCategory(category)
        }
    }
    
    
    private func setImageForCategory(_ category: String) {
        print("Setting image for category: \(category)") // Debug log
        
        switch category {
        case "Music":
            eventImageView.image = UIImage(named: "Music.png")
        case "Sports":
            eventImageView.image = UIImage(named: "Sports.png")
        case "Entertainment":
            eventImageView.image = UIImage(named: "Entertaintment.png")
        case "Comedy":
            eventImageView.image = UIImage(named: "Comedy.png")
        case "Health Wellness":
            eventImageView.image = UIImage(named: "Health.png")
        case "Social":
            eventImageView.image = UIImage(named: "Social.png")
        case "Art & Literature":
            eventImageView.image = UIImage(named: "Art.png")
        case "Education":
            eventImageView.image = UIImage(named: "Education.png")
        case "Food":
            eventImageView.image = UIImage(named: "Food.png")
        case "Fashion":
            eventImageView.image = UIImage(named: "Fashion.png")
        default:
            eventImageView.image = UIImage(named: "Social.png")
        }
    }
    
    
    // Action triggered when the payment button is pressed
    @IBAction func payBtn(_ sender: UIButton) {
        // Check if the user is logged in and the event ID is not nil
        guard let userID = currentUserID, let eventID = eventID else {
            // Show an alert if the user is not logged in or the event ID is missing
            let alertController = UIAlertController(title: "Error", message: "User is not logged in or event ID is missing.", preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "Done", style: .default, handler: nil)
            alertController.addAction(doneAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        // Reference to the user's document in Firestore
        let userRef = db.collection("Users").document(userID)
        
        // Update the user's document to add the event they are joining
        userRef.updateData([
            "joinedEvents": FieldValue.arrayUnion([eventID]) // Use arrayUnion to add eventID to joinedEvents array
        ]) { error in
            if let error = error {
                // Handle error and show an alert if the update fails
                print("Error updating document: \(error)")
                let alertController = UIAlertController(title: "Error", message: "You have successfully joined the event.", preferredStyle: .alert)
                let doneAction = UIAlertAction(title: "Done", style: .default, handler: nil)
                alertController.addAction(doneAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                // Show success alert if the event was joined successfully
                let alertController = UIAlertController(title: "Payment Successful", message: "You have successfully joined the event.", preferredStyle: .alert)
                let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
                    // Optionally log the event or navigate back after joining
                    print("User joined event: \(eventID)")
                }
                alertController.addAction(doneAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        navigateToEventHome()
    }
    func navigateToEventHome() {
        // Create an instance of EventHomeViewController from the storyboard
        let storyboard = UIStoryboard(name: "HomePage ", bundle: nil)
        guard let eventHomeVC = storyboard.instantiateViewController(withIdentifier: "EventHomeViewController") as? EventHomeViewController else {
            print("Error: Could not find EventHomeViewController in storyboard")
            return
        }
        
        // Initialize a navigation controller with EventHomeViewController as the root view controller
        let navigationController = UINavigationController(rootViewController: eventHomeVC)
        
        // Find the active scene and set the navigation controller as the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        } else {
            print("Error: Unable to find the active window scene.")
        }
    }

}
