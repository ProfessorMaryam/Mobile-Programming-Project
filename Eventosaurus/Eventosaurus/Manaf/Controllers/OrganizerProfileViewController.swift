//
//  OrganizerProfileViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed on 25/12/2024.
//

import UIKit

class OrganizerProfileViewController: UIViewController {

    @IBOutlet weak var followersLabel: UILabel!
    
    var followerCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if followerCount == nil {
                   followerCount = UserDefaults.standard.integer(forKey: "followerCount")
               }
        
        followersLabel.text = "\(followerCount ?? 0) Followers"
            
        }
        
    }

