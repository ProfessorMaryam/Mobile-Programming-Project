//
//  HomePageViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-21 on 04/12/2024.
//

import UIKit

class HomePageViewController: UIViewController {
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
      
        
        
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

class FilterSearchViewController: UIViewController {
    
    @IBOutlet weak var HAbutton: UIButton!
    
    @IBOutlet weak var SPButton: UIButton!
    
    @IBOutlet weak var FNButton: UIButton!
    
    @IBOutlet weak var ENButton: UIButton!
    
    @IBOutlet weak var ARButton: UIButton!
    
    @IBOutlet weak var CMButton: UIButton!
    
    @IBOutlet weak var MSButton: UIButton!
    
    @IBOutlet weak var LTButton: UIButton!
    
    @IBOutlet weak var PHButton: UIButton!
    
    @IBOutlet weak var EDButton: UIButton!
    
    @IBOutlet weak var SLButton: UIButton!
    
    @IBOutlet weak var FDButton: UIButton!
    
    
    
    @IBOutlet weak var NRButton: UIButton!
    
    @IBOutlet weak var CLButton: UIButton!
    
    @IBOutlet weak var MQButton: UIButton!
    
    @IBOutlet weak var SRButton: UIButton!
    
    
    
    
    @IBOutlet weak var WEButton: UIButton!
    
    @IBOutlet weak var MOButton: UIButton!
    
    
    
    
    var HAChecked = false

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func HATapped(_ sender: UIButton) {
        HAChecked = !HAChecked
        let imageName = HAChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        HAbutton.setImage(image, for: .normal)
    }
    
    @IBAction func PHTapped(_ sender: UIButton) {
    }
    
    @IBAction func SPTapped(_ sender: UIButton) {
    }
    
    @IBAction func FNTapped(_ sender: UIButton) {
    }
    
    @IBAction func ENTapped(_ sender: Any) {
    }
    
    @IBAction func ARTapped(_ sender: Any) {
    }
    
    @IBAction func CMTapped(_ sender: UIButton) {
    }
    
    @IBAction func EDTapped(_ sender: UIButton) {
    }
    
    @IBAction func SLTapped(_ sender: UIButton) {
    }
    
    @IBAction func FDTapped(_ sender: UIButton) {
    }
    
    @IBAction func LRTapped(_ sender: Any) {
    }
    
    @IBAction func MSTapped(_ sender: UIButton) {
    }
    
    
    
    @IBAction func NRTapped(_ sender: UIButton) {
    }
    
    
    @IBAction func CLTapped(_ sender: UIButton) {
    }
    
    @IBAction func MQTapped(_ sender: UIButton) {
    }
    
    @IBAction func SRTapped(_ sender: UIButton) {
    }
    
    
    
    
    @IBAction func WETapped(_ sender: UIButton) {
    }
    
    @IBAction func MOTapped(_ sender: UIButton) {
    }
    
    
    
}


