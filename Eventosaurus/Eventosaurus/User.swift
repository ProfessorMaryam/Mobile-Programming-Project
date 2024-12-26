//
//  User.swift
//  Eventosaurus
//
//  Created by BP-36-201-14 on 01/12/2024.
//

import FirebaseFirestore

class User: Codable {
    
    
  //  static var loggeduser = User(from: <#Decoder#>)
    //Attributes
    let fullName: String
    let email: String
    var dateOfBirth: Date
    var password: String
    var userID: String
    var isOrganizer: Bool
    var isAdmin: Bool
    
    // Construstor used in registration
    init(fullName: String, email: String, dateOfBirth: Date, password: String, isOrganizer: Bool, isAdmin: Bool) {
        self.fullName = fullName
        self.email = email
        self.password = password
        self.dateOfBirth = dateOfBirth
        self.isOrganizer = isOrganizer
        self.userID = ""
        self.isAdmin = isAdmin
    }
    
    // Dictionary used to conform to the Firestore data layout
    func toDictionary() -> [String: Any] {
        return [
            "Full Name": fullName,
            "Email": email,
            "Date Of Birth": Timestamp(date: dateOfBirth), // Firestore Timestamp
            "Password": password, // Store hashed password
            "Is Organizer": isOrganizer,
            "Is Admin": isAdmin
        ]
    }
}
