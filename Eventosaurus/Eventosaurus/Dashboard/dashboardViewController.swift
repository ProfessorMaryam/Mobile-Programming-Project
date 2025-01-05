import UIKit
import FirebaseFirestore
import FirebaseAuth

class dashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    var todayEvent: [String: Any]?
    var eventHistory: [[String: Any]] = []
    var joinedEvents: [[String: Any]] = []
    var userEmail: String? {
        return User.loggeduser // Ensure this matches your User class logic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchJoinedEvents()
    }
    
    // MARK: - Setup TableView
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    // MARK: - Fetch Joined Events
    func fetchJoinedEvents() {
        guard let userEmail = userEmail else {
            print("User email not found.")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDateString = dateFormatter.string(from: Date()) // Today's date
        
        db.collection("Event_User")
            .whereField("email", isEqualTo: userEmail)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching joined events: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No joined events found.")
                    return
                }
                
                let eventIDs = documents.compactMap { $0.data()["event_id"] as? String }
                
                self.db.collection("Events").whereField(FieldPath.documentID(), in: eventIDs).getDocuments { eventSnapshot, error in
                    if let error = error {
                        print("Error fetching event details: \(error)")
                        return
                    }
                    
                    guard let eventDocs = eventSnapshot?.documents else {
                        print("No events found for provided event IDs.")
                        return
                    }
                    
                    self.joinedEvents = eventDocs.map { doc in
                        var data = doc.data()
                        data["eventID"] = doc.documentID
                        return data
                    }
                    
                    self.filterEvents(todayDateString: todayDateString, dateFormatter: dateFormatter)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
    }
    
    // MARK: - Filter Events
    func filterEvents(todayDateString: String, dateFormatter: DateFormatter) {
        todayEvent = nil
        eventHistory.removeAll()
        
        for event in joinedEvents {
            if let timestamp = event["Date"] as? Timestamp {
                let eventDate = timestamp.dateValue()
                let eventDateString = dateFormatter.string(from: eventDate)
                let eventYear = Calendar.current.component(.year, from: eventDate)
                
                if eventDateString == todayDateString {
                    todayEvent = event
                } else if eventYear < 2025 {
                    eventHistory.append(event)
                }
            }
        }
    }
    
    // MARK: - TableView DataSource and Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return todayEvent == nil ? 0 : 1
        } else {
            return eventHistory.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Today's Event" : "Event History"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dashcell", for: indexPath)
        
        if indexPath.section == 0 {
            if let todayEvent = todayEvent {
                cell.textLabel?.text = todayEvent["Event Name"] as? String ?? "Unknown Event"
                cell.detailTextLabel?.text = todayEvent["Description"] as? String ?? "No Description"
            }
        } else {
            let event = eventHistory[indexPath.row]
            cell.textLabel?.text = event["Event Name"] as? String ?? "Unknown Event"
            cell.detailTextLabel?.text = event["Description"] as? String ?? "No Description"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let todayEvent = todayEvent {
                showEventDetails(eventData: todayEvent)
            }
        } else {
            let event = eventHistory[indexPath.row]
            showEventDetails(eventData: event)
        }
    }
    
    // MARK: - Show Event Details
    func showEventDetails(eventData: [String: Any]) {
        let eventName = eventData["Event Name"] as? String ?? "Unknown Event"
        let description = eventData["Description"] as? String ?? "No Description"
        
        let alert = UIAlertController(title: eventName, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
