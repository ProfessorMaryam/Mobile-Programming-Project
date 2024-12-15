import Foundation
import FirebaseFirestore

class Event {
    
    enum EventStatus: String {
        case upcoming
        case ongoing
        case cancelled
        case completed
    }
    
    var eventName: String
    var users: [User] = []
    var status: EventStatus
    var description: String
    var date: Date
    var organizer1: String
    var organizer2: String
    var maximumAttendees: Int
    
    // Updated initializer that accepts a date string
    init(status: EventStatus, name: String, description: String, date: String, organizer1 : String, organizer2: String ,  maximumAttendees: Int) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"  // Customize the expected date format (e.g., "yyyy-MM-dd")
        
        if let parsedDate = dateFormatter.date(from: date) {
            self.date = parsedDate  // Successfully parsed date
        } else {
            // Handle invalid date format by setting the current date or another fallback
            self.date = Date()
            print("Invalid date format, using current date instead.")
        }
        
        self.eventName = name
        self.status = status
        self.description = description
        self.organizer1 = organizer1
        self.organizer2 = organizer2
        self.maximumAttendees = maximumAttendees
    }
    
    // convert the Event object into a dictionary for Firestore
    func toDictionary() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"  // Use the same format as the initializer
        
        // Convert the event status to a string
        let statusString = status.rawValue
        
        // Create a dictionary
        let eventDict: [String: Any] = [
            "Event Name": eventName,
            "Status": statusString,
            "Description": description,
            "Date": dateFormatter.string(from: date),
            "Organizer1": organizer1,
            "Organizer2" : organizer2,
            "Maximum attendees": maximumAttendees
        ]
        
        return eventDict
    }
    
    // Method to add a user to the event
    func addUser(user: User) {
        users.append(user)
        print("\(user.fullName) added to the event.")
    }
    
    // Method to remove a user from the event by name
    func removeUser(user: User) {
        if let index = users.firstIndex(where: { $0.email == user.email }) {
            users.remove(at: index)
            print("\(user.fullName) removed from the event.")
        } else {
            print("User \(user.fullName) not found in the event.")
        }
    }
    
    // Method to display all users in the event
    func displayUsers() {
        if users.isEmpty {
            print("No users in the event.")
        } else {
            print("Users in the event:")
            for user in users {
                print("\(user.fullName) - \(user.email)")
            }
        }
    }
}
