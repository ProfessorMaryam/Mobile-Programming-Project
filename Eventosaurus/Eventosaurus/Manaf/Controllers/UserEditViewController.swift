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
            guard let userID = CurrentUser.shared.userID else {
                print("Error: User ID not set.")
                return
            }
            
            // Fetch the user document from Firestore
            db.collection("Users").document(userID).getDocument { document, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, document.exists {
                    // Populate the UI with the user data
                    self.usernameTextField.text = document.get("Full Name") as? String ?? ""
                    self.emailTextField.text = document.get("Email") as? String ?? ""
                    self.BriefTextField.text = document.get("Brief") as? String ?? ""
                } else {
                    print("User document does not exist.")
                }
            }
        }
        
        // Update the user data in Firestore
        @IBAction func saveButtonTapped(_ sender: UIButton) {
            guard let userID = CurrentUser.shared.userID else {
                print("Error: User ID not set.")
                return
            }
            
            // Get updated data from the text fields
            let updatedUsername = usernameTextField.text ?? ""
            let updatedEmail = emailTextField.text ?? ""
            let updatedBrief = BriefTextField.text ?? ""
            
            // Update the Firestore document
            db.collection("Users").document(userID).updateData([
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
        
        // Show a success alert
        func showSuccessAlert() {
            let alertController = UIAlertController(title: "Success", message: "Your profile has been updated.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var BriefTextField: UITextView!
 
    @IBOutlet weak var usernameTextField: UITextField!
}
