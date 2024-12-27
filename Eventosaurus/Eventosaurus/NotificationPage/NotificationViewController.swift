//
//  NotificationViewController.swift
//  Eventosaurus
//
//  Created by Hx on 14/12/2024.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Arrays to hold event data
    var nameArray: [String] = []
    var imageArray: [UIImage] = []
    var descriptionArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tableView delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    // Cell for row at indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < nameArray.count,
              indexPath.row < imageArray.count,
              indexPath.row < descriptionArray.count else {
            fatalError("Error: Index out of bounds for data arrays.")
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as? notificationTableViewCell else {
            fatalError("Error: Unable to dequeue cell with identifier 'NotificationCell'.")
        }
        
        let originalImage = imageArray[indexPath.row]
        let resizedImage = resizeImage(image: originalImage, targetSize: CGSize(width: 50, height: 50))
        
        cell.eventImage.image = resizedImage
        cell.eventTitle.text = nameArray[indexPath.row]
        cell.eventDescription.text = descriptionArray[indexPath.row]
        
        return cell
    }
    
    // Row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // Helper function to resize images
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        guard size.width > 0, size.height > 0 else {
            print("Error: Invalid image dimensions \(size). Returning original image.")
            return image
        }
        
        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine the scale factor to maintain aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new size
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // Resize the image
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
}
