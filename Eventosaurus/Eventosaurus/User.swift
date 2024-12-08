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
    var userID : Int
    static var idIncrement : Int =  1000
    
    //var isOrganizer: Bool
    
    
    
    ///Constructor is used in registration
    
    init(username: String, fullName: String, email: String, dateOfBirth: String, password: String) {
        self.username = username
        self.fullName = fullName
        self.email = email
        self.dateOfBirth = dateOfBirth
        self.password = password
        
        userID = User.idIncrement
        User.idIncrement+=1
            }
    
    func login(username: String? = nil , email: String? = nil , password : String) -> Bool {
        
        
        guard username != nil || email != nil else {
            print("Error")
            return false
        }
        
        if((self.username == username || self.email == email) && self.password == password){
            print("lOGIN SUCCESS")
            return true
        }else{
            print("Access Denied")
            return false
        }
        
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
