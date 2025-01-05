//
//  FeedbackTableViewCell.swift
//  Eventosaurus
//
//  Created by BP-36-201-04 on 27/12/2024.
//

import UIKit
import FirebaseFirestore
import Firebase

class FeedbackTableViewCell: UITableViewCell {

    @IBOutlet weak var stars: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    override func awakeFromNib() {
           super.awakeFromNib()
       }

       // Configure the cell with feedback data
       func configure(with feedback: String, stars: Int) {
           feedbackLabel.text = feedback  // Set the feedback text
           self.stars.text = "⭐️ \(stars)"  // Set the star rating
       }
       
   }
