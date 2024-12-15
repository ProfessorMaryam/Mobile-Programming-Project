////
////  AdminPageTableViewController.swift
////  Eventosaurus
////
////  Created by BP-36-201-15 on 14/12/2024.
////
//
//import UIKit
//
//class AdminPageTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
//
//    //This code was taken from a tutorial called "TableView with Custom Cells in Swift" by iOS Academy
//    //The tutorial code spans this class, its respective view controller, the XIB AdminTVC file and its Coaca touch class "AdminTVC"
//    
//    @IBOutlet var tableView : UITableView!
//    
//    let myData = ["Events", "Users", "Categories", "Logout"]
//    let myImages = ["gamecontroller.fill", "person.fill", "folder.fill", "arrowshape.forward.fill"]
//
//
//    
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        let nib = UINib(nibName: "AdminTVC", bundle: nil) //defining the nib
//        
//        tableView.register(nib, forCellReuseIdentifier: "AdminTVC") //registering the nib
//  
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 110 //define the height of the cells
//    }
//
//    // TableView Functions
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return myData.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminTVC", for: indexPath) as! AdminTVC
//        
//        cell.myButton.setTitle(myData[indexPath.row], for: .normal) //setting the titles of the buttons using the strings in myData list
//        cell.myButton.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .bold) // Larger and bold font
//        cell.myButton.tintColor = .purple
//        
//        let symbolName = myImages[indexPath.row]
//        cell.myImage.image = UIImage(systemName: symbolName)
//        cell.myImage.tintColor = .purple
//        
//        // Handle button tap action
//           cell.buttonAction = { [weak self] in
//               self?.navigateToPage(for: indexPath.row)
//           }
//        
//        
//        
//        //cell.myImage.backgroundColor = .red
//        return cell //returning the cells one by one in the table view
//    }
//    
//    func navigateToPage(for index: Int) {
//        switch index {
//        case 0:
//            // Navigate to Events Page
//            let eventsVC = EventsDisplayController() // Replace with your actual view controller
//            self.navigationController?.pushViewController(eventsVC, animated: true)
//        case 1:
//            // Navigate to Users Page
//            let usersVC = UsersDisplayController()
//            self.navigationController?.pushViewController(usersVC, animated: true)
//        case 2:
//            // Navigate to Categories Page
//            let categoriesVC = InterestsDisplayPage()
//            self.navigationController?.pushViewController(categoriesVC, animated: true)
//        case 3:
//            // Navigate to Logout or Show Confirmation
//            let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
//                // Handle logout logic
//                print("Logged out")
//            }))
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            self.present(alert, animated: true)
//        default:
//            break
//        }
//    }
//
//    
//    
//
//}



import UIKit

class AdminPageTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //This code was taken from a tutorial called "TableView with Custom Cells in Swift" by iOS Academy
    //The tutorial code spans this class, its respective view controller, the XIB AdminTVC file and its Coaca touch class "AdminTVC"

    @IBOutlet var tableView: UITableView!

    let myData = ["Events", "Users", "Categories", "Logout"] //this defines the labels of the button which will take to their respective pages
    let myImages = ["gamecontroller.fill", "person.fill", "folder.fill", "arrowshape.forward.fill"]  //defines the names of the images to be displayed next to their respective buttons

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "AdminTVC", bundle: nil) // Load the custom cell NIB
        tableView.register(nib, forCellReuseIdentifier: "AdminTVC") // Register the cell

    }
    
    
    // TableView Functions

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110 // Height for each cell
    }

    // TableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myData.count //returns the count of elements inside the myData list
    }

    // Configure cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminTVC", for: indexPath) as! AdminTVC //dequeuing the cells

        // Set the button title from myData array
        cell.myButton.setTitle(myData[indexPath.row], for: .normal) //setting the titles of the buttons using the strings in myData list
        cell.myButton.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        cell.myButton.tintColor = .purple // changes the color of the button title
        
       
        let symbolName = myImages[indexPath.row]
        cell.myImage.image = UIImage(systemName: symbolName)
        cell.myImage.tintColor = .purple

        // Assign the closure to handle button taps
        cell.buttonAction = { [weak self] in
            self?.navigateToPage(for: indexPath.row)
        }

        return cell
    }

    // this function is for determining whch view controller to switch to depending on the button clicked
    func navigateToPage(for index: Int) {
        let storyboard = UIStoryboard(name: "AdminPage", bundle: nil) // stores the AdminPage in a varible to be used in the case switch

        switch index {
        case 0:
            // takes to events display page
            if let eventsVC = storyboard.instantiateViewController(withIdentifier: "EventsVC") as? EventsDisplayController {
                self.navigationController?.pushViewController(eventsVC, animated: true)
            }
        case 1:
            // takes to users display page
            if let usersVC = storyboard.instantiateViewController(withIdentifier: "UsersVC") as? UsersDisplayController {
                self.navigationController?.pushViewController(usersVC, animated: true)
            }
        case 2:
            // takes to catergories / events page
            if let categoriesVC = storyboard.instantiateViewController(withIdentifier: "CategoriesVC") as? InterestsDisplayPage {
                self.navigationController?.pushViewController(categoriesVC, animated: true)
            }
        case 3:
            // log out option
            let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                // Handle logout logic here
                print("Logged out")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        default:
            break
        }
    }

}
