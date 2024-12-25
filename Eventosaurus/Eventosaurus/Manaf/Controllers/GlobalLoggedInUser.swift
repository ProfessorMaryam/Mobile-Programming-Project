//
//  GlobalLoggedInUser.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed on 25/12/2024.
//

import Foundation

struct CurrentUser {
    static var shared = CurrentUser()

    var userID: String?
    var fullName: String?
    var email: String?
    var dateOfBirth: Date?
    var isOrganizer: Bool = false
    var isAdmin: Bool = false
    
    mutating func setUser(from user: User) {
        self.userID = user.userID
        self.fullName = user.fullName
        self.email = user.email
        self.dateOfBirth = user.dateOfBirth
        self.isOrganizer = user.isOrganizer
        self.isAdmin = user.isAdmin
    }
    
    mutating func clear() {
        self = CurrentUser() // Reset to default
    }
}
