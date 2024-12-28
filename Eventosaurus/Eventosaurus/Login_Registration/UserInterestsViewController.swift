//
//  UserInterestsViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-06 on 21/12/2024.
//

import UIKit
import FirebaseFirestore

class UserInterestsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    
    //Collection view outlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    var picturesAndLabels: [(String, String)] = []  //holds category names and system icon names. stored as a truple so that the SF symbol and the labels are associated with each other
    var db = Firestore.firestore()  // Firestore database reference thats accessible all throughout the class
    var selectedIndexPaths: Set<IndexPath> = []  // track selected indexPaths
    var selectedCategories: [String] = []  // stores the selected category names
    
    var userEmail: String?  // Identifies user by their email, passed from the previous view controller "Register"

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
        layout.itemSize = CGSize(width: 130, height: 135)  // size of each item / cell
        layout.minimumInteritemSpacing = 5  // Horizontal spacing between items
        layout.minimumLineSpacing = 15  // Vertical spacing between rows
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)  // Padding around the section
        collectionView.collectionViewLayout = layout //assigning the layout to the collectionView
    }

    // Fetch categories from Firestore
    func fetchCategories() {
        db.collection("Categories").getDocuments { (snapshot, error) in //Refers to the Categories Collection
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)") //handling Firebase error
                return
            }
            
            // Clear the existing data
            self.picturesAndLabels.removeAll()
            
            // Populate the data source array with category names and symbols
            for document in snapshot!.documents { //for every document that is inside the snapshot
                if let categoryName = document.data()["Category Name"] as? String, //casting field as string
                   let symbolName = document.data()["Symbol"] as? String { //casting field as string
                    self.picturesAndLabels.append((categoryName, symbolName)) //appending the
                }
            }
            
            // Reload collection view with fetched data
            self.collectionView.reloadData()
        }
    }


    // returns the number of elemented in the picturesAndLabels array
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesAndLabels.count
    }

    // Configure each cell in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestsCategoriesCollectionViewCell", for: indexPath) as! InterestsCategoriesCollectionViewCell  //stores the cell in the InterestsCategoriesCollectionViewCell as type class
        
        
        //the state on load
        let category = picturesAndLabels[indexPath.row]
        cell.InterestsLabel.text = category.0
        cell.InterestsLabel.textColor = .purple
        cell.InterestsImage.image = UIImage(systemName: category.1)
        cell.InterestsImage.contentMode = .scaleAspectFit
        cell.InterestsImage.tintColor = .purple
        cell.contentView.layer.cornerRadius = 15
        cell.contentView.clipsToBounds = true
        
        return cell //these cells are returned
    }


    // Handle selection of items
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedIndexPaths.count < 4 else { return }  // Allow a maximum of 4 selections

        let cell = collectionView.cellForItem(at: indexPath) as! InterestsCategoriesCollectionViewCell
        
        //change appearance of the cell when selected
        cell.contentView.backgroundColor = .purple
        cell.InterestsLabel.textColor = .white
        cell.InterestsImage.tintColor = .white

        selectedIndexPaths.insert(indexPath) //ensures that each item could only be selected once
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


//next button tapped action
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard selectedCategories.count == 4 else { return }  // Ensure exactly 4 categories are selected. if not then it returns
        
        guard let userEmail = userEmail else { return }  // Ensure user email is available. if not it returns
        
        var categoryReferences: [DocumentReference] = [] //created an array of firebase document references
        
        // For each selected category, fetch its reference from Firestore
        for categoryName in selectedCategories {
            db.collection("Categories")
                .whereField("Category Name", isEqualTo: categoryName)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error fetching category reference: \(error.localizedDescription)")
                        return
                    }

                    if let document = snapshot?.documents.first {//if the query is successful this line checks if there is at least one document in the snapshot
                        categoryReferences.append(document.reference) //appends the reference of each document in the snapshot
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
                // Update the user's interests with the category references, goes from 0-3 since the Interests are 1-4
                document.reference.updateData([
                    "Interest1": categoryReferences[0],
                    "Interest2": categoryReferences[1],
                    "Interest3": categoryReferences[2],
                    "Interest4": categoryReferences[3]
                ]) { error in
                    if let error = error {
                        print("Error updating user interests: \(error.localizedDescription)") //error handling
                    } else {
                        print("User interests updated successfully!") //sucessful
                        
                        
                        
                        let userStoryboard = UIStoryboard(name: "HomePage ", bundle: nil)
                        
                        if let userVC = userStoryboard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
                            // Set the modal presentation style to full screen since i am aware that the next view controller has no navigation controller embedded in it
                            userVC.modalPresentationStyle = .fullScreen
                            
                            // Present the view controller modally
                            self.present(userVC, animated: true, completion: nil)
                        } else {
                            //self.showAlert(title: "Error", message: "Unable to load User Page.")
                        }
                    }
                }
            } else {
                print("User document not found.")
            }
        }
    }
}
