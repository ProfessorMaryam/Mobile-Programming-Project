//
//  joinEventPageViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-15 on 10/12/2024.
//

import UIKit
import FirebaseFirestore

class joinEventPageViewController: UIViewController {
    
    @IBOutlet weak var EventName: UITextField! // Outlet for the event name text field
    @IBOutlet weak var FullName: UITextField! // Outlet for the full name text field
    let db = Firestore.firestore() // Create an instance of Firestore to interact with the database
    var eventID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup can be done here after the view has loaded
    }
    
    @IBAction func JoinEvent(_ sender: Any) {
        guard let eventName = EventName.text, !eventName.isEmpty else {
            showAlert(message: "Please enter the event name.")
            return // Exit if the event name is empty
        }
        
        guard let fullName = FullName.text, !fullName.isEmpty else {
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
            
            // Update the participants field in the found event document
            eventDocument.reference.updateData([
                "participants": FieldValue.arrayUnion([fullName]) // Add the user's full name to the participants array
            ]) { error in
                if let error = error {
                    print("Error updating event document: \(error)")
                    self.showAlert(message: "Failed to join event.")
                } else {
                    // Show a success alert indicating the user joined the event
                    self.showAlert(message: "User joined event successfully!")
                }
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        navigateToEventHome()
    }
    
    @IBAction func paybtn(_ sender: Any) {
        showAlert(message: "Paid successfully!")
    }
    func navigateToEventHome() {
        // Create an instance of EventHomeViewController from the storyboard
        let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
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

    // Function to show an alert with a given message
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(doneAction)
        present(alertController, animated: true, completion: nil)
    }
}
