//
//  LeaveEventPageViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-15 on 10/12/2024.
//

import UIKit
import FirebaseFirestore

class LeaveEventPageViewController: UIViewController {

    // Create an instance of Firestore for database operations
    let db = Firestore.firestore()
    
    // Property to hold the event ID for the event the user wants to leave
    var eventID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup can be done here after the view has loaded
    }
    
    // Action triggered when the leave button is pressed
    @IBAction func leaveBtn(_ sender: UIButton) {
        // Confirm withdrawal
        withdrawFromEvent()
    }
    
    // Method to handle user's withdrawal from an event
    func withdrawFromEvent() {
        // Ensure the event ID is valid
        guard let eventID = eventID else {
            return // Exit if the event ID is missing
        }

        // Reference to the user's document in Firestore
        // Note: You will need to determine how users are identified
        let userID = "default-user-id" // Replace this with actual user identification logic
        let userRef = db.collection("Users").document(userID)
        
        // Update the user's document to remove the event they are leaving
        userRef.updateData([
            "joinedEvents": FieldValue.arrayRemove([eventID]) // Use arrayRemove to remove eventID from joinedEvents array
        ]) { _ in
            // Show a simple alert indicating the user left the event
            let alertController = UIAlertController(title: "Event Left", message: "User left event!", preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(doneAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
