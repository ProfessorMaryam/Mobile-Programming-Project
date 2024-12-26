import UIKit
import FirebaseFirestore

class EditEventViewController: UIViewController {
    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var organizerTextField: UITextField!
    @IBOutlet weak var coOrganizerTextField: UITextField!
    @IBOutlet weak var maxAttendeesTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!

    var eventID: String? // Store the event ID passed from the previous view controller
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadEventData()
    }

    // Load event data from Firestore
    func loadEventData() {
        guard let eventID = eventID else { return }
        
        db.collection("Events").document(eventID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }
            guard let document = document, document.exists, let data = document.data() else {
                print("Document does not exist")
                return
            }
            
            // Populate text fields with event data
            self.eventNameTextField.text = data["Event Name"] as? String
            self.eventDateTextField.text = data["Date"] as? String
            self.organizerTextField.text = data["Organizer1"] as? String
            self.coOrganizerTextField.text = data["Organizer2"] as? String
            if let maxAttendees = data["Maximum Attendees"] as? Int {
                self.maxAttendeesTextField.text = "\(maxAttendees)"
            }
            self.descriptionTextView.text = data["Description"] as? String
        }
    }

    
    @IBAction func Done(_ sender: UIButton) {
        updateEvent()
    }
    func updateEvent() {
        guard let eventID = eventID else { return }
        
        var updatedData: [String: Any] = [:]

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
            updatedData["Maximum Attendees"] = maxAttendees
        }
        if let description = descriptionTextView.text, !description.isEmpty {
            updatedData["Description"] = description
        }

        // Update the Event in Firestore
        db.collection("Events").document(eventID).setData(updatedData, merge: true) { error in
            if let error = error {
                print("Error updating Event: \(error)")
            } else {
                print("Event updated successfully!")
                // Optionally, navigate back or clear fields
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
