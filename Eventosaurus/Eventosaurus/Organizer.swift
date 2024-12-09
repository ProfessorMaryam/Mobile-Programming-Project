//////////
//////////  Organizer.swift
//////////  Eventosaurus
//////////
//////////  Created by BP-36-201-14 on 01/12/2024.
//////////
////////
//import Foundation
//
//class Organizer : User{
//    
//    
//    var contactNumber: String
//    
//    init(contactNumber: String) {
//        
//       super.init(username: <#T##String#>, fullName: <#T##String#>, email: <#T##String#>, dateOfBirth: <#T##String#>, password: <#T##String#>)
//            .base()
//      self.contactNumber = contactNumber
//    }
//
//    
//    func createEvent(name: String, description: String, date: String, maximumAttendees: Int){
//        let newEvent = Event(status: .upcoming, name: name, description: description, date: date, organizers: self.fullName, maximumAttendees: maximumAttendees)
//
//    }
//    
//    func banEvent(event : Event){
//        event.status = .cancelled
//    }
//    
//    func editEvent(event: Event, newDescription: String?, newDate: String?) {
//           if let newDescription = newDescription {
//               event.description = newDescription
//               print("Event description updated to: \(newDescription)")
//           } 
//        if let newDate = newDate {
//               let dateFormatter = DateFormatter()
//               dateFormatter.dateFormat = "dd-MM-yyyy"
//               if let parsedDate = dateFormatter.date(from: newDate) {
//                   event.date = parsedDate
//                   print("Event date updated to: \(newDate)")
//               } else {
//                   print("Invalid date format. Event date not updated.")
//               }
//           }
//       }
//    
//    
//    
//    func banUserFromEvent(user: User, event: Event) {
//        event.removeUser(user: user)
//        print("\(user.fullName) has been banned from the event '\(event.eventName)'.")
//    }
//}
