//
//  notificationTableViewCell.swift
//  Eventosaurus
//
//  Created by Hx on 15/12/2024.
//

import UIKit

class notificationTableViewCell: UITableViewCell {
    
    // Outlets for event data
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
