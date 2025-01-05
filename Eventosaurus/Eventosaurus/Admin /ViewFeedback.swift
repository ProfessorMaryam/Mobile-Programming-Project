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
          
          // Register the custom cell NIB
          tableView.register(UINib(nibName: "FeedbackTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedbackCell")
          
          // Set delegates and data sources
          tableView.delegate = self
          tableView.dataSource = self
          
          // Fetch feedback data if eventID exists
          if let eventID = eventID {
              fetchFeedback(forEventID: eventID)
          }
      }
      
      // Fetch feedback data based on EventID
          func fetchFeedback(forEventID eventID: String) {
              // Create a reference to the event document in the "Events" collection
              let eventRef = db.collection("Events").document(eventID) // Get the event reference

                 // Query the "FeedBack" collection where EventID is a reference to the event
                 let feedbackRef = db.collection("FeedBack").whereField("EventID", isEqualTo: eventRef)

                 feedbackRef.getDocuments { snapshot, error in
                     if let error = error {
                         print("Error fetching feedback: \(error.localizedDescription)")
                         return
                     }

                     // Debugging output: Check number of documents returned
                     print("Number of feedback documents: \(snapshot?.documents.count ?? 0)")

                     // If no feedback data is found
                     if snapshot?.documents.isEmpty ?? true {
                         print("No feedback found for this event.")
                     }

                     // Clear previous feedback data
                     self.feedbackData.removeAll()

                     // Parse each document and store feedback and stars in the array
                     for document in snapshot!.documents {
                         let feedbackText = document.get("FeedBack") as? String ?? ""
                         let stars = document.get("Stars") as? Int ?? 0
                         print("Feedback: \(feedbackText), Stars: \(stars)")  // Debugging feedback

                         self.feedbackData.append((feedback: feedbackText, stars: stars))
                     }

                     // Reload the table view to display the fetched data
                     self.tableView.reloadData()
                 }
             }
      // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackData.count // Return the number of feedback items
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
