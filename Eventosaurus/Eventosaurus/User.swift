//
//  User.swift
//  Eventosaurus
//
//  Created by BP-36-201-14 on 01/12/2024.
//

import Foundation


enum UserRole {
    case Attendee
    case Organizer
    case Admin
    case Banned
}



class User : Codable{
    let fullName: String
    let email: String
    let dateOfBirth: String
    var password: String
    var userID : String
    static var idIncrement : Int =  1000
    var isOrganizer: Bool
    var isAdmin : Bool
    
    
    ///Constructor is used in registration
    
    init(fullName: String, email: String, dateOfBirth: String, password: String, isOrganizer : Bool, isAdmin : Bool) {
          
          self.fullName = fullName
        self.email = email
          self.password = password
          self.dateOfBirth = dateOfBirth
        self.isOrganizer = isOrganizer
        self.userID = ""
          
          // Convert the string to Date
//          let dateFormatter = DateFormatter()
//          dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust to the format of your input
//          
//          if let date = dateFormatter.date(from: dateOfBirth) {
//              self.dateOfBirth = date // Store it as Date
//          } else {
//              print("Invalid date format")
//              self.dateOfBirth = Date() // Default to the current date if parsing fails
//          }
          //self.userID = User.idIncrement
         // User.idIncrement += 1
        self.isAdmin = isAdmin
        
      }
    
    
    func toDictionary() -> [String: Any] {
            return [
                "ID": userID,
                "Full Name": fullName,
                "Email": email,
                "Date Of Birth": dateOfBirth,
                "Password": password,
                "Is Organizer": isOrganizer,
                "Is Admin" : isAdmin
            ]
        }
    

    func joinEvent(){
        // add user to the list of the event attendees
    }
    
    func withdrawFromEvent(){
        // remove self from the list of event attendees
    }
    
    func likeEvent(){
        
    }
    
    func shareEvent(){
        
    }
    
    func eventPayment(){
        
    }
    
}
