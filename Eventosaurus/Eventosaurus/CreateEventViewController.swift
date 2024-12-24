//
//  CreateEventViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-15 on 10/12/2024.
//

import UIKit
import FirebaseFirestore
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

        // Do any additional setup after loading the view.
    }
    

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        createEvent()
    }
    
    
    
    func createEvent() {
            guard let eventName = eventNameTextField.text,
                  let eventDate = eventDateTextField.text,
                  let organizer1 = organizerTextField.text,
                  let organizer2 = coOrganizerTextField.text,
                  let maxAttendeesString = maxAttendeesTextField.text,
                  let maxAttendees = Int(maxAttendeesString),
                  let description = descriptionTextView.text, !description.isEmpty else {
                // Handle the case where text fields are empty or invalid
                print("Please fill in all fields correctly.")
                return
            }

            let eventData: [String: Any] = [
                "Event Name": eventName,
                "Date": eventDate,
                "Organizer1": organizer1,
                "Organizer2": organizer2,
                "Maximum Attendees": maxAttendees,
                "Description": description
            ]

            db.collection("Events").addDocument(data: eventData) { error in
                if let error = error {
                    print("Error adding Event: \(error)")
                } else {
                    print("Event added successfully!")
                    // Optionally, clear the text fields or navigate to another screen
                    self.clearFields()
                }
            }
        }

        func clearFields() {
            eventNameTextField.text = ""
            eventDateTextField.text = ""
            organizerTextField.text = ""
            coOrganizerTextField.text = ""
            maxAttendeesTextField.text = ""
            descriptionTextView.text = "" // Clear the UITextView
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
