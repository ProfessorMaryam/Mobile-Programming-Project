//
//  User.swift
//  Eventosaurus
//
//  Created by BP-36-201-14 on 01/12/2024.
//

import FirebaseFirestore

class User: Codable {
    let fullName: String
    let email: String
    var dateOfBirth: Date  // This is now a Date object
    var password: String
    var userID: String
    static var idIncrement: Int = 1000
    var isOrganizer: Bool
    var isAdmin: Bool
    
    /// Constructor used in registration
    init(fullName: String, email: String, dateOfBirth: Date, password: String, isOrganizer: Bool, isAdmin: Bool) {
        self.fullName = fullName
        self.email = email
        self.password = password
        self.dateOfBirth = dateOfBirth
        self.isOrganizer = isOrganizer
        self.userID = ""
        self.isAdmin = isAdmin
    }
    
    func toDictionary() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return [
            "ID": userID,
            "Full Name": fullName,
            "Email": email,
            "Date Of Birth": Timestamp(date: dateOfBirth), // Store as Firestore Timestamp
            "Password": password,
            "Is Organizer": isOrganizer,
            "Is Admin": isAdmin
        ]
    }
}
