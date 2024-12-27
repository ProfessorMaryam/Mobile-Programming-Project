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

    // Outlets for the text fields and text view in the storyboard
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var organizerTextField: UITextField!
    @IBOutlet weak var coOrganizerTextField: UITextField!
    @IBOutlet weak var maxAttendeesTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!

    // Reference to Firestore database
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup if needed (e.g., initializing UI elements)
    }

    // Action triggered when the submit button is tapped
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        createEvent() // Call the function to create an event
    }

    // Function to create a new event in Firestore
    func createEvent() {
        // Validate user input to ensure no fields are empty
        guard let eventName = eventNameTextField.text, !eventName.isEmpty,
              let eventDate = eventDateTextField.text, !eventDate.isEmpty,
              let organizer1 = organizerTextField.text, !organizer1.isEmpty,
              let organizer2 = coOrganizerTextField.text, !organizer2.isEmpty,
              let maxAttendeesString = maxAttendeesTextField.text, let maxAttendees = Int(maxAttendeesString),
              let description = descriptionTextView.text, !description.isEmpty else {
            print("Please fill in all fields correctly.")
            return // Exit the function if validation fails
        }

        // Check if the user is authenticated before proceeding
        guard let user = Auth.auth().currentUser else {
            print("User is not authenticated.")
            return // Exit the function if the user is not logged in
        }

        // Create a dictionary to hold event data
        let eventData: [String: Any] = [
            "Event Name": eventName,
            "Date": eventDate,
            "Organizer1": organizer1,
            "Organizer2": organizer2,
            "Maximum Attendees": maxAttendees,
            "Description": description,
            "UserID": user.uid // Optionally store the user ID for reference
        ]

        // Add the event data to the "Events" collection in Firestore
        db.collection("Events").addDocument(data: eventData) { error in
            if let error = error {
                print("Error adding event: \(error)") // Print error message if the operation fails
            } else {
                print("Event added successfully!") // Confirm successful addition
                self.clearFields() // Clear the text fields after successful submission
            }
        }
    }

    // Function to clear all input fields in the form
    func clearFields() {
        eventNameTextField.text = ""
        eventDateTextField.text = ""
        organizerTextField.text = ""
        coOrganizerTextField.text = ""
        maxAttendeesTextField.text = ""
        descriptionTextView.text = ""
    }
}
