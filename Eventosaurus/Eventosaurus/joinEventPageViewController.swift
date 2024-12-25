//
//  joinEventPageViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-07 on 04/12/2024.
//

import UIKit

class joinEventPageViewController: UIViewController {
    
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
    
    @IBAction func payBtn(_ sender: UIButton) {
            let alertController = UIAlertController(title: "Payment Successful", message: "Payment has been done successfully.", preferredStyle: .alert)
            
            let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
                // Handle any actions when the user taps "Done" here
                print("Done.")
            }
            
            alertController.addAction(doneAction)
            
            present(alertController, animated: true, completion: nil)
    }
}
