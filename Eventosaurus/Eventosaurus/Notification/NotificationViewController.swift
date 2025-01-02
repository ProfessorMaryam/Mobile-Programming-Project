import UIKit
import FirebaseFirestore
import FirebaseAuth

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,EventDetailsDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userName: User?
    var upcomingEvents: [[String: Any]] = []
    var joinedEvents: [[String: Any]] = []
    let db = Firestore.firestore()
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Enable dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        fetchUpcomingEvents()
        fetchJoinedEvents()
    }
    func didJoinEvent(eventData: [String: Any]) {
        print("entered for notification view controller")
            // Add the event to the joined events array
            joinedEvents.append(eventData)
            
            // Reload the table view
            tableView.reloadData()
        }
    
    // Fetch upcoming events
    func fetchUpcomingEvents() {
        db.collection("Events").whereField("Status", isEqualTo: "UpComing").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching upcoming events: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found for upcoming events.")
                return
            }
            
            print("Fetched upcoming events: \(documents.count)")
            
            self.upcomingEvents = documents.map { doc in
                var data = doc.data()
                data["eventID"] = doc.documentID // Add document ID to the dictionary
                return data
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // Fetch joined events for the current user
    // Fetch joined events for the current user
    func fetchJoinedEvents() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("User email not found.")
            return
        }
        
        // Step 1: Fetch documents from Event_User where email matches
        db.collection("Users").whereField("email", isEqualTo: userEmail).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching joined events: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No joined events found for user.")
                return
            }
            
            // Step 2: Extract event_id values
            let eventIDs = documents.compactMap { $0.data()["event_id"] as? String }
            
            if eventIDs.isEmpty {
                print("No event IDs found for joined events.")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                return
            }
            
            print("Event IDs for joined events: \(eventIDs)")
            
            // Step 3: Fetch events from the Events collection using event_id
            self.db.collection("Events").whereField(FieldPath.documentID(), in: eventIDs).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching event details for joined events: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No event details found.")
                    return
                }
                
                // Step 4: Map the data and reload the table
                self.joinedEvents = documents.map { doc in
                    var data = doc.data()
                    data["eventID"] = doc.documentID // Include the document ID
                    return data
                }
                
                print("Joined Events: \(self.joinedEvents)")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - TableView DataSource & Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Section 0 for Upcoming Events, Section 1 for Joined Events
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return upcomingEvents.count
        } else {
            return joinedEvents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! notificationTableViewCell
        let event = indexPath.section == 0 ? upcomingEvents[indexPath.row] : joinedEvents[indexPath.row]
        
        cell.eventTitle.text = event["Event Name"] as? String
        cell.eventDescription.text = event["Description"] as? String
        cell.eventImage.image = UIImage(systemName: "calendar") // Placeholder image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Set header titles
        return section == 0 ? "Upcoming Events" : "Joined Events"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEvent = indexPath.section == 0 ? upcomingEvents[indexPath.row] : joinedEvents[indexPath.row]
        performSegue(withIdentifier: "showEventDetails", sender: selectedEvent)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventDetails",
           let destinationVC = segue.destination as? EventDetailsViewController,
           let eventData = sender as? [String: Any] {
            destinationVC.eventData = eventData
        }
    }
}
