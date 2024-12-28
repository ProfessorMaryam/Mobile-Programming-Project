//
//  UserViewOrgNavController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed  on 28/12/2024.
//

import UIKit

class UserViewOrgNavController: UINavigationController {
    var organizerEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the storyboard that contains UserViewOrgViewController
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        
        // Instantiate UserViewOrgViewController from that storyboard
        if let userViewOrgVC = storyboard.instantiateViewController(withIdentifier: "UserViewOrgViewController") as? UserViewOrgViewController {
            // Pass the email
            userViewOrgVC.organizerEmail = self.organizerEmail
            
            // Set it as the root view controller
            setViewControllers([userViewOrgVC], animated: false)
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


