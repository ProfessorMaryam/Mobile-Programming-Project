//
//  AdminTVC.swift
//  Eventosaurus
//
//  Created by BP-36-201-15 on 14/12/2024.
//

import UIKit

class AdminTVC: UITableViewCell {
    
    @IBOutlet var myButton : UIButton! //button outlet from the XIB file
    @IBOutlet var myImage : UIImageView! //image view to hold the icons for every button

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var buttonAction: (() -> Void)?
        
        @IBAction func buttonTapped(_ sender: UIButton) {
            buttonAction?() // Call the closure when the button is tapped
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}



