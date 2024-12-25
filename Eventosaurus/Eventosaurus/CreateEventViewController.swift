//
//  CreateEventViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-15 on 10/12/2024.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CreateEventViewController: UIViewController {

    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var organizerTextField: UITextField!
    @IBOutlet weak var coOrganizerTextField: UITextField!
    @IBOutlet weak var maxAttendeesTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup if needed
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        createEvent()
    }

    func createEvent() {
        guard let eventName = eventNameTextField.text, !eventName.isEmpty,
              let eventDate = eventDateTextField.text, !eventDate.isEmpty,
              let organizer1 = organizerTextField.text, !organizer1.isEmpty,
              let organizer2 = coOrganizerTextField.text, !organizer2.isEmpty,
              let maxAttendeesString = maxAttendeesTextField.text, let maxAttendees = Int(maxAttendeesString),
              let description = descriptionTextView.text, !description.isEmpty else {
            print("Please fill in all fields correctly.")
            return
        }

        // Check if user is authenticated
        guard let user = Auth.auth().currentUser else {
            print("User is not authenticated.")
            return
        }

        let eventData: [String: Any] = [
            "Event Name": eventName,
            "Date": eventDate,
            "Organizer1": organizer1,
            "Organizer2": organizer2,
            "Maximum Attendees": maxAttendees,
            "Description": description,
            "UserID": user.uid // Optionally store the user ID
        ]

        db.collection("Events").addDocument(data: eventData) { error in
            if let error = error {
                print("Error adding event: \(error)")
            } else {
                print("Event added successfully!")
                self.clearFields() // Clear the text fields after successful submission
            }
        }
    }

    func clearFields() {
        eventNameTextField.text = ""
        eventDateTextField.text = ""
        organizerTextField.text = ""
        coOrganizerTextField.text = ""
        maxAttendeesTextField.text = ""
        descriptionTextView.text = ""
    }
}
