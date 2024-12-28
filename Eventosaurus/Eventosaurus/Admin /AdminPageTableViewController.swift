////
////  AdminPageTableViewController.swift
////  Eventosaurus
////
////  Created by BP-36-201-15 on 14/12/2024.
////


import UIKit

class AdminPageTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //This code was taken from a tutorial called "TableView with Custom Cells in Swift" by iOS Academy
    //The tutorial code spans this class, its respective view controller, the XIB AdminTVC file and its Coaca touch class "AdminTVC"

    @IBOutlet var tableView: UITableView!

    let myData = ["Events", "Users", "Categories", "Requests", "Logout"] //this defines the labels of the button which will take to their respective pages
    let myImages = ["gamecontroller.fill", "person.fill", "folder.fill","person.fill.questionmark" ,"arrowshape.forward.fill"]  //defines the names of the images to be displayed next to their respective buttons

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "AdminTVC", bundle: nil) // Load the custom cell NIB
        tableView.register(nib, forCellReuseIdentifier: "AdminTVC") // Register the cell

    }
    
    
    // TableView Functions

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90 // Height for each cell
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
        let storyboard = UIStoryboard(name: "AdminPage", bundle: nil)

        switch index {
        case 0: //if cell at index 0 is clicked....
            if let eventsVC = storyboard.instantiateViewController(withIdentifier: "EventsVC") as? EventsDisplayController {
                eventsVC.title = "Events"
                self.navigationController?.pushViewController(eventsVC, animated: true)
            }
        case 1: //if cell at index 1 is clicked....
            if let usersVC = storyboard.instantiateViewController(withIdentifier: "UsersVC") as? UsersDisplayController {
                usersVC.title = "Users"
                self.navigationController?.pushViewController(usersVC, animated: true)
            }
        case 2: //if cell at index 2 is clicked....
            if let categoriesVC = storyboard.instantiateViewController(withIdentifier: "InterestsVC") as? InterestsDisplayPage {
                categoriesVC.title = "Categories"
            }
        case 3: //if cell at index 3 is clicked....
            if let requestsVC = storyboard.instantiateViewController(withIdentifier: "RequestsVC") as? RequestsViewController {
                requestsVC.title = "Requests"
                self.navigationController?.pushViewController(requestsVC, animated: true)
            }
        case 4: //if cell at index 4 is clicked....
            // Logout Implementation
            let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                // Clear the login state in UserDefaults
                UserDefaults.standard.set(false, forKey: "isLoggedIn") 
                UserDefaults.standard.set(false, forKey: "isAdmin")
                UserDefaults.standard.synchronize()

                // Navigate back to the login screen
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "MainVC") as? ViewController {
                    // Reset the navigation stack to ensure the user cannot go back to the admin page
                    self.navigationController?.setViewControllers([loginVC], animated: true)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        default:
            break
        }
    }

    }


