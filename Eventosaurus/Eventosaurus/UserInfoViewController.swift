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
    
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var status: UIPickerView!
    @IBOutlet weak var dateOfBirth: UIDatePicker!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var fullName: UITextField!

    // Define a property to hold the email passed from UsersDisplayController
    var userEmail: String?
    
    // Keep track of the original data to detect changes
    var originalFullName: String?
    var originalEmail: String?
    var originalDateOfBirth: Date?
    var originalStatus: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the UIPickerView
        status.dataSource = self
        status.delegate = self
        
        // Optional: Set the initial selection
        status.selectRow(0, inComponent: 0, animated: false)
        
        // If the email is passed (non-nil), fetch the user's data
        if let email = userEmail {
            print("Email for fetching: \(email)") // Debug log
            fetchUserData(email: email)
        } else {
            print("Error: userEmail is nil.")
        }
        
        // Initially disable the Save button
        SaveButton.isEnabled = false
        
        // Add observers to detect text changes and enable Save button
        fullName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        Email.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        dateOfBirth.addTarget(self, action: #selector(datePickerDidChange), for: .valueChanged)
    }
    
    // MARK: - Detect Changes in Text Fields
    @objc func textFieldDidChange() {
        checkForChanges()
    }
    
    @objc func datePickerDidChange() {
        checkForChanges()
    }

    // Detect Picker View selection change
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        checkForChanges()
    }

    // Check if there are changes in any fields to enable the Save button
    func checkForChanges() {
        let isChanged = (fullName.text != originalFullName) ||
                        (Email.text != originalEmail) ||
                        (dateOfBirth.date != originalDateOfBirth) ||
                        (statusOption[status.selectedRow(inComponent: 0)] != originalStatus)
        
        SaveButton.isEnabled = isChanged
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
                print("User not found for email: \(email)")
                return
            }

            // Extract the user's data from the document
            let fullName = document.get("Full Name") as? String ?? ""
            let email = document.get("Email") as? String ?? ""
            let dateOfBirthTimestamp = document.get("Date Of Birth") as? Timestamp
            let isOrganizer = document.get("Is Organizer") as? Bool ?? false

            self.fullName.text = fullName
            self.Email.text = email

            // Set the Date of Birth in the UIDatePicker
            if let dateOfBirth = dateOfBirthTimestamp?.dateValue() {
                self.dateOfBirth.date = dateOfBirth
            } else {
                print("Date of Birth not found for user \(email)")
            }

            // Set the status in the UIPickerView based on the "Is Organizer" field
            if isOrganizer {
                // If "Is Organizer" is true, set the status to "Organizer"
                if let index = self.statusOption.firstIndex(of: "Organizer") {
                    self.status.selectRow(index, inComponent: 0, animated: true)
                }
            } else {
                // If "Is Organizer" is false, set the status to "Attendee"
                if let index = self.statusOption.firstIndex(of: "Attendee") {
                    self.status.selectRow(index, inComponent: 0, animated: true)
                }
            }

            // Store the original values to track changes
            self.originalFullName = fullName
            self.originalEmail = email
            self.originalDateOfBirth = self.dateOfBirth.date
            self.originalStatus = isOrganizer ? "Organizer" : "Attendee"
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

    // MARK: - Save Button Action
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Get the updated data from the text fields
        let updatedFullName = fullName.text ?? ""
        let updatedEmail = Email.text ?? ""
        let updatedDateOfBirth = dateOfBirth.date
        let updatedStatus = statusOption[status.selectedRow(inComponent: 0)]

        // Update Firestore with the new data
        updateUserData(fullName: updatedFullName, email: updatedEmail, dateOfBirth: updatedDateOfBirth, status: updatedStatus)

        // After saving, update the original values
        originalFullName = updatedFullName
        originalEmail = updatedEmail
        originalDateOfBirth = updatedDateOfBirth
        originalStatus = updatedStatus
        
        // Optionally, disable the Save button after saving
        SaveButton.isEnabled = false
    }

    // MARK: - Update User Data in Firestore
    func updateUserData(fullName: String, email: String, dateOfBirth: Date, status: String) {
        let db = Firestore.firestore()
        
        // Query Firestore for the document with the matching email
        db.collection("Users").whereField("Email", isEqualTo: email.lowercased()).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot, let document = snapshot.documents.first else {
                print("Error: User not found in Firestore.")
                return
            }

            // Update the user's data in Firestore
            document.reference.updateData([
                "Full Name": fullName,
                "Email": email,
                "Date Of Birth": dateOfBirth,
                "Is Organizer": status == "Organizer"
            ]) { error in
                if let error = error {
                    print("Error updating user: \(error.localizedDescription)")
                } else {
                    print("User data updated successfully.")
                }
            }
        }
    }
}












//import UIKit
//import FirebaseFirestore
//
//class UserInfoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
//
//    var statusOption: [String] = ["Organizer", "Attendee"]
//    
//    @IBOutlet weak var SaveButton: UIButton!
//    @IBOutlet weak var status: UIPickerView!
//    @IBOutlet weak var dateOfBirth: UIDatePicker!
//    @IBOutlet weak var Email: UITextField!
//    @IBOutlet weak var fullName: UITextField!
//
//    // Define a property to hold the email passed from UsersDisplayController
//    var userEmail: String?
//    
//    // Keep track of the original data to detect changes
//    var originalFullName: String?
//    var originalEmail: String?
//    var originalDateOfBirth: Date?
//    var originalStatus: String?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Set up the UIPickerView
//        status.dataSource = self
//        status.delegate = self
//        
//        // Optional: Set the initial selection
//        status.selectRow(0, inComponent: 0, animated: false)
//        
//        // If the email is passed (non-nil), fetch the user's data
//        if let email = userEmail {
//            print("Email for fetching: \(email)") // Debug log
//            fetchUserData(email: email)
//        } else {
//            print("Error: userEmail is nil.")
//        }
//        
//        // Initially disable the Save button
//        SaveButton.isEnabled = false
//        
//        // Add observers to detect text changes and enable Save button
//        fullName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
//        Email.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
//        dateOfBirth.addTarget(self, action: #selector(datePickerDidChange), for: .valueChanged)
//    }
//    
//    // MARK: - Detect Changes in Text Fields
//    @objc func textFieldDidChange() {
//        checkForChanges()
//    }
//    
//    @objc func datePickerDidChange() {
//        checkForChanges()
//    }
//
//    // Detect Picker View selection change
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        checkForChanges()
//        
//        // If the status changes from "Attendee" to "Organizer", delete from the "Requests" collection
//        if originalStatus == "Attendee" && statusOption[row] == "Organizer" {
//            deleteRequestIfExists()
//        }
//    }
//
//    // Check if there are changes in any fields to enable the Save button
//    func checkForChanges() {
//        let isChanged = (fullName.text != originalFullName) ||
//                        (Email.text != originalEmail) ||
//                        (dateOfBirth.date != originalDateOfBirth) ||
//                        (statusOption[status.selectedRow(inComponent: 0)] != originalStatus)
//        
//        SaveButton.isEnabled = isChanged
//    }
//
//    // MARK: - Fetch user data from Firestore
//    func fetchUserData(email: String) {
//        let db = Firestore.firestore()
//
//        // Query Firestore for the document with the matching email
//        db.collection("Users").whereField("Email", isEqualTo: email.lowercased()).getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error fetching user data: \(error.localizedDescription)")
//                return
//            }
//
//            guard let snapshot = snapshot, let document = snapshot.documents.first else {
//                print("User not found for email: \(email)")
//                return
//            }
//
//            // Extract the user's data from the document
//            let fullName = document.get("Full Name") as? String ?? "Unknown Name"
//            let email = document.get("Email") as? String ?? "No Email"
//            let dateOfBirthTimestamp = document.get("Date Of Birth") as? Timestamp
//            let isOrganizer = document.get("Is Organizer") as? Bool ?? false
//
//            self.fullName.text = fullName
//            self.Email.text = email
//
//            // Set the Date of Birth in the UIDatePicker
//            if let dateOfBirth = dateOfBirthTimestamp?.dateValue() {
//                self.dateOfBirth.date = dateOfBirth
//            } else {
//                print("Date of Birth not found for user \(email)")
//            }
//
//            // Set the status in the UIPickerView based on the "Is Organizer" field
//            if isOrganizer {
//                // If "Is Organizer" is true, set the status to "Organizer"
//                if let index = self.statusOption.firstIndex(of: "Organizer") {
//                    self.status.selectRow(index, inComponent: 0, animated: true)
//                }
//            } else {
//                // If "Is Organizer" is false, set the status to "Attendee"
//                if let index = self.statusOption.firstIndex(of: "Attendee") {
//                    self.status.selectRow(index, inComponent: 0, animated: true)
//                }
//            }
//
//            // Store the original values to track changes
//            self.originalFullName = fullName
//            self.originalEmail = email
//            self.originalDateOfBirth = self.dateOfBirth.date
//            self.originalStatus = isOrganizer ? "Organizer" : "Attendee"
//        }
//    }
//
//    // MARK: - UIPickerViewDataSource Methods
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1  // Single column picker
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return statusOption.count
//    }
//
//    // MARK: - UIPickerViewDelegate Methods
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return statusOption[row]
//    }
//
//    // MARK: - Save Button Action
//    @IBAction func saveButtonTapped(_ sender: UIButton) {
//        // Get the updated data from the text fields
//        let updatedFullName = fullName.text ?? ""
//        let updatedEmail = Email.text ?? ""
//        let updatedDateOfBirth = dateOfBirth.date
//        let updatedStatus = statusOption[status.selectedRow(inComponent: 0)]
//
//        // Update Firestore with the new data
//        updateUserData(fullName: updatedFullName, email: updatedEmail, dateOfBirth: updatedDateOfBirth, status: updatedStatus)
//
//        // After saving, update the original values
//        originalFullName = updatedFullName
//        originalEmail = updatedEmail
//        originalDateOfBirth = updatedDateOfBirth
//        originalStatus = updatedStatus
//        
//        // Optionally, disable the Save button after saving
//        SaveButton.isEnabled = false
//    }
//
//    // MARK: - Update User Data in Firestore
//    func updateUserData(fullName: String, email: String, dateOfBirth: Date, status: String) {
//        let db = Firestore.firestore()
//        
//        // Query Firestore for the document with the matching email
//        db.collection("Users").whereField("Email", isEqualTo: email.lowercased()).getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error updating user data: \(error.localizedDescription)")
//                return
//            }
//
//            guard let snapshot = snapshot, let document = snapshot.documents.first else {
//                print("Error: User not found in Firestore.")
//                return
//            }
//
//            // Update the user's data in Firestore
//            document.reference.updateData([
//                "Full Name": fullName,
//                "Email": email,
//                "Date Of Birth": dateOfBirth,
//                "Is Organizer": status == "Organizer"
//            ]) { error in
//                if let error = error {
//                    print("Error updating user: \(error.localizedDescription)")
//                } else {
//                    print("User data updated successfully.")
//                }
//            }
//        }
//    }
//
//    // MARK: - Delete Request from Firestore if Exists
//    func deleteRequestIfExists() {
//        guard let email = userEmail else {
//            print("User email is nil.")
//            return
//        }
//
//        let db = Firestore.firestore()
//        
//        // Check the "Requests" collection for a document with this email
//        db.collection("Requests").whereField("Email", isEqualTo: email.lowercased()).getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error checking Requests collection: \(error.localizedDescription)")
//                return
//            }
//
//            guard let snapshot = snapshot, !snapshot.isEmpty else {
//                print("No matching request found for email: \(email)")
//                return
//            }
//
//            // If found, delete the document
//            snapshot.documents.first?.reference.delete() { error in
//                if let error = error {
//                    print("Error deleting request: \(error.localizedDescription)")
//                } else {
//                    print("Request deleted successfully.")
//                }
//            }
//        }
//    }
//}
