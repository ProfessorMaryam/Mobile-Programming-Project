//
//  joinEventPageViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-15 on 10/12/2024.
//

import UIKit
import FirebaseFirestore

class joinEventPageViewController: UIViewController {
    
    // Create an instance of Firestore to interact with the database
    let db = Firestore.firestore()
    
    // Property to hold the event ID for the event the user wants to join
    var eventID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup can be done here after the view has loaded
    }
    
    // Action triggered when the payment button is pressed
    @IBAction func payBtn(_ sender: UIButton) {
        // Check if the event ID is not nil
        guard let eventID = eventID else {
            return // Exit if the event ID is missing
        }
        
        // Assuming a default user ID for demonstration purposes
        let userID = "default-user-id" // Replace this with actual user identification logic
        let userRef = db.collection("Users").document(userID)
        
        // Update the user's document to add the event they are joining
        userRef.updateData([
            "joinedEvents": FieldValue.arrayUnion([eventID]) // Use arrayUnion to add eventID to joinedEvents array
        ]) { _ in
            // Show a simple alert indicating the user joined the event
            let alertController = UIAlertController(title: "Success", message: "User Joined Event Successfully!", preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(doneAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        navigateToEventHome()
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
}
