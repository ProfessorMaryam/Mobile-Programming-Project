//
//  OrganizerProfileViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed  on 28/12/2024.
//

import UIKit
import Firebase
class OrganizerProfileViewController: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var follwerstxt: UILabel!
    @IBOutlet weak var followingtxt: UILabel!
    @IBOutlet weak var nametxt: UILabel!
    @IBOutlet weak var Brieftxt: UITextView!
    
    @IBOutlet weak var eventHistorytxt: UITextView!
    @IBOutlet weak var upcomingeventstxt: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData()
        loadFollowersCount()
        loadOrganizerEvents()
    }
    
    func loadUserData() {
        let userEmail = User.loggedInemail
        
        db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents,
                  let document = documents.first else {
                print("User document not found")
                return
            }
            
            // Get the full name
            let fullName = document.get("Full Name") as? String ?? ""
            
            // Get the brief, use default message if nil or empty
            let brief = document.get("Brief") as? String
            let briefText = (brief?.isEmpty ?? true) ? "You should add a description!" : brief!
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self?.nametxt.text = fullName
                self?.Brieftxt.text = briefText
            }
        }
    }
    
    func loadFollowersCount() {
        let userEmail = User.loggedInemail
        
        // Count people following this user (followers)
        db.collection("Followers")
            .whereField("user", isEqualTo: userEmail)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching followers: \(error)")
                    return
                }
                
                let followersCount = snapshot?.documents.count ?? 0
                
                DispatchQueue.main.async {
                    self?.follwerstxt.text = "\(followersCount)"
                }
            }
        
        // Count people this user follows (following)
        db.collection("Followers")
            .whereField("follower", isEqualTo: userEmail)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching following: \(error)")
                    return
                }
                
                let followingCount = snapshot?.documents.count ?? 0
                
                DispatchQueue.main.async {
                    self?.followingtxt.text = "\(followingCount)"
                }
            }
    }
    
    func loadOrganizerEvents() {
           let userEmail = User.loggedInemail
           
           // Get all events where this user is organizer1
           db.collection("Events")
               .whereField("Organizer1", isEqualTo: "/Users/\(userEmail)")
               .getDocuments { [weak self] snapshot, error in
                   if let error = error {
                       print("Error fetching events: \(error)")
                       return
                   }
                   
                   guard let documents = snapshot?.documents else {
                       print("No events found")
                       return
                   }
                   
                   var upcomingEvents: [String] = []
                   var historyEvents: [String] = []
                   
                   for document in documents {
                       guard let eventName = document.data()["Event Name"] as? String,
                             let status = document.data()["Status"] as? String else {
                           continue
                       }
                       
                       print("Found event: \(eventName) with status: \(status)")
                       
                       if status == "UpComing" {
                           upcomingEvents.append(eventName)
                       } else {
                           historyEvents.append(eventName)
                       }
                   }
                   
                   DispatchQueue.main.async {
                       // Display upcoming events
                       if upcomingEvents.isEmpty {
                           self?.upcomingeventstxt.text = "No upcoming events"
                       } else {
                           self?.upcomingeventstxt.text = upcomingEvents.joined(separator: "\n")
                       }
                       
                       // Display last 3 historical events with dots
                       if historyEvents.isEmpty {
                           self?.eventHistorytxt.text = "No event history"
                       } else {
                           let lastThreeEvents = Array(historyEvents.prefix(3))
                           let displayText = lastThreeEvents.joined(separator: "\n...\n")
                           self?.eventHistorytxt.text = displayText + (historyEvents.count > 3 ? "\n..." : "")
                       }
                   }
               }
       }
}
