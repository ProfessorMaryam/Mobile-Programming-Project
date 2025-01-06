//
//  OrganizerProfileViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed  on 28/12/2024.
//

import UIKit
import Firebase

class OrganizerProfileViewController: UIViewController {
    // Firestore database reference
    let db = Firestore.firestore()
    
    // Outlets for UI components
    @IBOutlet weak var follwerstxt: UILabel! // Label to display the number of followers
    @IBOutlet weak var followingtxt: UILabel! // Label to display the number of users being followed
    @IBOutlet weak var nametxt: UILabel! // Label to display the organizer's name
    @IBOutlet weak var Brieftxt: UITextView! // TextView to display the organizer's brief description
    
    @IBOutlet weak var eventHistorytxt: UITextView! // TextView to display event history
    @IBOutlet weak var upcomingeventstxt: UITextView! // TextView to display upcoming events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load user data and update the UI
        loadUserData()
        
        // Load followers and following counts
        loadFollowersCount()
        
        // Load events organized by the user
        loadOrganizerEvents()
    }
    
    func loadUserData() {
        // Get the logged-in user's email
        let userEmail = User.loggedInemail
        
        // Fetch user data from the Firestore Users collection
        db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            // Ensure at least one document is retrieved
            guard let documents = snapshot?.documents,
                  let document = documents.first else {
                print("User document not found")
                return
            }
            
            // Retrieve the user's full name
            let fullName = document.get("Full Name") as? String ?? ""
            
            // Retrieve the user's brief description, or use a default message if empty
            let brief = document.get("Brief") as? String
            let briefText = (brief?.isEmpty ?? true) ? "You should add a description!" : brief!
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self?.nametxt.text = fullName
                self?.Brieftxt.text = briefText
            }
        }
    }
    
    func loadFollowersCount() {
        let userEmail = User.loggedInemail
        
        // Fetch the count of people following this user
        db.collection("Followers")
            .whereField("user", isEqualTo: userEmail)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching followers: \(error)")
                    return
                }
                
                // Get the count of followers
                let followersCount = snapshot?.documents.count ?? 0
                
                // Update the followers count in the UI on the main thread
                DispatchQueue.main.async {
                    self?.follwerstxt.text = "\(followersCount)"
                }
            }
        
        // Fetch the count of people this user is following
        db.collection("Followers")
            .whereField("follower", isEqualTo: userEmail)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching following: \(error)")
                    return
                }
                
                // Get the count of people the user is following
                let followingCount = snapshot?.documents.count ?? 0
                
                // Update the following count in the UI on the main thread
                DispatchQueue.main.async {
                    self?.followingtxt.text = "\(followingCount)"
                }
            }
    }
    
    func loadOrganizerEvents() {
        let userEmail = User.loggedInemail
        
        // Fetch events where the logged-in user is the primary organizer
        db.collection("Events")
            .whereField("Organizer1", isEqualTo: "/Users/\(userEmail)")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching events: \(error)")
                    return
                }
                
                // Ensure events are retrieved
                guard let documents = snapshot?.documents else {
                    print("No events found")
                    return
                }
                
                var upcomingEvents: [String] = [] // List to store upcoming events
                var historyEvents: [String] = [] // List to store past events
                
                // Iterate through the events and categorize them by status
                for document in documents {
                    guard let eventName = document.data()["Event Name"] as? String,
                          let status = document.data()["Status"] as? String else {
                        continue
                    }
                    
                    print("Found event: \(eventName) with status: \(status)")
                    
                    // Add event to appropriate list based on status
                    if status == "UpComing" {
                        upcomingEvents.append(eventName)
                    } else {
                        historyEvents.append(eventName)
                    }
                }
                
                // Update the UI on the main thread
                DispatchQueue.main.async {
                    // Display upcoming events or a default message
                    if upcomingEvents.isEmpty {
                        self?.upcomingeventstxt.text = "No upcoming events"
                    } else {
                        self?.upcomingeventstxt.text = upcomingEvents.joined(separator: "\n")
                    }
                    
                    // Display the last 3 historical events or a default message
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
