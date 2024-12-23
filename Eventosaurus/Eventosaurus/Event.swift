import Foundation
import FirebaseFirestore

class Event {
    
    // Event attributes
    var eventName: String
    var status: String 
    var description: String
    var date: Date
    var organizer1: String
    var organizer2: String
    var maximumAttendees: Int
    
    // Construstor
    init(status: String, name: String, description: String, date: Date, organizer1: String, organizer2: String, maximumAttendees: Int) {
        self.eventName = name
        self.status = status
        self.description = description
        self.organizer1 = organizer1
        self.organizer2 = organizer2
        self.maximumAttendees = maximumAttendees
        self.date = date
    }
    
    // Dictionary used to conform to the Firestore data layout
    func toDictionary() -> [String: Any] {
        
        let eventDict: [String: Any] = [
            "Event Name": eventName,
            "Status": status,
            "Description": description,
            "Date": Timestamp(date: date), //time stamp used to save the date
            "Organizer1": organizer1,
            "Organizer2": organizer2,
            "Maximum attendees": maximumAttendees
        ]
        
        return eventDict
    }
    
    // check if the event is full based on maximum attendees
    func isEventFull(currentAttendees: Int) -> Bool {
        return currentAttendees >= maximumAttendees
    }
}
