//
//  Event.swift
//  Eventosaurus
//
//  Created by BP-36-201-14 on 01/12/2024.
//

import Foundation

enum EventStatus {
    case upcoming
    case ongoing
    case cancelled
    case completed
}

class Event {
    
    //contains an array of users in a particular instance of event
    
    var users:[User] = []
    
}
