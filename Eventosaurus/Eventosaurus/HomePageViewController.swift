//
//  HomePageViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-21 on 04/12/2024.
//

import UIKit

import FirebaseFirestore
import FirebaseAuth





class HomePageViewController: UIViewController {
    
    
    @IBOutlet weak var helloDino: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
    }
   
    
    override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    let gradient = CAGradientLayer()

    // Define the gradient colors (purple to pink to orange to peach)withAlphaComponent(0.7).cgColor
    gradient.colors = [
        UIColor(red: 0.29, green: 0.00, blue: 0.51, alpha: 1.0).cgColor, // Purple
        UIColor(red: 0.87, green: 0.19, blue: 0.56, alpha: 1.0).cgColor, // Pink
        UIColor(red: 1.00, green: 0.49, blue: 0.31, alpha: 1.0).cgColor, // Orange
        UIColor(red: 1.00, green: 0.80, blue: 0.50, alpha: 1.0).cgColor // Peach
    ]
    gradient.locations = [0.0, 0.33, 0.66, 1.0] // Color stops
    gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.endPoint = CGPoint(x: 0.0, y: 1.0)

    // Set the frame dynamically
    gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)

    // Insert gradient as the background
    self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    
    
}




    









// MARK: - Event Home View Controller

class EventHomeViewController: UIViewController {
    
    @IBOutlet weak var collectionoView: UICollectionView!
    
    // Define properties to store event data
    let db = Firestore.firestore()
    
    var eventNames: [String] = []
    var eventCategories: [String] = [] // Store the category names
    
    var eventID: String? // The event ID for the event user joined
        var selectedStarRating: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionoView.dataSource = self
        collectionoView.delegate = self
        collectionoView.collectionViewLayout = UICollectionViewFlowLayout()
        
        
        fetchEvents()
        let eventID = "3plSFQlyblfBdbgvkxSGGH" // Replace this with the actual event ID you want to use
        showFeedbackAlert(forEvent: eventID)
    }
    
    override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    let gradient = CAGradientLayer()

    // Define the gradient colors (purple to pink to orange to peach)
    gradient.colors = [
    UIColor(red: 0.29, green: 0.00, blue: 0.51, alpha: 1.0).cgColor, // Purple
    UIColor(red: 0.87, green: 0.19, blue: 0.56, alpha: 1.0).cgColor, // Pink
    UIColor(red: 1.00, green: 0.49, blue: 0.31, alpha: 1.0).cgColor, // Orange
    UIColor(red: 1.00, green: 0.80, blue: 0.50, alpha: 1.0).cgColor // Peach
    ]
    gradient.locations = [0.0, 0.33, 0.66, 1.0] // Color stops
    gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.endPoint = CGPoint(x: 0.0, y: 1.0)

    // Set the frame dynamically
    gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)

    // Insert gradient as the background
    self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    func showFeedbackAlert(forEvent eventID: String) {
        // Check if the alert has already been shown for this session
        if UserDefaults.standard.bool(forKey: "hasShownFeedbackAlertForEvent_\(eventID)") {
            print("Alert already shown for event \(eventID). Skipping...")
            return  // Do nothing if the alert has already been shown
        }

        print("Attempting to show the alert for event \(eventID)...")
        
        let alertController = UIAlertController(title: "How did you find today's event?", message: nil, preferredStyle: .alert)
        
        // Add a custom star rating view
        let starRatingView = UIStackView()
        starRatingView.axis = .horizontal
        starRatingView.distribution = .fillEqually
        starRatingView.spacing = 5
        
        // Create the 5 star buttons
        for index in 0..<5 {
            let starButton = UIButton(type: .system)
            starButton.setTitle("★", for: .normal)
            starButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            starButton.tintColor = .lightGray  // Initial tint color is light gray
            starButton.tag = index + 1 // Assign tag to identify which star was tapped
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starRatingView.addArrangedSubview(starButton)
        }
        
        // Convert starRatingView to a UIViewController to add it to the alert
        let hostingController = UIViewController()
        hostingController.view = starRatingView
        hostingController.preferredContentSize = CGSize(width: 200, height: 50)
        
        // Set the content view of the alert to be the star rating view
        alertController.setValue(hostingController, forKey: "contentViewController")
        
        // Add "Feedback" button
        let feedbackAction = UIAlertAction(title: "Feedback", style: .default) { _ in
            print("Feedback button tapped")
            self.navigateToFeedbackPage(forEvent: eventID)
        }
        alertController.addAction(feedbackAction)
        
        // Add "Cancel" and "Confirm" actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            print("Confirm button tapped")
            
            // Save the star rating when "Confirm" is tapped, if any star rating is selected
            if self.selectedStarRating > 0 {
                self.saveStarRating(stars: self.selectedStarRating, eventID: eventID)
            } else {
                print("No star rating selected")
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        // Present the alert
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        
        // Set the flag in UserDefaults to indicate that the alert has been shown for this event
        UserDefaults.standard.set(true, forKey: "hasShownFeedbackAlertForEvent_\(eventID)")
    }

    
    

        // Method to handle star taps
        @objc func starTapped(_ sender: UIButton) {
            // Get the stack view containing the star buttons
                    guard let stackView = sender.superview as? UIStackView else { return }
                    
                    // Reset the tint color of all stars to light gray
            for star in stackView.arrangedSubviews {
                if let button = star as? UIButton {
                    button.tintColor = .lightGray
                }}
            
            if let index = stackView.arrangedSubviews.firstIndex(of: sender) {
                      // Highlight stars up to the tapped one
                      for i in 0...index {
                          if let button = stackView.arrangedSubviews[i] as? UIButton {
                              button.tintColor = .systemYellow
                          }
                      }
        }
            
            self.selectedStarRating = sender.tag
                    print("Star selected: \(selectedStarRating)")
                }


        // Save the star rating to Firestore
        func saveStarRating(stars: Int, eventID: String) {
            let db = Firestore.firestore()
            
            // Save the star rating data to Firestore (similar to your previous code)
            let feedbackData: [String: Any] = [
                "Stars": stars,
                "EventID": eventID
            ]
            
            db.collection("FeedBack").addDocument(data: feedbackData) { error in
                if let error = error {
                    print("Error saving star rating: \(error.localizedDescription)")
                } else {
                    print("Star rating saved successfully!")
                }
            }

            // After saving feedback, set didReceive to true so alert doesn't show again
            UserDefaults.standard.set(true, forKey: "didReceiveFeedback-\(eventID)")
            
        }
    
    func navigateToFeedbackPage(forEvent eventID: String) {
        let storyboardName = "FeedBack"  // Ensure this matches the name of your storyboard
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        // Try to instantiate the feedback view controller using the correct storyboard ID
        if let feedbackVC = storyboard.instantiateViewController(withIdentifier: "WriteFeedbackViewController") as? WriteFeedbackViewController {
            
            // Pass the selected star rating and event ID
            feedbackVC.starRating = self.selectedStarRating  // Pass the selected star rating here
            feedbackVC.eventID = eventID  // Pass the eventID here
            
            // Ensure the modal is presented correctly
            feedbackVC.modalPresentationStyle = .fullScreen  // Use .fullScreen or .pageSheet depending on your needs
            print("Presenting feedback page for eventID: \(eventID)") // Log for debugging
            
            // Present the feedback view controller modally
            self.present(feedbackVC, animated: true, completion: nil)
        } else {
            print("Could not instantiate WriteFeedbackViewController from the storyboard.") // Log error
        }
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
                                
                                CategoryStore.shared.addEventToCategory(eventName: eventName, category: categoryName)
                                                                
                                // Reload collection view after fetching events (inside the completion handler)
                                self.collectionoView.reloadData()
                            }
                        }
                    }
                } else {
                    // If there is no valid category reference, fall back to default category
                    let defaultCategory = "Fashion"
                    self.eventNames.append(eventName)
                    self.eventCategories.append(defaultCategory)
                    CategoryStore.shared.addEventToCategory(eventName: eventName, category: defaultCategory)
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













// MARK: - EventSearchViewController

class EventSearchViewController: UIViewController, UISearchBarDelegate, FilterSearchViewControllerDelegate {
    
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectioniView: UICollectionView!
    let db = Firestore.firestore()
        
          var eventNames: [String] = []
          var filteredEventNames: [String] = []
          var filteredEventCategories: [String] = []
          var filteredEventLocations: [String] = []
          var filteredEventDescriptions: [String] = []
          var filteredEventDates: [String] = []
          var eventDates: [String] = []
          var eventCategories: [String] = []
          var eventLocations: [String] = []
          var eventDescriptions: [String] = []
          var selectedCategories: [String] = []
          var selectedLocations: [String] = []
          var selectedDates: [String] = []
    
       
       override func viewDidLoad() {
           super.viewDidLoad()
           collectioniView.dataSource = self
           collectioniView.delegate = self
           collectioniView.collectionViewLayout = UICollectionViewFlowLayout()
           searchBar.delegate = self
//           print(filteredEventNames)
           print("before fetch")
             print(selectedLocations)
           print(selectedCategories)
                fetchEvents()
           print("after fetch")
             print(selectedLocations)
           print(selectedCategories)
           didUpdateFilters(selectedCategories: selectedCategories, selectedLocations: selectedLocations, selectedDates: selectedDates)
           print("after fetch")
             print(selectedLocations)
           print(selectedCategories)
           filteredEventNames = eventNames
           print("filtered names\(filteredEventNames)")
              
           
           
           print("Entered View Did Load, line 536")
           
       }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        didUpdateFilters(selectedCategories: selectedCategories, selectedLocations: selectedLocations)
//    }
    
    override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    let gradient = CAGradientLayer()

    // Define the gradient colors (purple to pink to orange to peach)withAlphaComponent(0.7).cgColor
    gradient.colors = [
        UIColor(red: 0.29, green: 0.00, blue: 0.51, alpha: 1.0).cgColor, // Purple
        UIColor(red: 0.87, green: 0.19, blue: 0.56, alpha: 1.0).cgColor, // Pink
        UIColor(red: 1.00, green: 0.49, blue: 0.31, alpha: 1.0).cgColor, // Orange
        UIColor(red: 1.00, green: 0.80, blue: 0.50, alpha: 1.0).cgColor // Peach
    ]
    gradient.locations = [0.0, 0.33, 0.66, 1.0] // Color stops
    gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.endPoint = CGPoint(x: 0.0, y: 1.0)

    // Set the frame dynamically
    gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)

    // Insert gradient as the background
    self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    
    @IBAction func filterShow(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HomePage ", bundle: nil)
                       if let filterVC = storyboard.instantiateViewController(withIdentifier: "FilterSearchViewController") as? FilterSearchViewController {
                           filterVC.savedSelectedCategories = selectedCategories
                           filterVC.savedSelectedLocations = selectedLocations
                           filterVC.savedSelectedDates = selectedDates
                           filterVC.delegate = self
                           self.present(filterVC, animated: true, completion: nil)
                }
    }
    
    func didUpdateFilters(selectedCategories: [String], selectedLocations: [String], selectedDates: [String]) {
            // Update local variables with selected filters
            self.selectedCategories = selectedCategories
            self.selectedLocations = selectedLocations
            self.selectedDates = selectedDates
            
            // Call method to update or fetch the filtered events
        filterEvents()
        
            
        }
        
       
    func filterEvents() {
        // Ensure selected categories and locations are non-empty before filtering
        let filteredEvents = zip(zip(zip(eventNames, eventCategories), zip(eventLocations, eventDescriptions)), eventDates).filter { eventTuple in
            let ((eventNameCategory, locationDescription), eventDate) = eventTuple
            let (_, category) = eventNameCategory
            let (location, _) = locationDescription
            
            // Ensure that if no filter is selected, it doesn't filter out all events
            let matchesCategory = selectedCategories.isEmpty || selectedCategories.contains(category)
            let matchesLocation = selectedLocations.isEmpty || selectedLocations.contains(location)
            let matchesDate = selectedDates.isEmpty || selectedDates.contains(eventDate)  // Filter by selected dates

            return matchesCategory && matchesLocation && matchesDate
        }

        // Unzip the filtered results into separate arrays
        filteredEventNames = filteredEvents.map { $0.0.0.0 }  // Extract event names
        filteredEventCategories = filteredEvents.map { $0.0.0.1 }  // Extract event categories
        filteredEventLocations = filteredEvents.map { $0.0.1.0 }  // Extract event locations
        filteredEventDescriptions = filteredEvents.map { $0.0.1.1 }  // Extract event descriptions
        filteredEventDates = filteredEvents.map { $0.1 }  // Extract event dates

        collectioniView.reloadData()
    }

      
      func fetchEvents() {
          db.collection("Events").getDocuments { (snapshot, error) in
              if let error = error {
                  print("Error fetching events: \(error)")
                  return
              }

              guard let documents = snapshot?.documents, documents.count > 0 else {
                  print("No events found.")
                  return
              }

              self.eventNames.removeAll()
              self.eventCategories.removeAll()
              self.eventLocations.removeAll() // Clear locations
              self.eventDescriptions.removeAll() // Clear descriptions
              self.eventDates.removeAll()
              
              var newEventNames: [String] = []
              var newEventCategories: [String] = []
              var newEventLocations: [String] = [] // Array for event locations
              var newEventDescriptions: [String] = [] // Array for event descriptions
              var newEventDates: [String] = []
              
              let group = DispatchGroup() // To handle async calls

              documents.forEach { document in
                  group.enter()
                  let data = document.data()
                  let eventName = data["Event Name"] as? String ?? "Unnamed Event"
                  let description = data["Description"] as? String ?? "No Description" // Get description

                  // Split the description to extract location
                  let location = description.components(separatedBy: " - ").first ?? "Unknown Location"
                  let actualDescription = description.components(separatedBy: " - ").dropFirst().joined(separator: " - ")

                  var date = ""
                  if let eventDateTimestamp = data["Date"] as? Timestamp {
                      let eventDate = eventDateTimestamp.dateValue() // Convert the Firestore timestamp to a Date
                      
                      // Determine if the event is this week or this month
                      
                      let currentDate = Date()
                      
                      let calendar = Calendar.current
                      // Check if the event is in this week
                      if calendar.isDate(eventDate, equalTo: currentDate, toGranularity: .weekOfYear) {
                          date = "This Week"
                      }
                      // Check if the event is in this month
                      else if calendar.isDate(eventDate, equalTo: currentDate, toGranularity: .month) {
                          date = "This Month"
                      } else {
                          date = "Other" // You can adjust this based on your needs
                      }
                  }
                  print("698 date: \(date)")
                  
                  if let categoryRef = data["Category"] as? DocumentReference {
                      categoryRef.getDocument { (categorySnapshot, error) in
                          if let error = error {
                              print("Error fetching category: \(error)")
                          }

                          if let categorySnapshot = categorySnapshot,
                             let categoryName = categorySnapshot.data()?["Category Name"] as? String {
                              newEventNames.append(eventName)
                              newEventCategories.append(categoryName)
                              newEventLocations.append(location) // Store the extracted location
                              newEventDescriptions.append(actualDescription) // Store the actual description
                              newEventDates.append(date)
                          }

                          group.leave() // Notify that this async call is done
                      }
                  } else {
                      let defaultCategory = "Fashion" // Only use this if
                      newEventNames.append(eventName)
                      newEventCategories.append(defaultCategory)
                      newEventLocations.append(location) // Default location if none found
                      newEventDescriptions.append(actualDescription)
                      newEventDates.append("Unknown Date") // Default description
                      group.leave() // No async needed for default category
                  }
              }

              group.notify(queue: .main) {
                  self.eventNames = newEventNames
                  self.eventCategories = newEventCategories
                  self.eventLocations = newEventLocations // Assign fetched locations
                  self.eventDescriptions = newEventDescriptions // Assign descriptions
                  self.eventDates = newEventDates
                  self.collectioniView.reloadData()
                  self.filterEvents() // Now filter the events after the data is fully fetched
              }
          }
      }



       
           
       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           // If the search text is empty, show all events
           if searchText.isEmpty {
                             filteredEventNames = eventNames
                         } else {
                             // Filter events based on both event name and category
                             filteredEventNames = zip(eventNames, eventCategories).filter { (eventName, category) in
                                 return eventName.lowercased().contains(searchText.lowercased()) || category.lowercased().contains(searchText.lowercased())
                             }.map { (eventName, _) in
                                 return eventName
                             }
                         }
                  
                  // Reload the collection view to reflect the filtered results
                  collectioniView.reloadData()
              }
       
           
           // Optionally handle the search bar cancel button
           func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
               searchBar.text = ""
               filteredEventNames = eventNames
                                                 // Reset the filtered events
               collectioniView.reloadData()
           }
       }
       

   extension EventSearchViewController: UICollectionViewDataSource {
       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                  return filteredEventNames.count  // Return the count of events
              }
              
           func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EveCollectionViewCell", for: indexPath) as! EveCollectionViewCell
                   
                   let eventName = filteredEventNames[indexPath.row]
                   let eventCategory = filteredEventCategories[indexPath.row] // Get the category for this event
                   let eventLocation = filteredEventLocations[indexPath.row] // Get the location for this event
                   let eventDescription = filteredEventDescriptions[indexPath.row] // Get the description for this event
                   let eventDate = filteredEventDates[indexPath.row]
                   // Pass data to the cell
               cell.setup(with: eventName, category: eventCategory, location: eventLocation, description: eventDescription, date: eventDate)
                   
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
    
    func setup(with eventName: String, category: String, location: String, description: String, date: String) {
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
    
    override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    let gradient = CAGradientLayer()

    // Define the gradient colors (purple to pink to orange to peach)withAlphaComponent(0.7).cgColor
    gradient.colors = [
        UIColor(red: 0.29, green: 0.00, blue: 0.51, alpha: 1.0).cgColor, // Purple
        UIColor(red: 0.87, green: 0.19, blue: 0.56, alpha: 1.0).cgColor, // Pink
        UIColor(red: 1.00, green: 0.49, blue: 0.31, alpha: 1.0).cgColor, // Orange
        UIColor(red: 1.00, green: 0.80, blue: 0.50, alpha: 1.0).cgColor // Peach
    ]
    gradient.locations = [0.0, 0.33, 0.66, 1.0] // Color stops
    gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.endPoint = CGPoint(x: 0.0, y: 1.0)

    // Set the frame dynamically
    gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)

    // Insert gradient as the background
    self.view.layer.insertSublayer(gradient, at: 0)
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






class CategoryStore {
    static let shared = CategoryStore() // Singleton instance
    
    private init() {}
    
    var healthWellness: [String] = []
    var sports: [String] = []
    var fashion: [String] = []
    var entertainment: [String] = []
    var comedy: [String] = []
    var education: [String] = []
    var social: [String] = []
    var food: [String] = []
    var artLiterature: [String] = []
    var music: [String] = []
    
    var eventLocations: [String] = []
    
    // New properties for date-based filtering
    var eventDates: [String] = []
    
    func addEventToCategory(eventName: String, category: String) {
        switch category {
        case "Health Wellness":
            healthWellness.append(eventName)
        case "Sports":
            sports.append(eventName)
        case "Fashion":
            fashion.append(eventName)
        case "Entertainment":
            entertainment.append(eventName)
        case "Comedy":
            comedy.append(eventName)
        case "Education":
            education.append(eventName)
        case "Social":
            social.append(eventName)
        case "Food":
            food.append(eventName)
        case "Art & Literature":
            artLiterature.append(eventName)
        case "Music":
            music.append(eventName)
        default:
            print("Unknown category: \(category)")
        }
    }
    
    
    func clearAllCategories() {
        healthWellness.removeAll()
        sports.removeAll()
        fashion.removeAll()
        entertainment.removeAll()
        comedy.removeAll()
        education.removeAll()
        social.removeAll()
        food.removeAll()
        artLiterature.removeAll()
        music.removeAll()
        
    }
}












// MARK: - Filter work
protocol FilterSearchViewControllerDelegate: AnyObject {
    func didUpdateFilters(selectedCategories: [String], selectedLocations: [String], selectedDates: [String])
}

class FilterSearchViewController: UIViewController {
    
    weak var delegate: FilterSearchViewControllerDelegate?
    
        var selectedCategories: [String] = []
        var selectedLocations: [String] = []
        var selectedDates: [String] = []
    var savedSelectedCategories: [String] = []
    var savedSelectedLocations: [String] = []
    var savedSelectedDates: [String] = []
    
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
            
        }
    

    
    @IBAction func resetClicked(_ sender: UIButton) {
        
        selectedCategories.removeAll()
        selectedLocations.removeAll()
        selectedDates.removeAll()

        resetButtons()
        
        if let eventSearchVC = self.presentingViewController as? EventSearchViewController {
            eventSearchVC.filteredEventNames = eventSearchVC.eventNames
            eventSearchVC.filteredEventCategories = eventSearchVC.eventCategories
            eventSearchVC.filteredEventLocations = eventSearchVC.eventLocations
            eventSearchVC.filteredEventDescriptions = eventSearchVC.eventDescriptions
            eventSearchVC.filteredEventDates = eventSearchVC.eventDates
            eventSearchVC.collectioniView.reloadData()
        }
    }
    
    @IBAction func doneClicked(_ sender: UIButton) {
                
        delegate?.didUpdateFilters(selectedCategories: selectedCategories, selectedLocations: selectedLocations, selectedDates: selectedDates)
                
                // Dismiss the filter view
                self.dismiss(animated: true, completion: nil)
    }
    
    func updateButtonState(button: UIButton, checkedState: inout Bool, category: String, isCategory: Bool) {
            checkedState.toggle()
            let imageName = checkedState ? "checkmark.square.fill" : "square"
            let image = UIImage(systemName: imageName)
            button.setImage(image, for: .normal)
            
        if isCategory {
               updateSelectedCategories(category, isSelected: checkedState)
           } else if category == "This Week" || category == "This Month" || category == "Other" {
               // If category is one of the date strings, update selected dates
               updateSelectedDates(category, isSelected: checkedState)
           } else {
               // Otherwise, update selected locations
               updateSelectedLocations(category, isSelected: checkedState)
           }
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
    
    func updateSelectedDates(_ date: String, isSelected: Bool) {
        if isSelected {
            selectedDates.append(date)
        } else {
            selectedDates.removeAll { $0 == date }
        }
    }
    
    @IBAction func HATapped(_ sender: UIButton) {
        updateButtonState(button: HAbutton, checkedState: &HAChecked, category: "Health Wellness", isCategory: true)
           }
    
    
    @IBAction func SPTapped(_ sender: UIButton) {
        updateButtonState(button: SPButton, checkedState: &SPChecked, category: "Sports", isCategory: true)
    }
    
    @IBAction func FNTapped(_ sender: UIButton) {
        updateButtonState(button: FNButton, checkedState: &FNChecked, category: "Fashion", isCategory: true)
    }
    
    @IBAction func ENTapped(_ sender: Any) {
        updateButtonState(button: ENButton, checkedState: &ENChecked, category: "Entertainment", isCategory: true)
    }
  
    @IBAction func CMTapped(_ sender: UIButton) {
        updateButtonState(button: CMButton, checkedState: &CMChecked, category: "Comedy", isCategory: true)
    }
    
    @IBAction func EDTapped(_ sender: UIButton) {
        updateButtonState(button: EDButton, checkedState: &EDChecked, category: "Education", isCategory: true)
    }
    
    @IBAction func SLTapped(_ sender: UIButton) {
        updateButtonState(button: SLButton, checkedState: &SLChecked, category: "Social", isCategory: true)
    }
    
    @IBAction func FDTapped(_ sender: UIButton) {
        updateButtonState(button: FDButton, checkedState: &FDChecked, category: "Food", isCategory: true)
    }
    
    @IBAction func LRTapped(_ sender: Any) {
        updateButtonState(button: LTButton, checkedState: &LTChecked, category: "Art & Literature", isCategory: true)
    }
    
    @IBAction func MSTapped(_ sender: UIButton) {
        updateButtonState(button: MSButton, checkedState: &MSChecked, category: "Music", isCategory: true)
    }
    
    
    @IBAction func NRTapped(_ sender: UIButton) {
        updateButtonState(button: NRButton, checkedState: &NRChecked, category: "Northern", isCategory: false)
    }
    
    
    @IBAction func CLTapped(_ sender: UIButton) {
        updateButtonState(button: CLButton, checkedState: &CLChecked, category: "The Capital", isCategory: false)

    }
    
    @IBAction func MQTapped(_ sender: UIButton) {
        updateButtonState(button: MQButton, checkedState: &MQChecked, category: "Muharraq", isCategory: false)
    }
    
    @IBAction func SRTapped(_ sender: UIButton) {
        updateButtonState(button: SRButton, checkedState: &SRChecked, category: "Southern", isCategory: false)
    }
    
    
    @IBAction func WETapped(_ sender: UIButton) {
        updateButtonState(button: WEButton, checkedState: &WEChecked, category: "This Week", isCategory: false)
    }
    
    @IBAction func MOTapped(_ sender: UIButton) {
        updateButtonState(button: MOButton, checkedState: &MOChecked, category: "This Month", isCategory: false)
    }
    
    
    
   
    
    private func resetButtons() {
              
              HAbutton.setImage(UIImage(systemName: "square"), for: .normal)
              SPButton.setImage(UIImage(systemName: "square"), for: .normal)
                 FNButton.setImage(UIImage(systemName: "square"), for: .normal)
                 ENButton.setImage(UIImage(systemName: "square"), for: .normal)
        SLButton.setImage(UIImage(systemName: "square"), for: .normal)
        CMButton.setImage(UIImage(systemName: "square"), for: .normal)
           CLButton.setImage(UIImage(systemName: "square"), for: .normal)
           NRButton.setImage(UIImage(systemName: "square"), for: .normal)
        SRButton.setImage(UIImage(systemName: "square"), for: .normal)
        MSButton.setImage(UIImage(systemName: "square"), for: .normal)
           EDButton.setImage(UIImage(systemName: "square"), for: .normal)
           FDButton.setImage(UIImage(systemName: "square"), for: .normal)
        LTButton.setImage(UIImage(systemName: "square"), for: .normal)
        MQButton.setImage(UIImage(systemName: "square"), for: .normal)
           WEButton.setImage(UIImage(systemName: "square"), for: .normal)
           MOButton.setImage(UIImage(systemName: "square"), for: .normal)
              
          }
    
    
    
}


