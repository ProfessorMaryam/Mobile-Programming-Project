//
//  FeedbackTableViewCell.swift
//  Eventosaurus
//
//  Created by BP-36-201-04 on 27/12/2024.
//

import UIKit

class FeedbackTableViewCell: UITableViewCell {

    @IBOutlet weak var stars: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // Configure the cell with feedback data
    func configure(with feedback: String, stars: Int) {
        feedbackLabel.text = feedback
        self.stars.text = "⭐️ \(stars)"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
