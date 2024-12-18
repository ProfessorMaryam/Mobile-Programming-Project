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
    
    var eventsList: [(eventName: String, organizer1: String)] = []
    var filteredEvents: [(eventName: String, organizer1: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the custom nib for the table view cell
        let nib = UINib(nibName: "EventsDisplayTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        eventsSearch.delegate = self
        
        fetchEventDataFromFireStore()
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the events list based on the search text
        if searchText.isEmpty {
            filteredEvents = eventsList // If no search text, show all events
        } else {
            filteredEvents = eventsList.filter { event in
                event.eventName.lowercased().contains(searchText.lowercased()) ||
                event.organizer1.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Reset search to show all events when the search is cancelled
        filteredEvents = eventsList
        tableView.reloadData()
    }
    
    func fetchEventDataFromFireStore() {
        let db = Firestore.firestore()
        
        db.collection("Events").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }
            
            // Clear the existing event list before adding new data
            self.eventsList.removeAll()
            
            // Iterate through each document in the snapshot (each event)
            for document in snapshot!.documents {
                // Extract the event name from the document
                guard let eventName = document.get("Event Name") as? String else {
                    print("Missing event name for document: \(document.documentID)")
                    continue
                }
                
                // Extract the Organizer1 reference (which points to a document in the Users collection)
                guard let organizerReference = document.get("Organizer1") as? DocumentReference else {
                    print("Missing organizer reference for event \(eventName)")
                    continue
                }
                
                // Fetch the organizer's data from the Users collection
                organizerReference.getDocument { userSnapshot, error in
                    if let error = error {
                        print("Error fetching organizer: \(error.localizedDescription)")
                        return
                    }
                    
                    // Extract the organizer's full name from the user document
                    guard let organizerName = userSnapshot?.get("Full Name") as? String else {
                        print("Organizer name not found for event: \(eventName)")
                        return
                    }
                    
                    // Add the event data (event name and organizer's name) to the eventsList
                    self.eventsList.append((eventName: eventName, organizer1: organizerName))
                    
                    // Update the filtered events and reload the table view on the main thread
                    DispatchQueue.main.async {
                        self.filteredEvents = self.eventsList
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    
    // MARK: - Table View DataSource and Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = filteredEvents[indexPath.row]
        
        cell.textLabel?.text = event.eventName
        cell.detailTextLabel?.text = event.organizer1
        
        return cell
    }
}
