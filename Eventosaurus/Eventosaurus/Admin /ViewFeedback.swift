//
//  ViewRequests.swift
//  Eventosaurus
//
//  Created by BP-36-201-04 on 27/12/2024.
//

import UIKit
import FirebaseFirestore

class ViewFeedback: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Property to store the EventID passed from EventListViewController
    var eventID: String?
    
    // Array to store the feedback data
    var feedbackData: [(feedback: String, stars: Int)] = []
    
    // Firestore reference
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegates and data sources
        tableView.delegate = self
        tableView.dataSource = self
        
        // Fetch feedback data for the specific event using EventID
        if let eventID = eventID {
            fetchFeedback(forEventID: eventID)
        }
    }
    
    // Fetch feedback data based on EventID
    func fetchFeedback(forEventID eventID: String) {
        let feedbackRef = db.collection("FeedBack").whereField("EventID", isEqualTo: eventID)
        
        feedbackRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching feedback: \(error.localizedDescription)")
                return
            }
            
            // Clear previous feedback data
            self.feedbackData.removeAll()
            
            // Parse each document and store feedback and stars in the array
            for document in snapshot!.documents {
                let feedbackText = document.get("FeedBack") as? String ?? ""
                let stars = document.get("Stars") as? Int ?? 0
                self.feedbackData.append((feedback: feedbackText, stars: stars))
            }
            
            // Reload the table view to display the fetched data
            self.tableView.reloadData()
        }
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the custom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath) as? FeedbackTableViewCell else {
            return UITableViewCell() // Return an empty cell if dequeuing fails
        }
        
        // Get the feedback data for the current row
        let feedback = feedbackData[indexPath.row]
        
        // Pass the data to the cell's configure method
        cell.configure(with: feedback.feedback, stars: feedback.stars)
        
        return cell
    }
}
