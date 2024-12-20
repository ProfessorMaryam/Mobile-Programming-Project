import Foundation
import FirebaseFirestore

class Event {
    
    // Event properties
    var eventName: String
    var status: String
    var description: String
    var date: Date
    var organizer1: String
    var organizer2: String
    var maximumAttendees: Int
    
    // Initializer
    init(status: String, name: String, description: String, date: Date, organizer1: String, organizer2: String, maximumAttendees: Int) {
        self.eventName = name
        self.status = status
        self.description = description
        self.organizer1 = organizer1
        self.organizer2 = organizer2
        self.maximumAttendees = maximumAttendees
        self.date = date
    }
    
    // Convert the Event object into a dictionary for Firestore
    func toDictionary() -> [String: Any] {
        // Create a dictionary with the event's data
        let eventDict: [String: Any] = [
            "Event Name": eventName,
            "Status": status,  // Using String for status
            "Description": description,
            "Date": Timestamp(date: date),  // Firestore Timestamp
            "Organizer1": organizer1,
            "Organizer2": organizer2,
            "Maximum attendees": maximumAttendees
        ]
        
        return eventDict
    }
    
    // Optional: Check if the event is full (based on maximum attendees)
    func isEventFull(currentAttendees: Int) -> Bool {
        return currentAttendees >= maximumAttendees
    }
}
