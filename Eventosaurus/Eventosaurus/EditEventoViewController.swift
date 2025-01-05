//
//  EditEventViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-15 on 10/12/2024.
//

import UIKit
import FirebaseFirestore

class EditEventoViewController: UIViewController {
    
    // Outlets for the text fields and text view to edit event details
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var organizerTextField: UITextField!
    @IBOutlet weak var coOrganizerTextField: UITextField!
    @IBOutlet weak var maxAttendeesTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!

    let db = Firestore.firestore() // Create an instance of Firestore for database operations

    override func viewDidLoad() {
        super.viewDidLoad()
        // Load event data is now triggered by a button action
    }

    // Action triggered to load event data
    @IBAction func loadEventData(_ sender: UIButton) {
        guard let eventName = eventNameTextField.text, !eventName.isEmpty else {
            print("Event Name is empty.")
            return
        }

        // Search for the event document by Event Name
        db.collection("Events").whereField("Event Name", isEqualTo: eventName).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return } // Ensure self is available

            if let error = error {
                print("Error fetching document: \(error)") // Print error if occurs
                return
            }
            guard let documents = querySnapshot?.documents, let document = documents.first else {
                print("No matching events found.") // Print message if no events are found
                return
            }

            let data = document.data()

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
    
    // Method to update the event data in Firestore based on the Event Name
    func updateEvent() {
        guard let eventName = eventNameTextField.text, !eventName.isEmpty else { return } // Exit if eventName is nil

        // Search for the event document by Event Name to get the eventID
        db.collection("Events").whereField("Event Name", isEqualTo: eventName).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return } // Ensure self is available

            if let error = error {
                print("Error fetching document: \(error)") // Print error if occurs
                return
            }
            guard let documents = querySnapshot?.documents, let document = documents.first else {
                print("No matching events found.") // Print message if no events are found
                return
            }

            let eventID = document.documentID // Get the document ID

            // Dictionary to hold the updated event data
            var updatedData: [String: Any] = [:]

            // Check and add each field's new value if it's not empty
            if let eventDate = self.eventDateTextField.text, !eventDate.isEmpty {
                updatedData["Date"] = eventDate
            }
            if let organizer1 = self.organizerTextField.text, !organizer1.isEmpty {
                updatedData["Organizer1"] = organizer1
            }
            if let organizer2 = self.coOrganizerTextField.text, !organizer2.isEmpty {
                updatedData["Organizer2"] = organizer2
            }
            if let maxAttendeesString = self.maxAttendeesTextField.text, let maxAttendees = Int(maxAttendeesString) {
                updatedData["Maximum Attendees"] = maxAttendees // Convert max attendees to Int
            }
            if let description = self.descriptionTextView.text, !description.isEmpty {
                updatedData["Description"] = description
            }

            // Update the Event in Firestore, merging with existing data
            self.db.collection("Events").document(eventID).setData(updatedData, merge: true) { error in
                if let error = error {
                    print("Error updating Event: \(error)") // Print error if occurs
                } else {
                    print("Event updated successfully!") // Confirmation message
                    // Navigate back to previous view
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
