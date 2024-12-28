import UIKit
import FirebaseFirestore
import FirebaseAuth

class joinEventPageViewController: UIViewController {
    
    // Create an instance of Firestore to interact with the database
    let db = Firestore.firestore()
    
    @IBOutlet weak var backButton: UIButton!
    // Property to get the current user's ID if they are logged in
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    @IBAction func BackbuttonTapped(_ sender: Any) {
        
        navigateToHomePage()
        
        
    }
    // Property to hold the event ID for the event the user wants to join
    var eventID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup can be done here after the view has loaded
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
                let alertController = UIAlertController(title: "Error", message: "Failed to join event. Please try again.", preferredStyle: .alert)
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
    
    
    
    // Function to navigate to the "HomePage" storyboard modally
    func navigateToHomePage() {
        // Load the "HomePage" storyboard
        let storyboard = UIStoryboard(name: "HomePage ", bundle: nil)
        
        // Instantiate the "EventHomeViewController" by its identifier
        if let eventHomeVC = storyboard.instantiateViewController(withIdentifier: "EventHomeViewController") as? EventHomeViewController {
            // Present the EventHomeViewController modally
            eventHomeVC.modalPresentationStyle = .fullScreen
            present(eventHomeVC, animated: true, completion: nil)
        } else {
            // Handle the error if the view controller could not be casted
            print("Error: Unable to cast the view controller to EventHomeViewController")
        }
    }
}
