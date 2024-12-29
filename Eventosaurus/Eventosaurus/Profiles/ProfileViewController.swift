//
//  ProfileViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed  on 28/12/2024.
//

import UIKit
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var eventHistory: UITextView!
    @IBOutlet weak var upcomingEvent: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData()
    }
    
    func loadUserData() {
        let userEmail = User.loggedInemail
        
        // First load user basic info
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
            
            let fullName = document.get("Full Name") as? String ?? ""
            let brief = document.get("Brief") as? String
            let briefText = (brief?.isEmpty ?? true) ? "You should add a description!" : brief!
            
            DispatchQueue.main.async {
                self?.name.text = fullName
                self?.briedText.text = briefText
            }
            
            // After loading basic info, load events
            self?.loadUserEvents(userEmail: userEmail)
        }
    }

    func loadUserEvents(userEmail: String) {
        // Get all events for this user
        db.collection("Event_User")
            .whereField("email", isEqualTo: userEmail)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching user events: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var upcomingEvents: [String] = []
                var historyEvents: [String] = []
                let group = DispatchGroup()
                
                // For each Event_User document, fetch the corresponding event
                for document in documents {
                    group.enter()
                    if let eventId = document.get("event_id") as? String {
                        self?.db.collection("Events").document(eventId).getDocument { eventSnapshot, error in
                            defer { group.leave() }
                            
                            guard let eventData = eventSnapshot?.data(),
                                  let eventName = eventData["Event Name"] as? String,
                                  let status = eventData["Status"] as? String else { return }
                            
                            if status == "UpComing" {
                                upcomingEvents.append(eventName)
                            } else {
                                historyEvents.append(eventName)
                            }
                        }
                    } else {
                        group.leave()
                    }
                }
                
                // When all events are fetched, update the UI
                group.notify(queue: .main) {
                    // Display upcoming events
                    if upcomingEvents.isEmpty {
                        self?.upcomingEvent.text = "No upcoming events"
                    } else {
                        self?.upcomingEvent.text = upcomingEvents.joined(separator: "\n")
                    }
                    
                    // Display last 3 historical events with dots
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
    @IBOutlet weak var briedText: UITextView!
    @IBOutlet weak var name: UILabel!
}
