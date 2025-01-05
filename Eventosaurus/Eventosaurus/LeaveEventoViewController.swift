//
//  LeaveEventoViewController.swift
//  Eventosaurus
//
//  Created by BP-36-215-04 on 05/01/2025.
//

import UIKit
import FirebaseFirestore
class LeaveEventoViewController: UIViewController {


    @IBOutlet weak var EventName: UITextField!
    @IBOutlet weak var UserFullName: UITextField!
    
    let db = Firestore.firestore() // Create an instance of Firestore for database operations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup can be done here after the view has loaded
    }
    
    // Action triggered when the leave button is pressed
    @IBAction func leaveBtn(_ sender: Any) {
        withdrawFromEvent() // Call the method to handle user's withdrawal
    }
    
    // Method to handle user's withdrawal from an event
    func withdrawFromEvent() {
        guard let eventName = EventName.text, !eventName.isEmpty else {
            showAlert(message: "Please enter the event name.")
            return // Exit if the event name is empty
        }
        
        guard let fullName = UserFullName.text, !fullName.isEmpty else {
            showAlert(message: "Please enter your full name.")
            return // Exit if the full name is empty
        }

        // Query Firestore to find the event document by its name
        db.collection("Events").whereField("Event Name", isEqualTo: eventName).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return } // Ensure self is available
            
            if let error = error {
                print("Error fetching event document: \(error)")
                self.showAlert(message: "Failed to find event.")
                return
            }
            
            // Check if any documents were returned
            guard let documents = querySnapshot?.documents, let eventDocument = documents.first else {
                self.showAlert(message: "No event found with that name.")
                return
            }
            
            // Remove the user's full name from the participants field in the found event document
            eventDocument.reference.updateData([
                "participants": FieldValue.arrayRemove([fullName]) // Remove the user's full name from the participants array
            ]) { error in
                if let error = error {
                    print("Error updating event document: \(error)")
                    self.showAlert(message: "Failed to leave event.")
                } else {
                    // Show a success alert indicating the user left the event
                    self.showAlert(message: "User left event successfully!")
                }
            }
        }
    }

    // Function to show an alert with a given message
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(doneAction)
        present(alertController, animated: true, completion: nil)
    }
}
