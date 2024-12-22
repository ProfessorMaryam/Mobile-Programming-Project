//
//  HomePageViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-21 on 04/12/2024.
//

import UIKit

import FirebaseFirestore






class HomePageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
    }
    
    
}









class WriteFeedbackViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
}








class DisplayNameViewController: UIViewController {
    
    @IBOutlet weak var CategoryName: UILabel!
    
    @IBOutlet weak var EventNameL: UILabel!
    
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetch a random event name from Firestore
        showFeedbackAlert()
        fetchRandomEvent()
    }
    
    @IBAction func buttonShow(_ sender: UIButton) {
        showFeedbackAlert()
    }
    
    func showFeedbackAlert() {
        // Create the alert controller
        let alertController = UIAlertController(title: "How did you find today's event?", message: nil, preferredStyle: .alert)
        
        // Add a custom star rating view
        let starRatingView = UIStackView()
        starRatingView.axis = .horizontal
        starRatingView.distribution = .fillEqually
        starRatingView.spacing = 5
        
        for _ in 0..<5 {
            let starButton = UIButton(type: .system)
            starButton.setTitle("★", for: .normal)
            starButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            starButton.tintColor = .lightGray
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starRatingView.addArrangedSubview(starButton)
        }
        
        // Convert starRatingView to UIViewController to add to the alert
        let hostingController = UIViewController()
        hostingController.view = starRatingView
        hostingController.preferredContentSize = CGSize(width: 200, height: 50)
        
        alertController.setValue(hostingController, forKey: "contentViewController")
        
        // Add "Feedback" button
        let feedbackAction = UIAlertAction(title: "Feedback", style: .default) { _ in
            print("Feedback button tapped")
            self.navigateToFeedbackPage()
        }
        alertController.addAction(feedbackAction)
        
        // Add "Cancel" and "Confirm" actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            print("Confirm button tapped")
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        // Present the alert
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func starTapped(_ sender: UIButton) {
        // Handle star tap logic, e.g., change the tint color for selected stars
        guard let stackView = sender.superview as? UIStackView else { return }
        
        for star in stackView.arrangedSubviews {
            if let button = star as? UIButton {
                button.tintColor = .lightGray
            }
        }
        
        // Highlight stars up to the tapped one
        if let index = stackView.arrangedSubviews.firstIndex(of: sender) {
            for i in 0...index {
                if let button = stackView.arrangedSubviews[i] as? UIButton {
                    button.tintColor = .systemYellow
                }
            }
        }
    }
    func fetchRandomEvent() {
        // Reference to the "events" collection in Firestore
        db.collection("Events").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching events: \(error)")
                return
            }
            
            // Check if we have documents in the snapshot
            guard let documents = snapshot?.documents, documents.count > 0 else {
                print("No events found.")
                return
            }
            
            // Randomly pick an event from the documents
            let randomIndex = Int.random(in: 0..<documents.count)
            let randomEvent = documents[randomIndex]
            
            // Extract the event name from the document data
            if let eventName = randomEvent.data()["Event Name"] as? String {
                // Set the event name on the label
                self.EventNameL.text = eventName
            } else {
                print("Event Name not found in the document.")
                return
            }
            
            // Extract the category reference
            if let categoryRef = randomEvent.data()["Category"] as? DocumentReference {
                // Fetch the category document using the reference
                categoryRef.getDocument { (categorySnapshot, error) in
                    if let error = error {
                        print("Error fetching category: \(error)")
                        return
                    }
                    
                    // Check if the category document exists
                    if let categorySnapshot = categorySnapshot, categorySnapshot.exists {
                        // Extract the category name from the category document
                        if let categoryName = categorySnapshot.data()?["Category Name"] as? String {
                            // Set the category name on the label
                            self.CategoryName.text = categoryName
                        } else {
                            print("Category Name not found in the document.")
                        }
                    } else {
                        print("Category document does not exist.")
                    }
                }
            } else {
                print("Category reference not found in the event document.")
            }
        }
    }
    func navigateToFeedbackPage() {
        // Navigate to the feedback page
        let storyboard = UIStoryboard(name: "WriteFeedbackViewController", bundle: nil) // Replace "Main" with your actual storyboard name
        if let feedbackVC = storyboard.instantiateViewController(withIdentifier: "WriteFeedbackViewController") as? WriteFeedbackViewController {
            feedbackVC.modalPresentationStyle = .fullScreen // Optional: Set presentation style
            present(feedbackVC, animated: true, completion: nil)
        } else {
            print("WriteFeedbackViewController not found in storyboard")
        }
    }}
    
    











class EventHomeViewController: UIViewController {
    
    @IBOutlet weak var collectionoView: UICollectionView!
    
    // Define properties to store event data
    let db = Firestore.firestore()
    
    var eventNames: [String] = []
    var eventCategories: [String] = [] // Store the category names
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionoView.dataSource = self
        collectionoView.delegate = self
        collectionoView.collectionViewLayout = UICollectionViewFlowLayout()
        
        
        fetchEvents()
        
    }
    
    func fetchEvents() {
        db.collection("Events").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching events: \(error)")
                return
            }
            
            // Check if we have any documents
            guard let documents = snapshot?.documents, documents.count > 0 else {
                print("No events found.")
                return
            }
            
            // Clear previous data
            self.eventNames.removeAll()
            self.eventCategories.removeAll()
            
            // Map documents to event data arrays
            documents.forEach { document in
                let data = document.data()
                
                // Debugging: Log the data to check the fields
                print("Fetched document data: \(data)")
                
                let eventName = data["Event Name"] as? String ?? "Unnamed Event"
                
                // Fetch the Category document reference
                if let categoryRef = data["Category"] as? DocumentReference {
                    // Fetch the category document using the reference
                    categoryRef.getDocument { (categorySnapshot, error) in
                        if let error = error {
                            print("Error fetching category: \(error)")
                            return
                        }
                        
                        // Check if the category document exists
                        if let categorySnapshot = categorySnapshot, categorySnapshot.exists {
                            // Extract the category name from the category document
                            if let categoryName = categorySnapshot.data()?["Category Name"] as? String {
                                // Debugging: Log the event name and category
                                print("Event Name: \(eventName), Category Name: \(categoryName)")
                                
                                // Add data to arrays
                                self.eventNames.append(eventName)
                                self.eventCategories.append(categoryName)
                                
                                // Reload collection view after fetching events (inside the completion handler)
                                self.collectionoView.reloadData()
                            }
                        }
                    }
                } else {
                    // If there is no valid category reference, fall back to default category
                    let defaultCategory = "General"
                    self.eventNames.append(eventName)
                    self.eventCategories.append(defaultCategory)
                    
                    // Reload collection view after fetching events (inside the completion handler)
                    self.collectionoView.reloadData()
                }
            }
        }
    }
    
    }

    


    
    
    // Clear previous event data
    

// MARK: - UICollectionView DataSource
extension EventHomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return eventNames.count  // Return the count of events
       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCell", for: indexPath) as! EventCollectionViewCell
            
            let eventName = eventNames[indexPath.row]
            let eventCategory = eventCategories[indexPath.row] // Get the category for this event
            
            // Debugging: Log to check the values being passed to the cell
            print("Event Name in cell: \(eventName), Event Category in cell: \(eventCategory)")
            
            // Populate the cell with event data
            cell.setup(with: eventName, category: eventCategory)
            
            return cell
        }
}




// MARK: - UICollectionView DelegateFlowLayout
extension EventHomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 352, height: 150)
    }
}



// MARK: - UICollectionView Delegate
extension EventHomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                print("Event selected: \(eventNames[indexPath.row])")
            }
}



// MARK: - EventCollectionViewCell
class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func setup(with eventName: String, category: String) {
            titleLabel.text = eventName
            setImageForCategory(category)
        }
        
        private func setImageForCategory(_ category: String) {
            print("Setting image for category: \(category)") // Debug log
            
            switch category {
            case "Music":
                eventImageView.image = UIImage(named: "Music.png")
            case "Sports":
                eventImageView.image = UIImage(named: "Sports.png")
            case "Entertainment":
                eventImageView.image = UIImage(named: "Entertaintment.png")
            case "Comedy":
                eventImageView.image = UIImage(named: "Comedy.png")
            case "Health Wellness":
                eventImageView.image = UIImage(named: "Health.png")
            case "Social":
                eventImageView.image = UIImage(named: "Social.png")
            case "Art & Literature":
                eventImageView.image = UIImage(named: "Art.png")
            case "Education":
                eventImageView.image = UIImage(named: "Education.png")
            case "Food":
                eventImageView.image = UIImage(named: "Food.png")
            case "Fashion":
                eventImageView.image = UIImage(named: "Fashion.png")
            default:
                eventImageView.image = UIImage(named: "Social.png")
            }
        }
    }





















/////////////////////////////
///////////////////////////////
///////////////////////////////
///
///
///
///
///
///
///class FilterDataManager {

class FilterDataManager {
    static let shared = FilterDataManager()  // Singleton instance
    
    // Store event data
    var eventNames: [String] = []
    var eventCategories: [String] = []
    var eventLocations: [String] = []
    
    // Store selected filters
    var selectedCategories: [String] = []
    var selectedLocations: [String] = []
    
    // Store the filtered events
    var filteredEventNames: [String] = []
    
    let db = Firestore.firestore()
    
    // Fetch events from Firestore and filter based on the selected categories and locations
    func fetchEvents() {
        db.collection("Events").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching events: \(error)")
                return
            }
            
            // Check if we have any documents
            guard let documents = snapshot?.documents, documents.count > 0 else {
                print("No events found.")
                return
            }
            
            // Clear previous data
            self.eventNames.removeAll()
            self.eventCategories.removeAll()
            self.eventLocations.removeAll()
            
            // Map documents to event data arrays
            documents.forEach { document in
                let data = document.data()
                let eventName = data["Event Name"] as? String ?? "Unnamed Event"
                let location = (data["Description"] as? String)?
                    .split(separator: " ")
                    .first.map { String($0) } ?? "Unknown Location"

                
                // Fetch the Category document reference
                if let categoryRef = data["Category"] as? DocumentReference {
                    categoryRef.getDocument { (categorySnapshot, error) in
                        if let error = error {
                            print("Error fetching category: \(error)")
                            return
                        }
                        
                        // Check if the category document exists
                        if let categorySnapshot = categorySnapshot, categorySnapshot.exists {
                            // Extract the category name from the category document
                            if let categoryName = categorySnapshot.data()?["Category Name"] as? String {
                                // Add the data to arrays
                                self.eventNames.append(eventName)
                                self.eventCategories.append(categoryName)
                                self.eventLocations.append(location)
                                
                                // After fetching all events, apply the current filters
                                self.applyFilters()
                            }
                        }
                    }
                } else {
                    // If there's no valid category reference, fall back to default category
                    let defaultCategory = "General"
                    self.eventNames.append(eventName)
                    self.eventCategories.append(defaultCategory)
                    self.eventLocations.append(location)
                    
                    // Apply filters immediately after adding the event data
                    self.applyFilters()
                }
            }
        }
    }
    
    func applyFilters() {
           // If no categories are selected, show all events
           if selectedCategories.isEmpty {
               filteredEventNames = eventNames
           } else {
               filteredEventNames = []
               for (index, eventName) in eventNames.enumerated() {
                   let category = eventCategories[index]
                   let location = eventLocations[index]
                   if selectedCategories.contains(category) && (selectedLocations.isEmpty || selectedLocations.contains(location)) {
                       filteredEventNames.append(eventName)
                   }
               }
           }
       }
       
       // Reset the filters
       func resetFilters() {
           selectedCategories.removeAll()
           selectedLocations.removeAll()
           applyFilters()
       }
   }














class EventSearchViewController: UIViewController, UISearchBarDelegate, FilterSearchViewControllerDelegate {
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectioniView: UICollectionView!
    let db = Firestore.firestore()
        
        var eventNames: [String] = []
        var filteredEventNames: [String] = []
        var eventCategories: [String] = []
        var selectedCategories: [String] = []
        var selectedLocations: [String] = []
    
    override func viewDidLoad() {
            super.viewDidLoad()
            collectioniView.dataSource = self
            collectioniView.delegate = self
            collectioniView.collectionViewLayout = UICollectionViewFlowLayout()
            searchBar.delegate = self
            FilterDataManager.shared.fetchEvents()
                    
                    // Reload the collection view after fetching and filtering events
                    collectioniView.reloadData()
                }
        
        @IBAction func filterShow(_ sender: Any) {
            
            let filterVC = FilterSearchViewController()
                    filterVC.delegate = self  // Set the delegate
               
        }

    func didUpdateFilters(selectedCategories: [String], selectedLocations: [String]) {
           FilterDataManager.shared.selectedCategories = selectedCategories
                  FilterDataManager.shared.selectedLocations = selectedLocations
                  
                  // Reapply filters and update the collection view
                  FilterDataManager.shared.applyFilters()
                  collectioniView.reloadData()
       }


       
           
       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           // If the search text is empty, show all events
           if searchText.isEmpty {
                      FilterDataManager.shared.filteredEventNames = FilterDataManager.shared.eventNames
                  } else {
                      FilterDataManager.shared.filteredEventNames = FilterDataManager.shared.eventNames.filter {
                          return $0.lowercased().contains(searchText.lowercased())
                      }
                  }
                  
                  collectioniView.reloadData()
              }
       
           
           // Optionally handle the search bar cancel button
           func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
               searchBar.text = ""
               filteredEventNames = eventNames // Reset the filtered events
               collectioniView.reloadData()
           }
       }
       
      


   extension EventSearchViewController: UICollectionViewDataSource {
       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
               return FilterDataManager.shared.filteredEventNames.count
           }
           
           func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EveCollectionViewCell", for: indexPath) as! EveCollectionViewCell
               let eventName = FilterDataManager.shared.filteredEventNames[indexPath.row]
               cell.setup(with: eventName, category: FilterDataManager.shared.eventCategories[indexPath.row])
               return cell
           }
   }


   extension EventSearchViewController: UICollectionViewDelegateFlowLayout {
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: 379, height: 100)
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
               return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0
               )
           }
   }


extension EventSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("Event selected: \(filteredEventNames[indexPath.row])")
        }
    
}


class EveCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var eveImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func setup(with eventName: String, category: String) {
               titleLabel.text = eventName
               setImageForCategory(category)
           }
           
           private func setImageForCategory(_ category: String) {
               print("Setting image for category: \(category)") // Debug log
               
               switch category {
               case "Music":
                   eveImageView.image = UIImage(named: "Music.png")
               case "Sports":
                   eveImageView.image = UIImage(named: "Sports.png")
               case "Entertainment":
                   eveImageView.image = UIImage(named: "Entertaintment.png")
               case "Comedy":
                   eveImageView.image = UIImage(named: "Comedy.png")
               case "Health Wellness":
                   eveImageView.image = UIImage(named: "Health.png")
               case "Social":
                   eveImageView.image = UIImage(named: "Social.png")
               case "Art & Literature":
                   eveImageView.image = UIImage(named: "Art.png")
               case "Education":
                   eveImageView.image = UIImage(named: "Education.png")
               case "Food":
                   eveImageView.image = UIImage(named: "Food.png")
               case "Fashion":
                   eveImageView.image = UIImage(named: "Fashion.png")
               default:
                   eveImageView.image = UIImage(named: "Social.png")
               }
           }
       }















class OrganizerSearchViewController: UIViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectioneView: UICollectionView!
    var organizers: [String] = []
    var filteredOrgNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectioneView.dataSource = self
        collectioneView.delegate = self
        collectioneView.collectionViewLayout = UICollectionViewFlowLayout()
        searchBar.delegate = self
        fetchOrganizers()
        }

        // Fetch users where "Is Organiser" is true
    func fetchOrganizers() {
            let db = Firestore.firestore()
            
            // Query to get all users who are marked as organizers
            db.collection("Users").whereField("Is Organizer", isEqualTo: true).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching organizers: \(error)")
                    return
                }
                
                // Map fetched users' full names to the organizers array
                self.organizers = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    return data["Full Name"] as? String  // Extract Full Name
                } ?? []
                
                // Initially, set filteredOrgNames to be the same as organizers
                self.filteredOrgNames = self.organizers
                
                // Reload the collection view to display the fetched organizers
                DispatchQueue.main.async {
                    self.collectioneView.reloadData()
                }
            }
        }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // If the search text is empty, show all events
        if searchText.isEmpty {
                    filteredOrgNames = organizers
                } else {
                    // Filter organizers based on the search text
                    filteredOrgNames = organizers.filter { orgName in
                        return orgName.lowercased().contains(searchText.lowercased())
                    }
                }
                
                // Reload the collection view to reflect the filtered results
                collectioneView.reloadData()
    }
        
        // Optionally handle the search bar cancel button
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
                    filteredOrgNames = organizers  // Reset the filtered list
                    collectioneView.reloadData()
        }
    }
    
    


extension OrganizerSearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredOrgNames.count  // Return the count of filtered organizers
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrgCollectionViewCell", for: indexPath) as! OrgCollectionViewCell
            cell.setup(with: filteredOrgNames[indexPath.row])  // Pass the filtered organizer name
            return cell
        }
}

extension OrganizerSearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 379, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0
            )
        }
}

extension OrganizerSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print(filteredOrgNames[indexPath.row])  // Print the selected organizer's name
        }
    
}

class OrgCollectionViewCell: UICollectionViewCell{
    
    
    @IBOutlet weak var orgImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func setup(with organizerName: String) {
        orgImageView.image = UIImage(named: "DinoProfile.jpeg") // Placeholder image
            titleLabel.text = organizerName  // Set the organizer name
        }
    
}







class ContactUsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}









protocol FilterSearchViewControllerDelegate: AnyObject {
    func didUpdateFilters(selectedCategories: [String], selectedLocations: [String])
}

class FilterSearchViewController: UIViewController {
    
    weak var delegate: FilterSearchViewControllerDelegate?
        
    var availableCategories: [String] = ["Music", "Sports", "Entertainment", "Comedy", "Health Wellness", "Social", "Art & Literature", "Education", "Food", "Fashion"]
        var availableLocations: [String] = ["Southern", "Northern", "The Capital", "Muharraq"]
        
        var selectedCategories: [String] = []
        var selectedLocations: [String] = []
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    @IBOutlet weak var HAbutton: UIButton!
    var HAChecked = false
    
    @IBOutlet weak var SPButton: UIButton!
    var SPChecked = false
    
    @IBOutlet weak var FNButton: UIButton!
    var FNChecked = false
    
    @IBOutlet weak var ENButton: UIButton!
    var ENChecked = false
   
    
    @IBOutlet weak var CMButton: UIButton!
    var CMChecked = false
    
    @IBOutlet weak var MSButton: UIButton!
    var MSChecked = false
    
    @IBOutlet weak var LTButton: UIButton!
    var LTChecked = false
  
    
    @IBOutlet weak var EDButton: UIButton!
    var EDChecked = false
    
    @IBOutlet weak var SLButton: UIButton!
    var SLChecked = false
    
    @IBOutlet weak var FDButton: UIButton!
    var FDChecked = false
    
    
    
    @IBOutlet weak var NRButton: UIButton!
    var NRChecked = false
    
    @IBOutlet weak var CLButton: UIButton!
    var CLChecked = false
    
    @IBOutlet weak var MQButton: UIButton!
    var MQChecked = false
    
    @IBOutlet weak var SRButton: UIButton!
    var SRChecked = false
    
    
    
    
    @IBOutlet weak var WEButton: UIButton!
    var WEChecked = false
    
    @IBOutlet weak var MOButton: UIButton!
    var MOChecked = false
    
    
    
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtonStates()
    }
    
    func updateButtonStates() {
            // Ensure FilterDataManager has the correct data
            HAChecked = FilterDataManager.shared.selectedCategories.contains("Health Wellness")
            
            // Safe unwrapping of HAbutton
            if let haButton = HAbutton {
                haButton.setImage(UIImage(systemName: HAChecked ? "checkmark.square.fill" : "square"), for: .normal)
            } else {
                print("HAbutton is nil. Make sure it's connected in the storyboard.")
            }
            
            // Similarly, update other button states based on FilterDataManager.shared.selectedCategories
            // Update the rest of the buttons similarly
            if let spButton = SPButton {
                SPChecked = FilterDataManager.shared.selectedCategories.contains("Sports")
                spButton.setImage(UIImage(systemName: SPChecked ? "checkmark.square.fill" : "square"), for: .normal)
            } else {
                print("SPButton is nil. Make sure it's connected in the storyboard.")
            }

            if let fnButton = FNButton {
                FNChecked = FilterDataManager.shared.selectedCategories.contains("Food")
                fnButton.setImage(UIImage(systemName: FNChecked ? "checkmark.square.fill" : "square"), for: .normal)
            } else {
                print("FNButton is nil. Make sure it's connected in the storyboard.")
            }
            
            // Repeat for other buttons...
        }


    
    
    @IBAction func resetClicked(_ sender: UIButton) {
        
        selectedCategories.removeAll()
            selectedLocations.removeAll()
            resetButtons()
    }
    
    @IBAction func doneClicked(_ sender: UIButton) {
        FilterDataManager.shared.selectedCategories = FilterDataManager.shared.selectedCategories
                       FilterDataManager.shared.selectedLocations = FilterDataManager.shared.selectedLocations
                       
                       // Notify the delegate (EventSearchViewController) that filters have been updated
                       delegate?.didUpdateFilters(selectedCategories: FilterDataManager.shared.selectedCategories, selectedLocations: FilterDataManager.shared.selectedLocations)
                       
                       dismiss(animated: true, completion: nil)
    }
    
    
    func updateSelectedCategories(_ category: String, isSelected: Bool) {
           if isSelected {
               selectedCategories.append(category)
           } else {
               selectedCategories.removeAll { $0 == category }
           }
       }

       func updateSelectedLocations(_ location: String, isSelected: Bool) {
           if isSelected {
               selectedLocations.append(location)
           } else {
               selectedLocations.removeAll { $0 == location }
           }
       }
    
    @IBAction func HATapped(_ sender: UIButton) {
        if sender == HAbutton {
                         HAChecked.toggle()
                         if HAChecked {
                             FilterDataManager.shared.selectedCategories.append("Health Wellness")
                         } else {
                             FilterDataManager.shared.selectedCategories.removeAll { $0 == "Health Wellness" }
                         }
                     }
                     
                     // Update button states
                     updateButtonStates()
           }
    
    
    @IBAction func SPTapped(_ sender: UIButton) {
        SPChecked.toggle()
            let imageName = SPChecked ? "checkmark.square.fill" : "square"
            let image = UIImage(systemName: imageName)
            SPButton.setImage(image, for: .normal)
            updateSelectedCategories("Sports", isSelected: SPChecked)
    }
    
    @IBAction func FNTapped(_ sender: UIButton) {
        FNChecked = !FNChecked
        let imageName = FNChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        FNButton.setImage(image, for: .normal)
    }
    
    @IBAction func ENTapped(_ sender: Any) {
        ENChecked = !ENChecked
        let imageName = ENChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        ENButton.setImage(image, for: .normal)
    }
  
    @IBAction func CMTapped(_ sender: UIButton) {
        CMChecked = !CMChecked
        let imageName = CMChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        CMButton.setImage(image, for: .normal)
    }
    
    @IBAction func EDTapped(_ sender: UIButton) {
        EDChecked = !EDChecked
        let imageName = EDChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        EDButton.setImage(image, for: .normal)
    }
    
    @IBAction func SLTapped(_ sender: UIButton) {
        SLChecked = !SLChecked
        let imageName = SLChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        SLButton.setImage(image, for: .normal)
    }
    
    @IBAction func FDTapped(_ sender: UIButton) {
        FDChecked = !FDChecked
        let imageName = FDChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        FDButton.setImage(image, for: .normal)
    }
    
    @IBAction func LRTapped(_ sender: Any) {
        LTChecked = !LTChecked
        let imageName = LTChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        LTButton.setImage(image, for: .normal)
    }
    
    @IBAction func MSTapped(_ sender: UIButton) {
        MSChecked = !MSChecked
        let imageName = MSChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        MSButton.setImage(image, for: .normal)
    }
    
    
    
    
    
    @IBAction func NRTapped(_ sender: UIButton) {
        NRChecked = !NRChecked
        let imageName = NRChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        NRButton.setImage(image, for: .normal)
    }
    
    
    @IBAction func CLTapped(_ sender: UIButton) {
        CLChecked = !CLChecked
        let imageName = CLChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        CLButton.setImage(image, for: .normal)
    }
    
    @IBAction func MQTapped(_ sender: UIButton) {
        MQChecked = !MQChecked
        let imageName = MQChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        MQButton.setImage(image, for: .normal)
    }
    
    @IBAction func SRTapped(_ sender: UIButton) {
        SRChecked = !SRChecked
        let imageName = SRChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        SRButton.setImage(image, for: .normal)
    }
    
    
    
    
    @IBAction func WETapped(_ sender: UIButton) {
        WEChecked = !WEChecked
        let imageName = WEChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        WEButton.setImage(image, for: .normal)
    }
    
    @IBAction func MOTapped(_ sender: UIButton) {
        MOChecked = !MOChecked
        let imageName = MOChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        MOButton.setImage(image, for: .normal)
    }
    
    
   
    
    private func resetButtons() {
              // Reset button images to "unselected" state
              // For each button, reset the image to square
              HAbutton.setImage(UIImage(systemName: "square"), for: .normal)
              SPButton.setImage(UIImage(systemName: "square"), for: .normal)
                 FNButton.setImage(UIImage(systemName: "square"), for: .normal)
                 ENButton.setImage(UIImage(systemName: "square"), for: .normal)
              // Reset other buttons similarly
          }
    
    
    
}


