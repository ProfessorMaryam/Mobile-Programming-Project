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








class DisplayNameViewController: UIViewController {
    
    
    @IBOutlet weak var EventNameL: UILabel!
    
    let db = Firestore.firestore()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Fetch a random event name from Firestore
            fetchRandomEvent()
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
                }
            }
        }
    }















class EventHomeViewController: UIViewController {
    
    @IBOutlet weak var collectionoView: UICollectionView!
    
    // Define properties to store event data
    let db = Firestore.firestore()
        
        var eventNames: [String] = []

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
               
               
               // Map documents to event data arrays
               documents.forEach { document in
                   let data = document.data()
                   let eventName = data["Event Name"] as? String ?? "Unnamed Event"
                   

                   // Add data to arrays
                   self.eventNames.append(eventName)
                  
               }
               
               // Reload collection view after fetching events
               self.collectionoView.reloadData()
           }
       }
   }
    
    // Clear previous event data
    

// MARK: - UICollectionView DataSource
extension EventHomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return eventNames.count // Return the count of events
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCell", for: indexPath) as! EventCollectionViewCell
            
            // Get event data from arrays
            let eventName = eventNames[indexPath.row]
            
            // Populate the cell with event data
            cell.setup(with: eventName)
            
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
    
    func setup(with eventName: String) {
            // Set the image (you can replace "damn.jpeg" with your own default image name)
            eventImageView.image = UIImage(named: "damn.jpeg")
            
            // Set the event name in the label
        titleLabel.text = eventName
            
            // If you want to display description or date, you can add those as well
            // For example: print(description) or titleLabel.text = "\(eventName) - \(description)"
        }
}










class EventSearchViewController: UIViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectioniView: UICollectionView!
    let db = Firestore.firestore()
        
        var eventNames: [String] = []
    var filteredEventNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectioniView.dataSource = self
        collectioniView.delegate = self
        collectioniView.collectionViewLayout = UICollectionViewFlowLayout()
        searchBar.delegate = self
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
               self.filteredEventNames.removeAll()
               
               // Map documents to event data arrays
               documents.forEach { document in
                   let data = document.data()
                   let eventName = data["Event Name"] as? String ?? "Unnamed Event"
                   

                   // Add data to arrays
                   self.eventNames.append(eventName)
                   self.filteredEventNames.append(eventName)
               }
               
               // Reload collection view after fetching events
               self.collectioniView.reloadData()
           }
       }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // If the search text is empty, show all events
        if searchText.isEmpty {
            filteredEventNames = eventNames
        } else {
            // Filter events based on the search text
            filteredEventNames = eventNames.filter { eventName in
                return eventName.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Reload the collection view to reflect the filtered results
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
        return filteredEventNames.count // Return the count of events
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EveCollectionViewCell", for: indexPath) as! EveCollectionViewCell
            
            // Get event data from arrays
            let eventName = filteredEventNames[indexPath.row]
            // Populate the cell with event data
            cell.setup(with: eventName)
            
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
    
    func setup(with eventName: String) {
            // Set the image (you can replace "damn.jpeg" with your own default image name)
            eveImageView.image = UIImage(named: "damn.jpeg")
            
            // Set the event name in the label
        titleLabel.text = eventName
            
            // If you want to display description or date, you can add those as well
            // For example: print(description) or titleLabel.text = "\(eventName) - \(description)"
        }
    
}














class OrganizerSearchViewController: UIViewController {
    
    
    
    @IBOutlet weak var collectioneView: UICollectionView!
    var upcomingEvents: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectioneView.dataSource = self
        collectioneView.delegate = self
        collectioneView.collectionViewLayout = UICollectionViewFlowLayout()
        
        fetchUpcomingEvents()
    }
    
    func fetchUpcomingEvents() {
        let db = Firestore.firestore()
        db.collection("Event").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching events: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            self.upcomingEvents = documents.compactMap { doc -> Event? in
                let data = doc.data()
                guard
                    let eventName = data["Event Name"] as? String,
                    let status = data["Status"] as? String,
                    let description = data["Description"] as? String,
                    let timestamp = data["Date"] as? Timestamp,
                    let organizer1 = data["Organizer1"] as? String,
                    let organizer2 = data["Organizer2"] as? String,
                    let maxAttendees = data["Maximum Attendees"] as? Int
                else {
                    return nil
                }
                let date = timestamp.dateValue()
                return Event(status: status, name: eventName, description: description, date: date, organizer1: organizer1, organizer2: organizer2, maximumAttendees: maxAttendees)
            }
            
            DispatchQueue.main.async {
                self.collectioneView.reloadData()
            }
        }
    }
}

extension OrganizerSearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrgCollectionViewCell", for: indexPath) as! OrgCollectionViewCell
        cell.setup(with: upcomingEvents[indexPath.row])
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
        print(upcomingEvents[indexPath.row].eventName)
    }
    
}

class OrgCollectionViewCell: UICollectionViewCell{
    
    
    @IBOutlet weak var orgImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func setup(with event: Event) {
        orgImageView.image = #imageLiteral(resourceName: "damn.jpeg")
        titleLabel.text = event.eventName
    }
    
}







class ContactUsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}











class FilterSearchViewController: UIViewController {
    
    @IBOutlet weak var HAbutton: UIButton!
    var HAChecked = false
    
    @IBOutlet weak var SPButton: UIButton!
    var SPChecked = false
    
    @IBOutlet weak var FNButton: UIButton!
    var FNChecked = false
    
    @IBOutlet weak var ENButton: UIButton!
    var ENChecked = false
    
    @IBOutlet weak var ARButton: UIButton!
    var ARChecked = false
    
    @IBOutlet weak var CMButton: UIButton!
    var CMChecked = false
    
    @IBOutlet weak var MSButton: UIButton!
    var MSChecked = false
    
    @IBOutlet weak var LTButton: UIButton!
    var LTChecked = false
    
    @IBOutlet weak var PHButton: UIButton!
    var PHChecked = false
    
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
    
    @IBAction func HATapped(_ sender: UIButton) {
        HAChecked = !HAChecked
        let imageName = HAChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        HAbutton.setImage(image, for: .normal)
    }
    
    @IBAction func PHTapped(_ sender: UIButton) {
        PHChecked = !PHChecked
        let imageName = PHChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        PHButton.setImage(image, for: .normal)
    }
    
    @IBAction func SPTapped(_ sender: UIButton) {
        SPChecked = !SPChecked
        let imageName = SPChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        SPButton.setImage(image, for: .normal)
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
    
    @IBAction func ARTapped(_ sender: Any) {
        ARChecked = !ARChecked
        let imageName = ARChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        ARButton.setImage(image, for: .normal)
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
    
    
    
}


