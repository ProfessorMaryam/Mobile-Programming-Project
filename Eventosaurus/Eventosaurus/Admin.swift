//
//  Admin.swift
//  Eventosaurus
//
//  Created by BP-36-201-14 on 01/12/2024.
//

import Foundation

class Admin{
    
    static let shared = Admin(id: "0", name: "Admin", email: "EventosaurausAdmin@Example.com")
    
    private var id : String
    private var name: String
    private var email: String
    
    
    private init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
                              
    func createUser(){
        
    }
    
    func banUser(){
        
    }
    
    func addEvent(){
        
    }
    
    func banEvent(){
        
    }
    
    func editEvent(){
        
    }
    
    func (){
        
    }
                              
}
