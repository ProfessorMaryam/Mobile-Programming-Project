//
//  DisplayUsersTableViewCell.swift
//  Eventosaurus
//
//  Created by BP-36-201-15 on 17/12/2024.
//

import UIKit

class DisplayUsersTableViewCell: UITableViewCell {

   
  
    @IBOutlet weak var NameDisplayLbl: UILabel!
    
    @IBOutlet weak var EmailDisplayLbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
