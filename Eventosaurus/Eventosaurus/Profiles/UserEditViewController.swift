//
//  UserEditViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed on 25/12/2024.
//

import UIKit
import FirebaseFirestore

class UserEditViewController: UIViewController {
    
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData()
        // Do any additional setup after loading the view.
    }
    // Fetch the current user data from Firestore
    func loadUserData() {
        let userEmail = User.loggedInemail // Remove guard let since it's not optional
        
        // Fetch the user document from Firestore using email
        db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, let document = documents.first else {
                print("User document does not exist.")
                return
            }
            
            // Populate the UI with the user data
            self.usernameTextField.text = document.get("Full Name") as? String ?? ""
            self.emailTextField.text = document.get("Email") as? String ?? ""
            self.BriefTextField.text = document.get("Brief") as? String ?? ""
        }
    }
    
    // Update the user data in Firestore
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let userEmail = User.loggedInemail // Remove guard let since it's not optional
        
        // Get updated data from the text fields
        let updatedUsername = usernameTextField.text ?? ""
        let updatedEmail = emailTextField.text ?? ""
        let updatedBrief = BriefTextField.text ?? ""
        
        // First query to find the document with matching email
        db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { snapshot, error in
            if let error = error {
                print("Error finding user document: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, let document = documents.first else {
                print("User document not found")
                return
            }
            
            // Update the Firestore document
            document.reference.updateData([
                "Full Name": updatedUsername,
                "Email": updatedEmail,
                "Brief": updatedBrief
            ]) { error in
                if let error = error {
                    print("Error updating user data: \(error.localizedDescription)")
                } else {
                    print("User data updated successfully!")
                    self.showSuccessAlert()
                }
            }
        }
    }
    
    // Show a success alert
    func showSuccessAlert() {
        let alertController = UIAlertController(title: "Success", message: "Your profile has been updated.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var BriefTextField: UITextView!
    @IBOutlet weak var usernameTextField: UITextField!
}
