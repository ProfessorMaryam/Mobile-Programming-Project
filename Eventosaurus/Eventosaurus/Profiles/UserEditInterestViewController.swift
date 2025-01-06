//
//  UserEditInterestViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed on 05/01/2025.
//

import UIKit
import Firebase

// View controller to allow users to select and update their interests
class UserEditInterestViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - UI Outlets
    @IBOutlet weak var collectionView: UICollectionView! // Collection view to display categories
    @IBOutlet weak var nextButton: UIButton! // Button to proceed after selecting interests
    
    // MARK: - Properties
    var picturesAndLabels: [(String, String)] = [] // Array to hold category names and their corresponding SF Symbols
    var db = Firestore.firestore() // Firestore database reference
    var selectedIndexPaths: Set<IndexPath> = [] // Tracks selected index paths in the collection view
    var selectedCategories: [String] = [] // Stores names of selected categories
    var userInterests: [DocumentReference] = [] // Holds user's current interest document references
    var userEmail: String? // Email of the logged-in user to identify their data
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial UI setup
        nextButton.isEnabled = false // Disable the button until enough selections are made
        collectionView.dataSource = self // Set data source
        collectionView.delegate = self // Set delegate
        collectionView.allowsMultipleSelection = true // Enable multi-selection in the collection view
        configureCollectionViewLayout() // Configure the layout of the collection view
        
        // Fetch categories and the user's existing interests
        fetchCategories()
        fetchUserInterests()
    }
    
    // MARK: - Collection View Layout Configuration
    func configureCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 130, height: 135) // Set the size of each collection view cell
        layout.minimumInteritemSpacing = 5 // Set horizontal spacing between items
        layout.minimumLineSpacing = 15 // Set vertical spacing between rows
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Add padding around the section
        collectionView.collectionViewLayout = layout // Apply the layout to the collection view
    }
    
    // MARK: - Fetch Categories
    // Fetch all available categories from Firestore
    func fetchCategories() {
        db.collection("Categories").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)") // Log error if fetching fails
                return
            }
            
            // Clear any existing data
            self.picturesAndLabels.removeAll()
            
            // Populate the array with category names and their symbols
            for document in snapshot!.documents {
                if let categoryName = document.data()["Category Name"] as? String,
                   let symbolName = document.data()["Symbol"] as? String {
                    self.picturesAndLabels.append((categoryName, symbolName))
                }
            }
            
            // Reload the collection view to display the fetched data
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesAndLabels.count // Return the number of categories
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestsCategoriesCollectionViewCell", for: indexPath) as! InterestsCategoriesCollectionViewCell
        
        let category = picturesAndLabels[indexPath.row]
        cell.InterestsLabel.text = category.0 // Set the category name
        cell.InterestsLabel.textColor = .purple // Set label color
        cell.InterestsImage.image = UIImage(systemName: category.1) // Set category icon
        cell.InterestsImage.contentMode = .scaleAspectFit // Set image scaling
        cell.InterestsImage.tintColor = .purple // Set icon color
        cell.contentView.layer.cornerRadius = 15 // Round cell corners
        cell.contentView.clipsToBounds = true // Clip content to bounds
        
        return cell
    }
    
    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedIndexPaths.count < 4 else { return } // Limit selections to 4
        
        let cell = collectionView.cellForItem(at: indexPath) as! InterestsCategoriesCollectionViewCell
        cell.contentView.backgroundColor = .purple // Highlight the selected cell
        cell.InterestsLabel.textColor = .white // Change label color
        cell.InterestsImage.tintColor = .white // Change icon color
        
        selectedIndexPaths.insert(indexPath) // Track the selected index path
        selectedCategories.append(picturesAndLabels[indexPath.row].0) // Add the selected category name
        
        // Enable the next button when 4 categories are selected
        if selectedIndexPaths.count == 4 {
            nextButton.isEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InterestsCategoriesCollectionViewCell
        cell.contentView.backgroundColor = .clear // Clear the highlight
        cell.InterestsLabel.textColor = .purple // Reset label color
        cell.InterestsImage.tintColor = .purple // Reset icon color
        
        selectedIndexPaths.remove(indexPath) // Remove deselected index path
        selectedCategories.removeAll { $0 == picturesAndLabels[indexPath.row].0 } // Remove deselected category name
        
        // Disable the next button if fewer than 4 categories are selected
        if selectedIndexPaths.count < 4 {
            nextButton.isEnabled = false
        }
    }
    
    // MARK: - Button Action
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard selectedCategories.count == 4 else { return } // Ensure 4 categories are selected
        
        let userEmail = User.loggedInemail // Get the logged-in user's email
        var categoryReferences: [DocumentReference] = [] // Array to hold references to selected categories
        
        let group = DispatchGroup() // Dispatch group to synchronize multiple Firestore queries
        
        // For each selected category, fetch its document reference
        for categoryName in selectedCategories {
            group.enter()
            db.collection("Categories")
                .whereField("Category Name", isEqualTo: categoryName)
                .getDocuments { (snapshot, error) in
                    defer { group.leave() } // Notify the group when the query completes
                    
                    if let document = snapshot?.documents.first {
                        categoryReferences.append(document.reference) // Add the reference to the array
                    }
                }
        }
        
        // Once all references are fetched, update the user's interests
        group.notify(queue: .main) {
            self.updateUserInterests(userEmail: userEmail, categoryReferences: categoryReferences)
        }
    }
    
    // MARK: - Fetch User Interests
    func fetchUserInterests() {
        let userEmail = User.loggedInemail // Get the logged-in user's email
        
        db.collection("Users")
            .whereField("Email", isEqualTo: userEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let document = snapshot?.documents.first else { return }
                
                // Retrieve user's interests and store them as document references
                if let interest1 = document.get("Interest1") as? DocumentReference {
                    self.userInterests.append(interest1)
                }
                if let interest2 = document.get("Interest2") as? DocumentReference {
                    self.userInterests.append(interest2)
                }
                if let interest3 = document.get("Interest3") as? DocumentReference {
                    self.userInterests.append(interest3)
                }
                if let interest4 = document.get("Interest4") as? DocumentReference {
                    self.userInterests.append(interest4)
                }
                
                // Pre-select user's existing interests in the collection view
                for interestRef in self.userInterests {
                    interestRef.getDocument { (document, error) in
                        if let categoryName = document?.get("Category Name") as? String,
                           let categoryIndex = self.picturesAndLabels.firstIndex(where: { $0.0 == categoryName }) {
                            let indexPath = IndexPath(item: categoryIndex, section: 0)
                            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                            self.selectedIndexPaths.insert(indexPath)
                            self.selectedCategories.append(categoryName)
                            
                            // Highlight the pre-selected cell
                            if let cell = self.collectionView.cellForItem(at: indexPath) as? InterestsCategoriesCollectionViewCell {
                                cell.contentView.backgroundColor = .purple
                                cell.InterestsLabel.textColor = .white
                                cell.InterestsImage.tintColor = .white
                            }
                        }
                    }
                }
            }
    }
    
    // MARK: - Update User Interests
    func updateUserInterests(userEmail: String, categoryReferences: [DocumentReference]) {
        db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)") // Log error
                return
            }
            
            if let document = snapshot?.documents.first {
                // Update the user's interests in Firestore
                document.reference.updateData([
                    "Interest1": categoryReferences[0],
                    "Interest2": categoryReferences[1],
                    "Interest3": categoryReferences[2],
                    "Interest4": categoryReferences[3]
                ]) { error in
                    if let error = error {
                        print("Error updating user interests: \(error.localizedDescription)") // Log update error
                        // Show error alert
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error",
                                                          message: "Failed to update interests. Please try again.",
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    } else {
                        print("User interests updated successfully!") // Log success
                        // Show success alert
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Success",
                                                          message: "Your interests have been updated!",
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            } else {
                print("User document not found.") // Log user not found
                // Show error alert for missing user
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error",
                                                  message: "User not found. Please try again.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
