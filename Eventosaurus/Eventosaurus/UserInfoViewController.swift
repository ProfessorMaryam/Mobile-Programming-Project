//
//  UserInfoViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-20 on 24/12/2024.
//

import UIKit
import FirebaseFirestore

class UserInfoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var statusOption: [String] = ["Organizer", "Attendee"]
    
    @IBOutlet weak var status: UIPickerView!
    @IBOutlet weak var dateOfBirth: UIDatePicker!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var fullName: UITextField!

    // Define a property to hold the email passed from UsersDisplayController
    var userEmail: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the UIPickerView
        status.dataSource = self
        status.delegate = self
        
        // Optional: Set the initial selection
        status.selectRow(0, inComponent: 0, animated: false)
        
        // If the email is passed (non-nil), fetch the user's data
        if let email = userEmail {
            fetchUserData(email: email)
        }
    }

    // MARK: - Fetch user data from Firestore
    func fetchUserData(email: String) {
        let db = Firestore.firestore()
        
        // Query Firestore for the document with the matching email
        db.collection("Users").whereField("Email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot, let document = snapshot.documents.first else {
                print("User not found.")
                return
            }

            // Extract the user's data from the document
            if let fullName = document.get("Full Name") as? String,
               let email = document.get("Email") as? String,
               let dateOfBirth = document.get("Date of Birth") as? Timestamp {
                
                // Populate the UI with the fetched data
                self.fullName.text = fullName
                self.Email.text = email
                
                // Convert Firestore Timestamp to Date and set it in the UIDatePicker
                self.dateOfBirth.date = dateOfBirth.dateValue()
            }
        }
    }

    // MARK: - UIPickerViewDataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1  // Single column picker
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusOption.count
    }

    // MARK: - UIPickerViewDelegate Methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedStatus = statusOption[row]
        print("Selected Status: \(selectedStatus)")
    }
}
