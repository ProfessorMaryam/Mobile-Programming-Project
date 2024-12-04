import Foundation



class Event {
    
    enum EventStatus {
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
    var organizers: String
    var maximumAttendees: Int
    
    // Updated initializer that accepts a date string
    init(status: EventStatus, name: String, description: String, date: String, organizers: String, maximumAttendees: Int) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-mm-yyyy"  // Customize the expected date format (e.g., "yyyy-MM-dd")
        
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
        self.organizers = organizers
        self.maximumAttendees = maximumAttendees
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
