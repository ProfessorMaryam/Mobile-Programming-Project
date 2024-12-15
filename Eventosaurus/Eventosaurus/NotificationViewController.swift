//
//  NotificationViewController.swift
//  Eventosaurus
//
//  Created by Hx on 14/12/2024.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var nameArray: [String] = []
    var imageArray: [UIImage] = []
    var descriptionArray: [String] = []

    override func viewDidLoad() {super.viewDidLoad()
        
        nameArray = ["Fun Land"]
        imageArray = [UIImage(systemName: "gear")!]
        descriptionArray = ["This is a test"]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! notificationTableViewCell
        
        cell.eventImage.image = imageArray[indexPath.row]
        cell.eventTitle.text = nameArray[indexPath.row]
        
        return cell
    }

}
