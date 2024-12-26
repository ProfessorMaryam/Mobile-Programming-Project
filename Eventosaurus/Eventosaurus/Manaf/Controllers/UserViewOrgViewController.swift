//
//  UserViewOrgViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed on 25/12/2024.
//

import UIKit

class UserViewOrgViewController: UIViewController {
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var labelFollowers: UILabel!
    
    var followerCount: Int {
            get {
                // Retrieve follower count from UserDefaults or default to 100 if not found
                return UserDefaults.standard.integer(forKey: "followerCount")
            }
            set {
                // Save the new follower count to UserDefaults
                UserDefaults.standard.set(newValue, forKey: "followerCount")
            }
        }
    
    
    var isFollowing = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelFollowers.text = "\(followerCount)"
        
        followButton.setTitle(isFollowing ? "Following" : "Follow", for: .normal)
           
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let organizerProfileVC = segue.destination as? OrganizerProfileViewController {
            organizerProfileVC.followerCount = followerCount
        }
        
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        
        if isFollowing {

            followButton.setTitle("Follow", for: .normal)
            followerCount -= 1
            isFollowing = false
            
        } else {
         
            followButton.setTitle("Following", for: .normal)
            followerCount += 1
            isFollowing = true
            
        }
        labelFollowers.text = "\(followerCount)"
    }
}
