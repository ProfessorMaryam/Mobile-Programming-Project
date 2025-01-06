//
//  UserViewOrgNavController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed on 28/12/2024.
//

import UIKit

// Navigation controller that manages the transition to the UserViewOrgViewController
class UserViewOrgNavController: UINavigationController {
    var organizerEmail: String = "" // Organizer's email address to be passed to the next view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the storyboard that contains UserViewOrgViewController
        let storyboard = UIStoryboard(name: "Profile", bundle: nil) // Ensure the storyboard name matches your project
        
        // Instantiate UserViewOrgViewController from that storyboard
        if let userViewOrgVC = storyboard.instantiateViewController(withIdentifier: "UserViewOrgViewController") as? UserViewOrgViewController {
            
            // Pass the organizer's email to the UserViewOrgViewController
            userViewOrgVC.organizerEmail = self.organizerEmail
            
            // Set UserViewOrgViewController as the root view controller of the navigation stack
            setViewControllers([userViewOrgVC], animated: false) // Animated is false to avoid unnecessary animations during the initial setup
        }
    }
    
    /*
    // MARK: - Navigation
    // Use this section to handle navigation-related preparations if needed in the future
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
