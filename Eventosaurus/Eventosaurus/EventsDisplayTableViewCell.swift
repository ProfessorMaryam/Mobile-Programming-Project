//
//  EventsDisplayTableViewCell.swift
//  Eventosaurus
//
//  Created by BP-36-201-06 on 18/12/2024.
//

import UIKit

class EventsDisplayTableViewCell: UITableViewCell {

    
    @IBOutlet weak var Eventname: UILabel!
    
    @IBOutlet weak var organizerName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
