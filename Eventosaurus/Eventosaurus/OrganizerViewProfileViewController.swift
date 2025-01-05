//
//  OrganizerViewProfileViewController.swift
//  Eventosaurus
//
//  Created by BP-36-215-01 on 05/01/2025.
//

import UIKit
import FirebaseFirestore

class OrganizerViewProfileViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var Followbtn: UIButton!
    
    @IBOutlet weak var aboutlbl: UILabel!
    
    
    var organizerName: String?
    var organizerID: String? // Organizer's Firestore document ID
    
    let db = Firestore.firestore()
    var currentUserID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userID = UserDefaults.standard.string(forKey: "currentUserID") {
            currentUserID = userID
        } else {
            print("No logged-in user found.")
            return
        }
        
        if let organizerName = organizerName {
            fetchOrganizerProfile(organizerName: organizerName)
        }
        
        // Gradient background setup
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let gradient = CAGradientLayer()
        
        // Define the gradient colors (purple to pink to orange to peach)withAlphaComponent(0.7).cgColor
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
    
    
    func fetchOrganizerProfile(organizerName: String) {
        db.collection("Users").whereField("Full Name", isEqualTo: organizerName).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching organizer profile: \(error)")
                return
            }
            
            if let document = snapshot?.documents.first, document.exists {
                let data = document.data()
                let fullName = data["Full Name"] as? String ?? "No name available"
                let interests = (data["Interest 1"] as? String ?? "") + " - " +
                (data["Interest 2"] as? String ?? "") + " - " +
                (data["Interest 3"] as? String ?? "") + " - " +
                (data["Interest 4"] as? String ?? "")
                let followersCount = data["followers"] as? Int ?? 0
                
                self.organizerID = document.documentID
                self.name.text = fullName
                self.aboutlbl.text = interests
                
                
            }
        }
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        guard let currentUserID = currentUserID else {
            print("Error: No logged-in user.")
            return
        }
        
        guard let organizerID = organizerID else { return }
        
        let userRef = db.collection("Users").document(currentUserID)
        let organizerRef = db.collection("Users").document(organizerID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                var following = document.data()?["following"] as? [String] ?? []
                
                if following.contains(organizerID) {
                    following.removeAll { $0 == organizerID }
                    userRef.updateData(["following": following]) { error in
                        if let error = error {
                            print("Error unfollowing: \(error)")
                        } else {
                            organizerRef.updateData(["followers": FieldValue.increment(Int64(-1))]) { error in
                                if let error = error {
                                    print("Error decreasing followers count: \(error)")
                                } else {
                                    //self.updateUI(isFollowing: false)
                                }
                            }
                        }
                    }
                } else {
                    following.append(organizerID)
                    userRef.setData(["following": following], merge: true) { error in
                        if let error = error {
                            print("Error following: \(error)")
                        } else {
                            organizerRef.updateData(["followers": FieldValue.increment(Int64(1))]) { error in
                                if let error = error {
                                    print("Error increasing followers count: \(error)")
                                } else {
                                   // self.updateUI(isFollowing: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
