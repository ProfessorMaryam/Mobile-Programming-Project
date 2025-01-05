import UIKit
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EventDetailsDelegate {
    
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        // Fetch data
        fetchUpcomingEvents()
        fetchJoinedEvents()
        
        // Request notification permissions
        requestNotificationPermission()
    }
    
    func didJoinEvent(eventData: [String: Any]) {
        print("User joined event: \(eventData)")
        
        // Add the event to the joined events array
        joinedEvents.append(eventData)
        
        // Remove the event from the upcoming events list
        if let eventID = eventData["eventID"] as? String {
            upcomingEvents.removeAll { $0["eventID"] as? String == eventID }
        }
        
        // Schedule reminders for the joined event
        scheduleEventReminders(for: eventData)
        
        // Reload the table view
        tableView.reloadData()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func leaveEvent(eventData: [String: Any]) {
            let eventID = eventData["eventID"] as? String ?? ""
            let userEmail = User.loggeduser
            
            // Find and delete the event from the Event_User collection
            db.collection("Event_User")
                .whereField("email", isEqualTo: userEmail)
                .whereField("event_id", isEqualTo: eventID)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error finding the event to leave: \(error)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents, let document = documents.first else {
                        print("No matching event found to leave.")
                        return
                    }
                    
                    // Delete the document
                    self.db.collection("Event_User").document(document.documentID).delete { error in
                        if let error = error {
                            print("Error removing the event: \(error)")
                            return
                        }
                        
                        print("Successfully left the event.")
                        
                        // Move the event from joinedEvents to upcomingEvents
                        if let index = self.joinedEvents.firstIndex(where: { $0["eventID"] as? String == eventID }) {
                            let event = self.joinedEvents.remove(at: index)
                            self.upcomingEvents.append(event)
                        }
                        
                        // Reload the table view
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            // Show success alert
                            self.showAlert(title: "Event Left", message: "You have successfully left the event.")
                        }
                    }
                }
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
            
            self.upcomingEvents = documents.map { doc in
                var data = doc.data()
                data["eventID"] = doc.documentID // Add document ID to the dictionary
                return data
            }
            
            self.filterUpcomingEvents()
        }
    }
    
    // Fetch joined events for the current user
    func fetchJoinedEvents() {
        let userEmail = User.loggeduser
        
        db.collection("Event_User").whereField("email", isEqualTo: userEmail).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching joined events: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No joined events found for user.")
                return
            }
            
            let eventIDs = documents.compactMap { $0.data()["event_id"] as? String }
            
            if eventIDs.isEmpty {
                print("No event IDs found for joined events.")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                return
            }
            
            self.db.collection("Events").whereField(FieldPath.documentID(), in: eventIDs).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching event details for joined events: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.joinedEvents = documents.map { doc in
                    var data = doc.data()
                    data["eventID"] = doc.documentID // Include the document ID
                    return data
                }
                
                // Schedule notifications for all joined events
                for event in self.joinedEvents {
                    self.scheduleEventReminders(for: event)
                }
                
                self.filterUpcomingEvents()
            }
        }
    }
    
    // Filter out joined events from upcoming events
    func filterUpcomingEvents() {
        let joinedEventIDs = Set(joinedEvents.compactMap { $0["eventID"] as? String })
        
        self.upcomingEvents.removeAll { event in
            if let eventID = event["eventID"] as? String {
                return joinedEventIDs.contains(eventID)
            }
            return false
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // Schedule local reminders for an event
    func scheduleEventReminders(for event: [String: Any]) {
        guard let eventName = event["Event Name"] as? String,
              let dateTimestamp = event["Date"] as? Timestamp else { return }
        
        let eventDate = dateTimestamp.dateValue()
        
        // Schedule reminders for 12:00 AM event time
        let reminders = [
            ("1 hour before 12:00 AM", eventDate.addingTimeInterval(-60 * 60)), // 11:00 PM
            ("5 minutes before 12:00 AM", eventDate.addingTimeInterval(-5 * 60)), // 11:55 PM
            ("1 minute before 12:00 AM", eventDate.addingTimeInterval(-60)) // 11:59 PM
        ]
        
        let notificationCenter = UNUserNotificationCenter.current()
        for reminder in reminders {
            if reminder.1 > Date() { // Schedule only if the reminder time is in the future
                let content = UNMutableNotificationContent()
                content.title = "Event Reminder"
                content.body = "\(reminder.0) for \(eventName)"
                content.sound = .default
                
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents(
                        [.year, .month, .day, .hour, .minute],
                        from: reminder.1
                    ),
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: "\(eventName)_\(reminder.0)",
                    content: content,
                    trigger: trigger
                )
                
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    } else {
                        print("Notification scheduled for \(eventName) - \(reminder.0)")
                    }
                }
            }
        }
    }
    
    // Request notification permissions
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied: \(String(describing: error))")
            }
        }
    }
    
    // MARK: - TableView DataSource & Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Section 0 for Upcoming Events, Section 1 for Joined Events
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? upcomingEvents.count : joinedEvents.count
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
            destinationVC.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUpcomingEvents()
        fetchJoinedEvents()
    }
}
