//
//  UserProfileViewController.swift
//  Eventosaurus
//
//  Created by BP-36-215-01 on 05/01/2025.
//

import UIKit
import FirebaseFirestore


class UserProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    let gradient = CAGradientLayer()

    // Define the gradient colors (purple to pink to orange to peach)
    gradient.colors = [
    UIColor(red: 0.29, green: 0.00, blue: 0.51, alpha: 1.0).cgColor, // Purple
    UIColor(red: 0.87, green: 0.19, blue: 0.56, alpha: 1.0).cgColor, // Pink
    UIColor(red: 1.00, green: 0.49, blue: 0.31, alpha: 1.0).cgColor, // Orange
    UIColor(red: 1.00, green: 0.80, blue: 0.50, alpha: 1.0).cgColor // Peach
    ]
    gradient.locations = [0.0, 0.33, 0.66, 1.0] // Color stops
    gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.endPoint = CGPoint(x: 0.0, y: 1.0)

    // Set the frame dynamically
    gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)

    // Insert gradient as the background
    self.view.layer.insertSublayer(gradient, at: 0)
    }
    

}



class FollowingsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentUserID: String?
        var filteredFollowings: [String] = []  // Array to store organizer names
        let db = Firestore.firestore()

        override func viewDidLoad() {
            super.viewDidLoad()
            setupGradientBackground()
            
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.collectionViewLayout = UICollectionViewFlowLayout()
            
            // Fetch followings after checking the user ID
            fetchFollowings()
        }
        
        func fetchFollowings() {
            // Retrieve currentUserID from CurrentLoginUser singleton
            guard let currentUserID = CurrentLoginUser.shared.currentUserID else {
                print("No logged-in user.")
                return
            }
            
            self.currentUserID = currentUserID
            let userRef = db.collection("Users").document(currentUserID)
            
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    // Fetch the "Following" field (this should be an array of organizer IDs)
                    if let following = document.data()?["Following"] as? [String] {
                        // Now, fetch the names of the organizers
                        self.fetchOrganizerNames(from: following)
                    }
                } else {
                    print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        func fetchOrganizerNames(from following: [String]) {
            var organizerNames: [String] = []
            let dispatchGroup = DispatchGroup()
            
            for userID in following {
                dispatchGroup.enter()
                // Fetch the user (organizer) document using the userID (organizer ID)
                let organizerRef = db.collection("Users").document(userID)
                organizerRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let name = document.data()?["Full Name"] as? String {
                            organizerNames.append(name)
                        }
                    }
                    dispatchGroup.leave()
                }
            }
            
            // Once all organizer names have been fetched, update the UI
            dispatchGroup.notify(queue: .main) {
                self.filteredFollowings = organizerNames
                self.collectionView.reloadData() // Reload the collection view with the fetched names
            }
        }
        
        // Gradient background setup
        func setupGradientBackground() {
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor(red: 0.29, green: 0.00, blue: 0.51, alpha: 1.0).cgColor, // Purple
                UIColor(red: 0.87, green: 0.19, blue: 0.56, alpha: 1.0).cgColor, // Pink
                UIColor(red: 1.00, green: 0.49, blue: 0.31, alpha: 1.0).cgColor, // Orange
                UIColor(red: 1.00, green: 0.80, blue: 0.50, alpha: 1.0).cgColor // Peach
            ]
            gradient.locations = [0.0, 0.33, 0.66, 1.0] // Color stops
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
            
            gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.view.layer.insertSublayer(gradient, at: 0)
        }
    }

    extension FollowingsViewController: UICollectionViewDataSource {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredFollowings.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowCollectionViewCell", for: indexPath) as! FollowCollectionViewCell
            cell.setup(with: filteredFollowings[indexPath.row]) // Pass the filtered organizer name
            return cell
        }
    }

    extension FollowingsViewController: UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedOrganizerName = filteredFollowings[indexPath.row]
            print("Following: \(selectedOrganizerName)")
        }
    }

    // MARK: - UICollectionView Delegate Flow Layout Methods
    extension FollowingsViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 379, height: 100)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        }
    }

    class FollowCollectionViewCell: UICollectionViewCell {
        @IBOutlet weak var FollowImageView: UIImageView!
        @IBOutlet weak var titleLabel: UILabel!
        
        func setup(with organizerName: String) {
            FollowImageView.image = UIImage(named: "DinoProfile.jpeg") // Placeholder image
            titleLabel.text = organizerName  // Set the organizer name
        }
    }
