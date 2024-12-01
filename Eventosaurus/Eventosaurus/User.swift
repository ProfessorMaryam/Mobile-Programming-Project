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



class User {
    var username: String
    let fullName: String
    let email: String
    let dateOfBirth: String
    var password: String
    
    //var isOrganizer: Bool
    
    init(username: String, fullName: String, email: String, dateOfBirth: String, password: String) {
        self.username = username
        self.fullName = fullName
        self.email = email
        self.dateOfBirth = dateOfBirth
        self.password = password
            }
    
    func login(){
        
    }
    
    func joinEvent(){}
    
    func withdrawFromEvent(){
        
    }
    
    func likeEvent(){
        
    }
    
    func shareEvent(){
        
    }
    
    func eventPayment(){
        
    }
    
}
