//
//  OrganizerProfileViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed  on 28/12/2024.
//

import UIKit
import Firebase

class OrganizerProfileViewController: UIViewController {
    
    let db = Firestore.firestore()
    @IBOutlet weak var follwerstxt: UILabel!
    
    @IBOutlet weak var followingtxt: UILabel!
    
    
    @IBOutlet weak var nametxt: UILabel!
    
    @IBOutlet weak var Brieftxt: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
                self?.nametxt.text = fullName
                self?.Brieftxt.text = briefText
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
