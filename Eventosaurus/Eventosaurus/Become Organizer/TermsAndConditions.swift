//
//  TermsAndConditions.swift
//  Eventosaurus
//
//  Created by BP-36-201-14 on 10/12/2024.
//

import UIKit

class TermsAndConditions: UIViewController {
    
    //Nothing much here, just a keeping the next button diabled until user agrees to the terms and conditions. Once they do they the next button is enabled and they are taken to the request form

    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var checkButton: UIButton!
    var isChecked = false
    @IBAction func CheckTapped(_ sender: Any) {
        isChecked = !isChecked
              
              // Set the appropriate SF Symbol image based on the state
              let imageName = isChecked ? "checkmark.square.fill" : "square"
              let image = UIImage(systemName: imageName)
              
              // Set the button's image
              checkButton.setImage(image, for: .normal)
              nextButton.isEnabled = isChecked
    }
  

}
