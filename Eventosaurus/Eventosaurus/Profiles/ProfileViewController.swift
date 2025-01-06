//
//  ProfileViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed  on 28/12/2024.
//

import UIKit
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    let db = Firestore.firestore() // Firestore reference for database operations
    
    @IBOutlet weak var eventHistory: UITextView! // TextView to display user's event history
    @IBOutlet weak var upcomingEvent: UITextView! // TextView to display user's upcoming events
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData() // Load user data when the view is loaded
    }
    
    func loadUserData() {
        let userEmail = User.loggedInemail // Get the logged-in user's email
        
        // Fetch user's basic information from Firestore
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
            
            // Retrieve full name and brief description of the user
            let fullName = document.get("Full Name") as? String ?? ""
            let brief = document.get("Brief") as? String
            let briefText = (brief?.isEmpty ?? true) ? "You should add a description!" : brief!
            
            // Update UI with user's name and description on the main thread
            DispatchQueue.main.async {
                self?.name.text = fullName
                self?.briedText.text = briefText
            }
            
            // Fetch user's events after loading basic information
            self?.loadUserEvents(userEmail: userEmail)
        }
    }

    func loadUserEvents(userEmail: String) {
        // Fetch all events associated with the user from Firestore
        db.collection("Event_User")
            .whereField("email", isEqualTo: userEmail)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching user events: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var upcomingEvents: [String] = [] // Array to store upcoming event names
                var historyEvents: [String] = [] // Array to store past event names
                let group = DispatchGroup() // DispatchGroup to manage multiple asynchronous tasks
                
                // Iterate through each Event_User document
                for document in documents {
                    group.enter() // Notify DispatchGroup about a new task
                    
                    if let eventId = document.get("event_id") as? String {
                        // Fetch the corresponding event details using the event ID
                        self?.db.collection("Events").document(eventId).getDocument { eventSnapshot, error in
                            defer { group.leave() } // Notify DispatchGroup task completion
                            
                            guard let eventData = eventSnapshot?.data(),
                                  let eventName = eventData["Event Name"] as? String,
                                  let status = eventData["Status"] as? String else { return }
                            
                            // Categorize events based on their status
                            if status == "UpComing" {
                                upcomingEvents.append(eventName)
                            } else {
                                historyEvents.append(eventName)
                            }
                        }
                    } else {
                        group.leave() // If no event ID, notify DispatchGroup task completion
                    }
                }
                
                // Update UI after all events are fetched
                group.notify(queue: .main) {
                    // Display upcoming events or a placeholder message
                    if upcomingEvents.isEmpty {
                        self?.upcomingEvent.text = "No upcoming events"
                    } else {
                        self?.upcomingEvent.text = upcomingEvents.joined(separator: "\n")
                    }
                    
                    // Display the last 3 historical events or a placeholder message
                    if historyEvents.isEmpty {
                        self?.eventHistory.text = "No event history"
                    } else {
                        let lastThreeEvents = Array(historyEvents.prefix(3))
                        let displayText = lastThreeEvents.joined(separator: "\n...\n")
                        self?.eventHistory.text = displayText + (historyEvents.count > 3 ? "\n..." : "")
                    }
                }
            }
    }
    
    @IBOutlet weak var briedText: UITextView! // TextView to display user's brief description
    @IBOutlet weak var name: UILabel! // Label to display user's full name
}
