//
//  UserViewOrgViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed on 28/12/2024.
//

import UIKit
import Firebase

// Controller to display organizer's profile and manage follow/unfollow functionality
class UserViewOrgViewController: UIViewController {
    
    // Properties
    var organizerEmail: String = "" // Email of the organizer being viewed
    var isFollowing = false // Tracks if the current user is following the organizer
    let currentUserEmail = User.loggedInemail // Email of the logged-in user
    
    // UI Outlets
    @IBOutlet weak var usernametxt: UILabel! // Label to display the organizer's username
    @IBOutlet weak var following: UILabel! // Label to display the number of following
    @IBOutlet weak var followers: UILabel! // Label to display the number of followers
    @IBOutlet weak var descriptiontxt: UITextView! // TextView to display the organizer's brief description
    @IBOutlet weak var followBtn: UIButton! // Button to follow/unfollow the organizer
    
    // Lifecycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Organizer email: \(organizerEmail)") // Debug log to verify organizer email
        loadOrganizerData() // Load organizer's profile data
        checkFollowStatus() // Check if the user is already following the organizer
    }
    
    // Load organizer's profile data from Firestore
    func loadOrganizerData() {
        let db = Firestore.firestore()
        
        // Query the Users collection to get the organizer's data
        db.collection("Users")
            .whereField("Email", isEqualTo: organizerEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching organizer data: \(error)") // Handle query errors
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("No organizer found with this email") // Handle case where no data is found
                    return
                }
                
                let data = document.data()
                
                // Update the UI with the organizer's username
                if let username = data["Full Name"] as? String {
                    self.usernametxt.text = username
                }
                
                // Update the UI with the organizer's brief description
                if let brief = data["Brief"] as? String, !brief.isEmpty {
                    self.descriptiontxt.text = brief
                } else {
                    self.descriptiontxt.text = "No brief yet! Wait on it :)" // Placeholder text for empty description
                }
                
                // Update follower count
                self.updateFollowerCount()
            }
    }
    
    // Fetch and update the number of followers
    func updateFollowerCount() {
        let db = Firestore.firestore()
        
        // Query the Followers collection to count followers for the organizer
        db.collection("Followers")
            .whereField("user", isEqualTo: organizerEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching followers: \(error)") // Handle query errors
                    return
                }
                
                // Update the followers count in the UI
                let followerCount = snapshot?.documents.count ?? 0
                self.followers.text = "\(followerCount)"
            }
    }
    
    // Check if the current user is following the organizer
    func checkFollowStatus() {
        let db = Firestore.firestore()
        
        // Query the Followers collection to check if a relationship exists
        db.collection("Followers")
            .whereField("user", isEqualTo: organizerEmail)
            .whereField("follower", isEqualTo: currentUserEmail)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                // Update the follow status based on the query result
                self.isFollowing = !(snapshot?.documents.isEmpty ?? true)
                self.updateFollowButton() // Update the follow button title accordingly
            }
    }
    
    // Update the follow button's title based on the follow status
    func updateFollowButton() {
        if isFollowing {
            followBtn.setTitle("Unfollow", for: .normal) // Set to "Unfollow" if following
        } else {
            followBtn.setTitle("Follow", for: .normal) // Set to "Follow" if not following
        }
    }
    
    // Action for follow/unfollow button
    @IBAction func followButtonTapped(_ sender: UIButton) {
        let db = Firestore.firestore()
        
        if isFollowing {
            // Unfollow - delete the relationship from Firestore
            db.collection("Followers")
                .whereField("user", isEqualTo: organizerEmail)
                .whereField("follower", isEqualTo: currentUserEmail)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let document = snapshot?.documents.first {
                        document.reference.delete { error in
                            if error == nil {
                                // Update UI and state after successful unfollow
                                self.isFollowing = false
                                self.updateFollowButton()
                                self.updateFollowerCount()
                            }
                        }
                    }
                }
        } else {
            // Follow - add a new relationship to Firestore
            let followData: [String: Any] = [
                "user": organizerEmail, // The organizer being followed
                "follower": currentUserEmail // The current user following
            ]
            
            db.collection("Followers").addDocument(data: followData) { [weak self] error in
                guard let self = self else { return }
                
                if error == nil {
                    // Update UI and state after successful follow
                    self.isFollowing = true
                    self.updateFollowButton()
                    self.updateFollowerCount()
                }
            }
        }
    }
}
