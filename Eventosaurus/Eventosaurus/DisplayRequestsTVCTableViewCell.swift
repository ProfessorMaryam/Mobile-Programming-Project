//
//  DisplayRequestsTVCTableViewCell.swift
//  Eventosaurus
//
//  Created by Natheer work on 18/12/2024.
//

import UIKit

class DisplayRequestsTVCTableViewCell: UITableViewCell {

    @IBOutlet weak var AcceptButton: UIButton!
    @IBOutlet weak var displayEmail: UILabel!
    @IBOutlet weak var qualifications: UILabel!
    @IBOutlet weak var displayMessage: UILabel!
    @IBOutlet weak var DisplayName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
