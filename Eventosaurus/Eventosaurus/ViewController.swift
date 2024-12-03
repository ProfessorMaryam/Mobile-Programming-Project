//
//  ViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-14 on 01/12/2024.
//

import UIKit



class ViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    let newUser =  User(username: "mrfjm", fullName: "Manaf Mohamed", email: "mrfjm2@gmail.com", dateOfBirth: "17/03/2004", password: "password")
    
    //newUser.login(username: "mrfjm", password: "password")
    
    
    let event = Event(status:.completed, name: "Food Festival", description: "Food Festival this that this that", date: "31-06-2024", organizers: "organizer 1", maximumAttendees: 200);

    
    //event.addUser(user: newUser)

}

