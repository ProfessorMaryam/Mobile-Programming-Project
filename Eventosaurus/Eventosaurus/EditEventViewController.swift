import UIKit
import FirebaseFirestore

class EditEventViewController: UIViewController {
    
    // Outlets for the text fields and text view to edit event details
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var organizerTextField: UITextField!
    @IBOutlet weak var coOrganizerTextField: UITextField!
    @IBOutlet weak var maxAttendeesTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!

    var eventID: String? // Store the event ID passed from the previous view controller
    let db = Firestore.firestore() // Create an instance of Firestore for database operations

    override func viewDidLoad() {
        super.viewDidLoad()
        loadEventData() // Load event data when the view loads
    }

    // Load event data from Firestore
    func loadEventData() {
        guard let eventID = eventID else { return } // Exit if eventID is nil
        
        // Fetch the event document from Firestore using the eventID
        db.collection("Events").document(eventID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error)") // Print error if occurs
                return
            }
            guard let document = document, document.exists, let data = document.data() else {
                print("Document does not exist") // Print message if document does not exist
                return
            }
            
            // Populate text fields with event data retrieved from Firestore
            self.eventNameTextField.text = data["Event Name"] as? String
            self.eventDateTextField.text = data["Date"] as? String
            self.organizerTextField.text = data["Organizer1"] as? String
            self.coOrganizerTextField.text = data["Organizer2"] as? String
            
            // Convert maximum attendees to string for the text field
            if let maxAttendees = data["Maximum Attendees"] as? Int {
                self.maxAttendeesTextField.text = "\(maxAttendees)"
            }
            self.descriptionTextView.text = data["Description"] as? String // Set event description
        }
    }

    // Action triggered when the Done button is pressed
    @IBAction func Done(_ sender: UIButton) {
        updateEvent() // Call method to update event information
    }
    
    // Method to update the event data in Firestore
    func updateEvent() {
        guard let eventID = eventID else { return } // Exit if eventID is nil

        // Dictionary to hold the updated event data
        var updatedData: [String: Any] = [:]

        // Check and add each field's new value if it's not empty
        if let eventName = eventNameTextField.text, !eventName.isEmpty {
            updatedData["Event Name"] = eventName
        }
        if let eventDate = eventDateTextField.text, !eventDate.isEmpty {
            updatedData["Date"] = eventDate
        }
        if let organizer1 = organizerTextField.text, !organizer1.isEmpty {
            updatedData["Organizer1"] = organizer1
        }
        if let organizer2 = coOrganizerTextField.text, !organizer2.isEmpty {
            updatedData["Organizer2"] = organizer2
        }
        if let maxAttendeesString = maxAttendeesTextField.text, let maxAttendees = Int(maxAttendeesString) {
            updatedData["Maximum Attendees"] = maxAttendees // Convert max attendees to Int
        }
        if let description = descriptionTextView.text, !description.isEmpty {
            updatedData["Description"] = description
        }

        // Update the Event in Firestore, merging with existing data
        db.collection("Events").document(eventID).setData(updatedData, merge: true) { error in
            if let error = error {
                print("Error updating Event: \(error)") // Print error if occurs
            } else {
                print("Event updated successfully!") // Confirmation message
                // Optionally, navigate back or clear fields
                self.navigationController?.popViewController(animated: true) // Navigate back to previous view
            }
        }
    }
}
