//
//  UserViewOrgViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed on 28/12/2024.
//

import UIKit
import Firebase
class UserViewOrgViewController: UIViewController {
    var organizerEmail: String = ""
    var isFollowing = false
    let currentUserEmail = User.loggedInemail
    
    @IBOutlet weak var usernametxt: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var descriptiontxt: UITextView!
    @IBOutlet weak var followBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Organizer email: \(organizerEmail)")
        loadOrganizerData()
        checkFollowStatus()
    }
    
    func loadOrganizerData() {
        let db = Firestore.firestore()
        
        db.collection("Users")
            .whereField("Email", isEqualTo: organizerEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching organizer data: \(error)")
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("No organizer found with this email")
                    return
                }
                
                let data = document.data()
                
                // Update username
                if let username = data["Full Name"] as? String {
                    self.usernametxt.text = username
                }
                
                // Update brief/description
                if let brief = data["Brief"] as? String, !brief.isEmpty {
                    self.descriptiontxt.text = brief
                } else {
                    self.descriptiontxt.text = "No brief yet! Wait on it :)"
                }
                
                // Count followers
                self.updateFollowerCount()
            }
    }
    
    func updateFollowerCount() {
        let db = Firestore.firestore()
        db.collection("Followers")
            .whereField("user", isEqualTo: organizerEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching followers: \(error)")
                    return
                }
                
                let followerCount = snapshot?.documents.count ?? 0
                self.followers.text = "\(followerCount)"
            }
    }
    
    func checkFollowStatus() {
        let db = Firestore.firestore()
        db.collection("Followers")
            .whereField("user", isEqualTo: organizerEmail)
            .whereField("follower", isEqualTo: currentUserEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isFollowing = !(snapshot?.documents.isEmpty ?? true)
                self.updateFollowButton()
            }
    }
    
    func updateFollowButton() {
        if isFollowing {
            followBtn.setTitle("Unfollow", for: .normal)
        } else {
            followBtn.setTitle("Follow", for: .normal)
        }
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        let db = Firestore.firestore()
        
        if isFollowing {
            // Unfollow - delete the document
            db.collection("Followers")
                .whereField("user", isEqualTo: organizerEmail)
                .whereField("follower", isEqualTo: currentUserEmail)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let document = snapshot?.documents.first {
                        document.reference.delete { error in
                            if error == nil {
                                self.isFollowing = false
                                self.updateFollowButton()
                                self.updateFollowerCount()
                            }
                        }
                    }
                }
        } else {
            // Follow - create new document
            let followData: [String: Any] = [
                "user": organizerEmail,
                "follower": currentUserEmail
            ]
            
            db.collection("Followers").addDocument(data: followData) { [weak self] error in
                guard let self = self else { return }
                
                if error == nil {
                    self.isFollowing = true
                    self.updateFollowButton()
                    self.updateFollowerCount()
                }
            }
        }
    }
}
