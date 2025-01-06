//
//  OrganizerViewProfileViewController.swift
//  Eventosaurus
//
//  Created by BP-36-215-01 on 05/01/2025.
//

import UIKit
import FirebaseFirestore




class OrganizerViewProfileViewController: UIViewController {
    
    
    @IBOutlet weak var NumOfFollowers: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var Followbtn: UIButton!
    @IBOutlet weak var aboutlbl: UILabel!
    
    var organizerName: String?
       var organizerID: String? // This will now be fetched from the singleton
       let db = Firestore.firestore()
           
       override func viewDidLoad() {
           super.viewDidLoad()
           
           setupGradientBackground()
           
           // Fetch current user ID from the singleton
           if let currentUserID = CurrentLoginUser.shared.currentUserID {
               print("Logged in user ID: \(currentUserID)")
           } else {
               print("No logged-in user found.")
           }
           
           // Fetch the current organizer's ID from the OrganizerCurrentSelection singleton
           if let orgID = OrganizerCurrentSelection.shared.getOrgID() {
               organizerID = orgID // Set the organizerID from the singleton
               print("Organizer ID: \(orgID)") // Debugging line
           } else {
               print("Error: Organizer ID is missing.")
           }
           
           fetchFollowersCount()
       }
           
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
           // Retrieve the selected organizer's details from OrganizerCurrentSelection
           if let selectedOrgName = OrganizerCurrentSelection.shared.getOrgName(),
              let selectedOrgBrief = OrganizerCurrentSelection.shared.getOrgBrief() {
               // Set the name and brief from the current selection
               name.text = selectedOrgName  // Display the organizer's full name
               aboutlbl.text = selectedOrgBrief  // Display the organizer's brief
           }
           
           if let orgID = OrganizerCurrentSelection.shared.getOrgID() {
                   organizerID = orgID // Set the organizerID from the singleton
                   print("Organizer ID: \(orgID)") // Debugging line
               } else {
                   print("Error: Organizer ID is missing.")
               }
           
           fetchFollowersCount()
           
           // Update follow button state
           updateFollowButtonState()
       }
    
    func fetchFollowersCount() {
           // Ensure the organizerID is set
           guard let organizerID = self.organizerID else {
               print("Error: Organizer ID is missing.")
               return
           }
           
           // Fetch the organizer's document to get the Followers count
           let organizerRef = db.collection("Users").document(organizerID)
           
           organizerRef.getDocument { (document, error) in
               if let document = document, document.exists {
                   // Fetch the Followers field (assuming it is a number)
                   if let followersCount = document.data()?["Followers"] as? Int {
                       // Update the NumOfFollowers label with the count
                       self.NumOfFollowers.text = "\(followersCount)"
                   } else {
                       print("Error: Followers field is missing or not a number.")
                   }
               } else {
                   print("Error: Organizer document does not exist or cannot be fetched.")
               }
           }
       }
           
       func setupGradientBackground() {
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
       
       // This function checks if the current user is following the organizer and updates the button state
       func updateFollowButtonState() {
           // Fetch current user ID from the singleton
           guard let currentUserID = CurrentLoginUser.shared.currentUserID, let organizerID = organizerID else {
               print("Error: No logged-in user or no organizer ID.")
               return
           }
           
           let userRef = db.collection("Users").document(currentUserID)
           
           userRef.getDocument { document, error in
               if let document = document, document.exists {
                   let following = document.data()?["Following"] as? [String] ?? []
                   
                   // Check if the current user is already following the organizer
                   if following.contains(organizerID) {
                       self.Followbtn.setTitle("Unfollow", for: .normal)
                   } else {
                       self.Followbtn.setTitle("Follow", for: .normal)
                   }
               }
           }
       }
           
       // Follow/Unfollow Button Action
       @IBAction func followButtonTapped(_ sender: UIButton) {
           guard let currentUserID = CurrentLoginUser.shared.currentUserID else {
               print("Error: No logged-in user.")
               return
           }
           
           guard let organizerID = organizerID else {
               print("Error: No organizer ID.")
               return
           }
           
           let userRef = db.collection("Users").document(currentUserID)
           let organizerRef = db.collection("Users").document(organizerID)
           
           userRef.getDocument { document, error in
               if let document = document, document.exists {
                   var following = document.data()?["Following"] as? [String] ?? []
                   
                   if following.contains(organizerID) {
                       // Unfollow action
                       following.removeAll { $0 == organizerID }
                       userRef.updateData(["Following": following]) { error in
                           if let error = error {
                               print("Error unfollowing: \(error)")
                           } else {
                               // Decrease followers count for the organizer
                               organizerRef.updateData(["Followers": FieldValue.increment(Int64(-1))]) { error in
                                   if let error = error {
                                       print("Error decreasing followers count: \(error)")
                                   } else {
                                       self.Followbtn.setTitle("Follow", for: .normal) // Update button text
                                       print("Unfollowed successfully.")
                                   }
                               }
                           }
                       }
                   } else {
                       // Follow action
                       following.append(organizerID)
                       userRef.updateData(["Following": following]) { error in
                           if let error = error {
                               print("Error following: \(error)")
                           } else {
                               // Increase followers count for the organizer
                               organizerRef.updateData(["Followers": FieldValue.increment(Int64(1))]) { error in
                                   if let error = error {
                                       print("Error increasing followers count: \(error)")
                                   } else {
                                       self.Followbtn.setTitle("Unfollow", for: .normal) // Update button text
                                       print("Followed successfully.")
                                   }
                               }
                           }
                       }
                   }
               } else {
                   print("Error: User document does not exist.")
               }
           }
       }
   }
