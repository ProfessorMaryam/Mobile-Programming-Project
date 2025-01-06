//
//  OrganizerEditViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed on 05/01/2025.
//

import UIKit
import Firebase

// View controller for editing organizer's profile
class OrganizerEditViewController: UIViewController {
   
   // Firestore database reference
   let db = Firestore.firestore()
   
   // MARK: - UI Outlets
   @IBOutlet weak var saveBtn: UIButton! // Button to save profile changes
   @IBOutlet weak var brieftxt: UITextField! // TextField for the organizer's brief description
   @IBOutlet weak var emailtxt: UITextField! // TextField for the organizer's email
   @IBOutlet weak var usernametxt: UITextField! // TextField for the organizer's full name
   
   // MARK: - Lifecycle Methods
   override func viewDidLoad() {
       super.viewDidLoad()
       loadUserData() // Load the organizer's data when the view loads
   }
   
   // MARK: - Load Organizer Data
   // Fetch the organizer's data from Firestore and populate the UI
   func loadUserData() {
       let userEmail = User.loggedInemail // Get the logged-in organizer's email
       
       // Query the Users collection for the organizer's document
       db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { [weak self] snapshot, error in
           if let error = error {
               print("Error fetching user data: \(error.localizedDescription)") // Log the error
               return
           }
           
           // Ensure the document exists
           guard let documents = snapshot?.documents,
                 let document = documents.first else {
               print("User document not found") // Log if no document is found
               return
           }
           
           // Get user data fields
           let fullName = document.get("Full Name") as? String ?? "" // Organizer's full name
           let email = document.get("Email") as? String ?? "" // Organizer's email
           let brief = document.get("Brief") as? String ?? "" // Organizer's brief description
           
           // Update the UI with the fetched data on the main thread
           DispatchQueue.main.async {
               self?.usernametxt.text = fullName
               self?.emailtxt.text = email
               self?.brieftxt.text = brief
           }
       }
   }
   
   // MARK: - Save Button Action
   // Save changes to the organizer's profile
   @IBAction func saveButtonTapped(_ sender: UIButton) {
       // Validate that the username and email fields are not empty
       guard let username = usernametxt.text, !username.isEmpty,
             let email = emailtxt.text, !email.isEmpty else {
           showAlert(title: "Error", message: "Username and email cannot be empty")
           return
       }
       
       let brief = brieftxt.text ?? "" // Get the brief description (can be empty)
       let userEmail = User.loggedInemail // Get the logged-in organizer's email
       
       // Query the Users collection for the organizer's document
       db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { [weak self] snapshot, error in
           if let error = error {
               print("Error fetching user document: \(error.localizedDescription)") // Log the error
               self?.showAlert(title: "Error", message: "Failed to update profile. Please try again.")
               return
           }
           
           // Ensure the document exists
           guard let document = snapshot?.documents.first else {
               print("User document not found") // Log if no document is found
               self?.showAlert(title: "Error", message: "User not found")
               return
           }
           
           // Update the user data in Firestore
           document.reference.updateData([
               "Full Name": username, // Updated full name
               "Email": email, // Updated email
               "Brief": brief // Updated brief description
           ]) { error in
               if let error = error {
                   print("Error updating user data: \(error.localizedDescription)") // Log update error
                   self?.showAlert(title: "Error", message: "Failed to update profile. Please try again.")
               } else {
                   print("Profile updated successfully!") // Log success
                   self?.showAlert(title: "Success", message: "Profile updated successfully!") // Show success alert
               }
           }
       }
   }
   
   // MARK: - Helper Methods
   // Show an alert with a given title and message
   func showAlert(title: String, message: String) {
       let alert = UIAlertController(title: title, // Alert title
                                   message: message, // Alert message
                                   preferredStyle: .alert) // Alert style
       alert.addAction(UIAlertAction(title: "OK", style: .default)) // Add an OK button
       DispatchQueue.main.async {
           self.present(alert, animated: true) // Present the alert on the main thread
       }
   }
}
