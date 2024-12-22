//
//  LeaveEventPageViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-15 on 10/12/2024.
//

import UIKit

class LeaveEventPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func leaveBtn(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Withdraw", message: "Are you sure you want to withdraw from this event?", preferredStyle: .alert)
                
                let withdrawAction = UIAlertAction(title: "Withdraw", style: .destructive) { _ in
                    // Handle withdraw action here
                    print("User chose to withdraw.")
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    // Handle cancel action here
                    print("Withdrawing from event canceled.")
                }
                
                alertController.addAction(withdrawAction)
                alertController.addAction(cancelAction)
                
                present(alertController, animated: true, completion: nil)
            }
    }

