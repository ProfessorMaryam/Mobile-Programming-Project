//
//  EventsDisplayController.swift
//  Eventosaurus
//
//  Created by BP-36-201-15 on 14/12/2024.
//

import UIKit
import FirebaseFirestore

class EventsDisplayController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var eventsSearch: UISearchBar!
    
    var eventsList: [(eventName: String, organizer1: String, documentID: String)] = [] // Store documentID for each event
    var filteredEvents: [(eventName: String, organizer1: String, documentID: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the custom nib for the table view cell
        let nib = UINib(nibName: "EventsDisplayTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "EventCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        eventsSearch.delegate = self
        
        fetchEventDataFromFireStore()
    }

    // MARK: - Search Functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredEvents = eventsList
        } else {
            filteredEvents = eventsList.filter { event in
                event.eventName.lowercased().contains(searchText.lowercased()) ||
                event.organizer1.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredEvents = eventsList
        tableView.reloadData()
    }
    
    // MARK: - Fetch Data from Firestore
    func fetchEventDataFromFireStore() {
        let db = Firestore.firestore()
        
        db.collection("Events").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }
            
            self.eventsList.removeAll()
            
            let dispatchGroup = DispatchGroup()

            for document in snapshot!.documents {
                guard let eventName = document.get("Event Name") as? String else {
                    print("Missing event name for document: \(document.documentID)")
                    continue
                }
                
                guard let organizerReference = document.get("Organizer1") as? DocumentReference else {
                    print("Missing organizer reference for event \(eventName)")
                    continue
                }
                
                dispatchGroup.enter()
                
                organizerReference.getDocument { userSnapshot, error in
                    if let error = error {
                        print("Error fetching organizer: \(error.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let organizerName = userSnapshot?.get("Full Name") as? String else {
                        print("Organizer name not found for event: \(eventName)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    // Append event along with documentID to the list
                    self.eventsList.append((eventName: eventName, organizer1: organizerName, documentID: document.documentID))
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.filteredEvents = self.eventsList
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table View DataSource and Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventsDisplayTableViewCell
        let event = filteredEvents[indexPath.row]
        
        cell.Eventname.text = event.eventName
        cell.organizerName.text = event.organizer1
        
        return cell
    }

    // MARK: - Navigate to ViewFeedback and Pass EventID
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected event and its document ID
       // let selectedEvent = filteredEvents[indexPath.row]
      //  let eventID = selectedEvent.documentID
        
        // Instantiate the ViewFeedback controller
        if let feedbackVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewFeedback") as? ViewFeedback {
          
            // Set the title of the navigation bar (optional)
            feedbackVC.title = "Event Feedback"
            
            // Push the ViewFeedback controller to the navigation stack
            self.navigationController?.pushViewController(feedbackVC, animated: true)
        }
    }

    // MARK: - Swipe-to-Delete Action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let event = filteredEvents[indexPath.row]
        
        // Create the delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.deleteEvent(eventID: event.documentID)
            completionHandler(true)
        }
        
        // Configure the swipe actions
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }

    // MARK: - Delete Event from Firestore
    func deleteEvent(eventID: String) {
        let db = Firestore.firestore()
        
        // Delete the event from Firestore by its document ID
        db.collection("Events").document(eventID).delete { error in
            if let error = error {
                print("Error deleting event: \(error.localizedDescription)")
            } else {
                // Update the events list after deletion
                self.eventsList = self.eventsList.filter { $0.documentID != eventID }
                self.filteredEvents = self.eventsList
                self.tableView.reloadData()
            }
        }
    }
}
