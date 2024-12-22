//
//  UserInterestsViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-06 on 21/12/2024.
//

import UIKit
import FirebaseFirestore

class UserInterestsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    var picturesAndLabels: [(String, String)] = []  // This will hold the category name and system icon name.
    var db = Firestore.firestore()  // Firestore database reference
    var selectedIndexPaths: Set<IndexPath> = []  // Set to track selected indexPaths
    var selectedCategories: [String] = []  // Array to store selected category names
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initially disable the nextButton
        nextButton.isEnabled = false
        
        // Set the data source and delegate
        collectionView.dataSource = self
        collectionView.delegate = self  // Set delegate to handle cell selection

        // Allow multiple selection in the collection view
        collectionView.allowsMultipleSelection = true
        
        // Configure the flow layout
        let layout = UICollectionViewFlowLayout()

        // Define item size (adjust as needed)
        layout.itemSize = CGSize(width: 130, height: 135)  // Set cell size
        layout.minimumInteritemSpacing = 5 // Space between items horizontally
        layout.minimumLineSpacing = 15  // Space between rows vertically
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)  // Section padding

        // Apply the layout to the collection view
        collectionView.collectionViewLayout = layout

        // Fetch categories from Firestore
        fetchCategories()
    }
    
    // Fetch categories from Firestore
    func fetchCategories() {
        // Reference to your "Categories" collection
        db.collection("Categories").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                return
            }
            
            // Clear the existing data in the array
            self.picturesAndLabels.removeAll()
            
            // Iterate through each document in the collection
            for document in snapshot!.documents {
                // Get the category name and symbol from the document
                if let categoryName = document.data()["Category Name"] as? String,
                   let symbolName = document.data()["Symbol"] as? String {
                    // Append the category name and its corresponding symbol to the array
                    self.picturesAndLabels.append((categoryName, symbolName))
                }
            }
            
            // Reload the collection view with the new data
            self.collectionView.reloadData()
        }
    }

    // MARK: - UICollectionView Data Source
    
    // Number of items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesAndLabels.count
    }
    
    // Configuring each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue the reusable cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestsCategoriesCollectionViewCell", for: indexPath) as! InterestsCategoriesCollectionViewCell
        
        // Get the category data for the current indexPath
        let category = picturesAndLabels[indexPath.row]
        let categoryName = category.0
        let symbolName = category.1
        
        // Set the label text
        cell.InterestsLabel.text = categoryName
        cell.InterestsLabel.textColor = .purple
        
        // Set the image (use the SF Symbol corresponding to the category)
        cell.InterestsImage.image = UIImage(systemName: symbolName)
        
        cell.InterestsImage.contentMode = .scaleAspectFit
        cell.InterestsImage.tintColor = .purple
        cell.contentView.layer.cornerRadius = 15
        cell.contentView.clipsToBounds = true
        
        return cell
    }
    
    // MARK: - UICollectionView Delegate

    // This method is called when a cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // If 4 cells are already selected, don't allow selection of more
        if selectedIndexPaths.count >= 4 {
            // If the cell is not already selected, ignore the selection
            if !selectedIndexPaths.contains(indexPath) {
                return
            }
        }

        // Dequeue the selected cell
        let cell = collectionView.cellForItem(at: indexPath) as! InterestsCategoriesCollectionViewCell
        
        // Change the background color of the cell when selected
        cell.contentView.backgroundColor = .purple
        
        // Change the text color of the label when selected
        cell.InterestsLabel.textColor = .white
        
        // Change the image tint color when selected
        cell.InterestsImage.tintColor = .white

        // Track the selected cell
        selectedIndexPaths.insert(indexPath)
        
        // Add category name to selectedCategories array
        selectedCategories.append(picturesAndLabels[indexPath.row].0)
        
        // Enable the next button only if 4 cells are selected
        if selectedIndexPaths.count == 4 {
            nextButton.isEnabled = true
        }
    }
    
    // This method is called when a cell is deselected
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // Dequeue the deselected cell
        let cell = collectionView.cellForItem(at: indexPath) as! InterestsCategoriesCollectionViewCell
        
        // Reset the background color of the cell
        cell.contentView.backgroundColor = .clear
        
        // Reset the text color of the label
        cell.InterestsLabel.textColor = .purple
        
        // Reset the image tint color
        cell.InterestsImage.tintColor = .purple
        
        // Remove the deselected cell from the selected set
        selectedIndexPaths.remove(indexPath)
        
        // Remove the category name from the selectedCategories array
        selectedCategories.removeAll { $0 == picturesAndLabels[indexPath.row].0 }
        
        // Disable the next button if fewer than 4 cells are selected
        if selectedIndexPaths.count < 4 {
            nextButton.isEnabled = false
        }
    }
    
    // MARK: - Button Action
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        // Ensure that we have 4 categories selected
        guard selectedCategories.count == 4 else {
            return
        }
        
        // Fetch the "Users" collection and update the user's interests
        let userId = "currentUserId"  // Replace with the actual user ID (probably from Firebase Auth)
        
        // Fetch the "Categories" collection to get references to the categories
        var categoryReferences: [DocumentReference] = []
        
        // Loop through the selected categories and fetch the reference for each category
        for categoryName in selectedCategories {
            db.collection("Categories")
                .whereField("Category Name", isEqualTo: categoryName)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error fetching category reference: \(error.localizedDescription)")
                        return
                    }
                    
                    if let document = snapshot?.documents.first {
                        // Add the reference to the category
                        categoryReferences.append(document.reference)
                    }
                    
                    // Once all categories are fetched, update the user's interests
                    if categoryReferences.count == 4 {
                        self.updateUserInterests(userId: userId, categoryReferences: categoryReferences)
                    }
                }
        }
    }
    
    // Update the user's interests in Firestore
    func updateUserInterests(userId: String, categoryReferences: [DocumentReference]) {
        let userRef = db.collection("Users").document(userId)
        
        // Set the interests fields to the category references
        userRef.updateData([
            "Interest1": categoryReferences[0],
            "Interest2": categoryReferences[1],
            "Interest3": categoryReferences[2],
            "Interest4": categoryReferences[3]
        ]) { error in
            if let error = error {
                print("Error updating user interests: \(error.localizedDescription)")
            } else {
                print("User interests updated successfully!")
            }
        }
    }
}
