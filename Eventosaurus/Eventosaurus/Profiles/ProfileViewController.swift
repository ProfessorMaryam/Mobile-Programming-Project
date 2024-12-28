//
//  ProfileViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed  on 28/12/2024.
//

import UIKit
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData() 
    }
    
    func loadUserData() {
        let userEmail = User.loggedInemail
        
        db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents,
                  let document = documents.first else {
                print("User document not found")
                return
            }
            
            // Get the full name
            let fullName = document.get("Full Name") as? String ?? ""
            
            // Get the brief, use default message if nil or empty
            let brief = document.get("Brief") as? String
            let briefText = (brief?.isEmpty ?? true) ? "You should add a description!" : brief!
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self?.name.text = fullName
                self?.briedText.text = briefText
            }
        }
    }
    
    @IBOutlet weak var briedText: UITextView!
    @IBOutlet weak var name: UILabel!
}
