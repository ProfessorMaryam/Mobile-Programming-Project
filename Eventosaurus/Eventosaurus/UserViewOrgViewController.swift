//
//  UserViewOrgViewController.swift
//  Eventosaurus
//
//  Created by Manaf Mohamed on 15/12/2024.
//

import UIKit



class UserViewOrgViewController: UIViewController {

    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var follow: UIButton!
    
    var isfollowing = false
    var followerCount = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isfollowing = false
        followerCount = 0
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func followersTapped(_ sender: UIButton){
        isfollowing.toggle()
        
        if isfollowing{
            followerCount += 1
            
        } else {
            followerCount -= 1
            
        }
        
        updateUI()
    }

    func updateUI(){
        
        let buttonTitle = isfollowing ? "Following" : "Follow"
        follow.setTitle(buttonTitle, for: .normal)
        DispatchQueue.main.async{
            self.followers.text = "\(self.followerCount)"
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
