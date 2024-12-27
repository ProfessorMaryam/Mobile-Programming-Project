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
    
    var picturesAndLabels: [(String, String)] = []  // Will hold category names and system icon names.
    var db = Firestore.firestore()  // Firestore database reference
    var selectedIndexPaths: Set<IndexPath> = []  // To track selected indexPaths
    var selectedCategories: [String] = []  // Store the selected category names
    
    var userEmail: String?  // We'll use this to identify the user based on their email

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the next button initially
        nextButton.isEnabled = false
        
        // Set the data source and delegate for the collection view
        collectionView.dataSource = self
        collectionView.delegate = self

        // Allow multiple selection of items in the collection view
        collectionView.allowsMultipleSelection = true
        
        // Configure the collection view's layout
        configureCollectionViewLayout()

        // Fetch categories from Firestore
        fetchCategories()
    }

    // Configure collection view layout
    func configureCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 130, height: 135)  // Size of each item
        layout.minimumInteritemSpacing = 5  // Horizontal spacing between items
        layout.minimumLineSpacing = 15  // Vertical spacing between rows
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)  // Padding around the section
        collectionView.collectionViewLayout = layout
    }

    // Fetch categories from Firestore
    func fetchCategories() {
        db.collection("Categories").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                return
            }
            
            // Clear the existing data
            self.picturesAndLabels.removeAll()
            
            // Populate the data source array with category names and symbols
            for document in snapshot!.documents {
                if let categoryName = document.data()["Category Name"] as? String,
                   let symbolName = document.data()["Symbol"] as? String {
                    self.picturesAndLabels.append((categoryName, symbolName))
                }
            }
            
            // Reload collection view with fetched data
            self.collectionView.reloadData()
        }
    }

    // MARK: - UICollectionView Data Source

    // Number of items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesAndLabels.count
    }

    // Configure each cell in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestsCategoriesCollectionViewCell", for: indexPath) as! InterestsCategoriesCollectionViewCell
        
        let category = picturesAndLabels[indexPath.row]
        cell.InterestsLabel.text = category.0
        cell.InterestsLabel.textColor = .purple
        cell.InterestsImage.image = UIImage(systemName: category.1)
        cell.InterestsImage.contentMode = .scaleAspectFit
        cell.InterestsImage.tintColor = .purple
        cell.contentView.layer.cornerRadius = 15
        cell.contentView.clipsToBounds = true
        
        return cell
    }

    // MARK: - UICollectionView Delegate

    // Handle selection of items
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedIndexPaths.count < 4 else { return }  // Allow a maximum of 4 selections

        let cell = collectionView.cellForItem(at: indexPath) as! InterestsCategoriesCollectionViewCell
        cell.contentView.backgroundColor = .purple
        cell.InterestsLabel.textColor = .white
        cell.InterestsImage.tintColor = .white

        selectedIndexPaths.insert(indexPath)
        selectedCategories.append(picturesAndLabels[indexPath.row].0)

        // Enable the next button once 4 categories are selected
        if selectedIndexPaths.count == 4 {
            nextButton.isEnabled = true
        }
    }

    // Handle deselection of items
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InterestsCategoriesCollectionViewCell
        cell.contentView.backgroundColor = .clear
        cell.InterestsLabel.textColor = .purple
        cell.InterestsImage.tintColor = .purple

        selectedIndexPaths.remove(indexPath)
        selectedCategories.removeAll { $0 == picturesAndLabels[indexPath.row].0 }

        // Disable the next button if fewer than 4 categories are selected
        if selectedIndexPaths.count < 4 {
            nextButton.isEnabled = false
        }
    }

    // MARK: - Button Action

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard selectedCategories.count == 4 else { return }  // Ensure exactly 4 categories are selected
        
        guard let userEmail = userEmail else { return }  // Ensure user email is available
        
        var categoryReferences: [DocumentReference] = []
        
        // For each selected category, fetch its reference from Firestore
        for categoryName in selectedCategories {
            db.collection("Categories")
                .whereField("Category Name", isEqualTo: categoryName)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error fetching category reference: \(error.localizedDescription)")
                        return
                    }

                    if let document = snapshot?.documents.first {
                        categoryReferences.append(document.reference)
                    }

                    // Once all 4 categories are fetched, update the user's interests
                    if categoryReferences.count == 4 {
                        self.updateUserInterests(userEmail: userEmail, categoryReferences: categoryReferences)
                    }
                }
        }
    }

    // Update the user's interests in Firestore using category references
    func updateUserInterests(userEmail: String, categoryReferences: [DocumentReference]) {
        // Find the user document using their email
        db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }

            if let document = snapshot?.documents.first {
                // Update the user's interests with the category references
                document.reference.updateData([
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
            } else {
                print("User document not found.")
            }
        }
    }
}
