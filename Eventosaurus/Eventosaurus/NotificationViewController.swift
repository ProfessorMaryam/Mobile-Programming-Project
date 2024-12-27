//
//  NotificationViewController.swift
//  Eventosaurus
//
//  Created by Hx on 14/12/2024.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray: [String] = []
    var imageArray: [UIImage] = []
    var descriptionArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameArray = ["Fun Land"]
        imageArray = [UIImage(systemName: "gear")!]
        descriptionArray = ["This is a test"]
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! notificationTableViewCell
        
        let originalImage = imageArray[indexPath.row]
            
        // Resize the image
        _ = resizeImage(image: originalImage, targetSize: CGSize(width: 50, height: 100))
        
        cell.eventImage.image = imageArray[indexPath.row]
        cell.eventTitle.text = nameArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine the scale factor to maintain aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new size
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // Resize the image
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }

}
