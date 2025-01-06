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
        tableView.register(UINib(nibName: "DisplayUsersTableViewCell", bundle: nil), forCellReuseIdentifier: "DisplayUsersTableViewCell")

        tableView.rowHeight = 150
        // Fetch feedback data for the specific event using EventID
        if let eventID = eventID {
            fetchFeedback(forEventID: eventID)
        }
    }
    
    // Fetch feedback data based on EventID
    func fetchFeedback(forEventID eventID: String) {
        print("Fetching feedback for EventID: \(eventID)")

        // Create a DocumentReference for the EventID
        let eventRef = db.document(eventID) // eventID must be the full path: "/Events/3plSFQlyblfBbvkxSGGH"

        let feedbackRef = db.collection("FeedBack").whereField("EventID", isEqualTo: eventRef)

        feedbackRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching feedback: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No documents found for EventID: \(eventID)")
                return
            }

            print("Fetched \(documents.count) documents for EventID: \(eventID)")

            self.feedbackData = documents.compactMap { document in
                print("Document data: \(document.data())")
                let feedbackText = document.get("FeedBack") as? String ?? "No feedback"
                let stars = document.get("Stars") as? Int ?? 0
                return (feedback: feedbackText, stars: stars)
            }

            print("Feedback data count: \(self.feedbackData.count)")

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the custom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayUsersTableViewCell", for: indexPath) as? DisplayUsersTableViewCell else {
            return UITableViewCell() // Return an empty cell if dequeuing fails
        }
        
        // Get the feedback data for the current row
        let feedback = feedbackData[indexPath.row]
        
        // Set the labels to display feedback and stars
        cell.NameDisplayLbl.text = feedback.feedback // Use NameDisplayLbl for feedback text
        cell.EmailDisplayLbl.text = "\(feedback.stars) ⭐️" // Use EmailDisplayLbl for star ratings
        
        return cell
        

    }
}
