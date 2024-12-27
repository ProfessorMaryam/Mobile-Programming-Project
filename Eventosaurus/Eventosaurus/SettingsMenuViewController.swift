//
//  SettingsMenuViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-04 on 27/12/2024.
//

import UIKit

class SettingsMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    @IBAction func SignOutButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            // Step 1: Clear UserDefaults data
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            UserDefaults.standard.synchronize()  // Ensure UserDefaults is saved

            // Step 2: Dismiss the current view controller and navigate to the login screen
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "Entry") as? UINavigationController {
                // Ensure you're pushing the loginVC into the navigation stack
                // You can only push from a view controller inside a UINavigationController
                if let navController = self.navigationController {
                    // Push to the login screen using navigation
                    navController.pushViewController(loginVC, animated: true)
                } else {
                    // If there's no navigation controller (e.g., modal or root VC), present it modally
                    loginVC.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Step 3: Present the alert to confirm logout
        self.present(alert, animated: true)
    }
}
