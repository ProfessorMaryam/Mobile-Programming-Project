//
//  InterestsDisplayPage.swift
//  Eventosaurus
//
//  Created by BP-36-201-15 on 14/12/2024.
//

import UIKit
import FirebaseFirestore

class InterestsDisplayPage: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var InterestTextField: UITextField!
    var picturesAndLabels: [(String, String)] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var SymbolTextField: UITextField!
    
    @IBAction func AddButtonTapped(_ sender: Any) {
        // Get the text input values from the text fields
        guard let categoryName = InterestTextField.text, !categoryName.isEmpty,
              let symbolName = SymbolTextField.text, !symbolName.isEmpty else {
            // Show an alert if one or both text fields are empty
            showAlert(title: "Invalid Input", message: "Please enter both category name and symbol.")
            return
        }
        
        // Reference to Firestore
        let db = Firestore.firestore()
        
        // Add the new category to the "Categories" collection
        db.collection("Categories").addDocument(data: [
            "Category Name": categoryName,
            "Symbol": symbolName // Save the symbol (e.g., SF Symbol name)
        ]) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to add category.")
            } else {
                // Successfully added, update the table view
                print("Document successfully added!")
                // Clear the text fields after adding the category
                self.InterestTextField.text = ""
                self.SymbolTextField.text = ""
                
                // Fetch the updated data from Firestore
                self.fetchDataFromFirebase()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the NIB file for the custom cell
        let nib = UINib(nibName: "AdminDisplaysInterestsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AdminDisplaysInterestsTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Fetch data from Firebase
        fetchDataFromFirebase()
    }
    
    func fetchDataFromFirebase() {
        // Reference to the Categories collection in Firestore
        let db = Firestore.firestore()
        db.collection("Categories").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }
            
            // Process each document in the "Categories" collection
            self.picturesAndLabels = snapshot?.documents.compactMap { document in
                // Get the category name and SF symbol from the document
                guard let categoryName = document.data()["Category Name"] as? String,
                      let sfSymbol = document.data()["Symbol"] as? String else {
                    return nil
                }
                return (categoryName, sfSymbol) // Create a tuple with category name and SF symbol
            } ?? []
            
            // Reload the table view with the fetched data
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return picturesAndLabels.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90 // Height for each cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdminDisplaysInterestsTableViewCell", for: indexPath) as? AdminDisplaysInterestsTableViewCell else {
                return UITableViewCell() // Return an empty cell if dequeuing fails
            }
            
            // Get the corresponding data for the current row
            let (categoryName, sfSymbol) = picturesAndLabels[indexPath.row]
            
            // Set the label text
            cell.InterestLabel.text = categoryName
            
            // Set the SF Symbol image
            cell.InterestImage.image = UIImage(systemName: sfSymbol)
            
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected category
        let selectedCategory = picturesAndLabels[indexPath.row]
        
        // Create an alert controller with options to Edit or Delete
        let alertController = UIAlertController(
            title: "Manage Category",
            message: "What would you like to do with '\(selectedCategory.0)'?",
            preferredStyle: .alert
        )
        
        // Add Edit option
        alertController.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            self.editCategory(at: indexPath)
        }))
        
        // Add Delete option
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteCategory(at: indexPath, from: tableView)
        }))
        
        // Add Cancel option
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
        
        // Deselect the row after the alert is presented
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func editCategory(at indexPath: IndexPath) {
        let selectedCategory = picturesAndLabels[indexPath.row]
        
        // Create an alert with text fields for editing
        let editAlert = UIAlertController(
            title: "Edit Category",
            message: "Update the category details.",
            preferredStyle: .alert
        )
        
        editAlert.addTextField { textField in
            textField.text = selectedCategory.0 // Current category name
            textField.placeholder = "Category Name"
        }
        editAlert.addTextField { textField in
            textField.text = selectedCategory.1 // Current symbol name
            textField.placeholder = "Symbol Name (SF Symbol)"
        }
        
        editAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            guard let newName = editAlert.textFields?[0].text,
                  let newSymbol = editAlert.textFields?[1].text,
                  !newName.isEmpty, !newSymbol.isEmpty else {
                self.showAlert(title: "Invalid Input", message: "Please provide valid inputs for both fields.")
                return
            }
            
            // Update the Firestore document
            let db = Firestore.firestore()
            db.collection("Categories")
                .whereField("Category Name", isEqualTo: selectedCategory.0)
                .whereField("Symbol", isEqualTo: selectedCategory.1)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error finding document to edit: \(error.localizedDescription)")
                        return
                    }
                    
                    if let document = snapshot?.documents.first {
                        document.reference.updateData([
                            "Category Name": newName,
                            "Symbol": newSymbol
                        ]) { error in
                            if let error = error {
                                print("Error updating document: \(error.localizedDescription)")
                                self.showAlert(title: "Error", message: "Failed to update category.")
                            } else {
                                print("Document successfully updated!")
                                // Update local data and reload table
                                self.picturesAndLabels[indexPath.row] = (newName, newSymbol)
                                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                            }
                        }
                    }
                }
        }))
        
        editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(editAlert, animated: true, completion: nil)
    }
    
    func deleteCategory(at indexPath: IndexPath, from tableView: UITableView) {
        let categoryToDelete = picturesAndLabels[indexPath.row]
        
        // Reference Firestore to find and delete the document
        let db = Firestore.firestore()
        db.collection("Categories")
            .whereField("Category Name", isEqualTo: categoryToDelete.0)
            .whereField("Symbol", isEqualTo: categoryToDelete.1)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error finding document to delete: \(error.localizedDescription)")
                    return
                }
                
                if let document = snapshot?.documents.first {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting document: \(error.localizedDescription)")
                            self.showAlert(title: "Error", message: "Failed to delete category.")
                        } else {
                            print("Document successfully deleted!")
                            // Update local data and reload table
                            self.picturesAndLabels.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
            }
    }

    // Function to show an alert when needed
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    // Swipe to delete functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the category to be deleted
            let categoryToDelete = picturesAndLabels[indexPath.row]
            
            // Reference to Firestore
            let db = Firestore.firestore()
            
            // Query Firestore to find the document that matches the category name and symbol
            db.collection("Categories")
                .whereField("Category Name", isEqualTo: categoryToDelete.0)
                .whereField("Symbol", isEqualTo: categoryToDelete.1)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error finding document to delete: \(error.localizedDescription)")
                        return
                    }
                    
                    // If the document exists, delete it
                    if let document = snapshot?.documents.first {
                        db.collection("Categories").document(document.documentID).delete { error in
                            if let error = error {
                                print("Error deleting document: \(error.localizedDescription)")
                                self.showAlert(title: "Error", message: "Failed to delete category.")
                            } else {
                                // Successfully deleted, update the table view
                                print("Document successfully deleted!")
                                self.picturesAndLabels.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: .automatic)
                            }
                        }
                    }
                }
        }
    }
}
