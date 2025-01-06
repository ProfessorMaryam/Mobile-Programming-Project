//
//  UserEditViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed on 25/12/2024.
//

import UIKit
import FirebaseFirestore

// View controller for editing user profile details
class UserEditViewController: UIViewController {
    
    let db = Firestore.firestore() // Firestore reference for database operations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData() // Load current user data when the view loads
        // Do any additional setup after loading the view.
    }
    
    // Fetch the current user data from Firestore
    func loadUserData() {
        let userEmail = User.loggedInemail // Logged-in user's email (non-optional)
        
        // Query the Users collection in Firestore using the user's email
        db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)") // Handle query errors
                return
            }
            
            // Ensure the query returns at least one document
            guard let documents = snapshot?.documents, let document = documents.first else {
                print("User document does not exist.") // Handle case where no data is found
                return
            }
            
            // Populate the UI with the fetched user data
            self.usernameTextField.text = document.get("Full Name") as? String ?? "" // User's full name
            self.emailTextField.text = document.get("Email") as? String ?? "" // User's email
            self.BriefTextField.text = document.get("Brief") as? String ?? "" // User's brief description
        }
    }
    
    // Action triggered when the save button is tapped
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let userEmail = User.loggedInemail // Logged-in user's email (non-optional)
        
        // Get updated data from the UI elements
        let updatedUsername = usernameTextField.text ?? "" // Updated full name
        let updatedEmail = emailTextField.text ?? "" // Updated email
        let updatedBrief = BriefTextField.text ?? "" // Updated brief description
        
        // Query Firestore to find the user's document by email
        db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { snapshot, error in
            if let error = error {
                print("Error finding user document: \(error.localizedDescription)") // Handle query errors
                return
            }
            
            // Ensure the query returns at least one document
            guard let documents = snapshot?.documents, let document = documents.first else {
                print("User document not found") // Handle case where no document is found
                return
            }
            
            // Update the user's data in Firestore
            document.reference.updateData([
                "Full Name": updatedUsername, // Updated full name
                "Email": updatedEmail, // Updated email
                "Brief": updatedBrief // Updated brief description
            ]) { error in
                if let error = error {
                    print("Error updating user data: \(error.localizedDescription)") // Handle update errors
                } else {
                    print("User data updated successfully!") // Log success
                    self.showSuccessAlert() // Show success alert to the user
                }
            }
        }
    }
    
    // Show a success alert to the user
    func showSuccessAlert() {
        let alertController = UIAlertController(
            title: "Success",
            message: "Your profile has been updated.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil)) // Add an OK button
        self.present(alertController, animated: true, completion: nil) // Present the alert
    }
    
    // Outlets for UI elements
    @IBOutlet weak var emailTextField: UITextField! // TextField for the user's email
    @IBOutlet weak var BriefTextField: UITextView! // TextView for the user's brief description
    @IBOutlet weak var usernameTextField: UITextField! // TextField for the user's full name
}
