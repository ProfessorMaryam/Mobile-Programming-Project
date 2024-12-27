//
//  FeedBackViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-01 on 27/12/2024.
//

import UIKit
import FirebaseFirestore
import Firebase


class FeedBackViewController: UIViewController {
    
    
    var selectedStarRating: Int = 0  // Store the selected star rating
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup if needed
    }
    
    @IBAction func buttonShow(_ sender: UIButton) {
        print("Alert button pressed")
        
        let eventID = "3plSFQlyblfBbvkxSGGH" // Replace this with the actual event ID you want to use
        showFeedbackAlert(forEvent: eventID)
    }
    
    func showFeedbackAlert(forEvent eventID: String) {
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
            self.navigateToFeedbackPage(forEvent: eventID)  // Navigate to feedback page with event ID
        }
        alertController.addAction(feedbackAction)
        
        // Add "Cancel" and "Confirm" actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            print("Confirm button tapped")
            
            // Save the star rating when "Confirm" is tapped, if any star rating is selected
            if self.selectedStarRating > 0 {
                self.saveStarRating(stars: self.selectedStarRating, eventID: eventID)  // Save with event ID
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
    }
    // Method to handle star taps
    @objc func starTapped(_ sender: UIButton) {
        // Get the stack view containing the star buttons
        guard let stackView = sender.superview as? UIStackView else { return }
        
        // Reset the tint color of all stars to light gray
        for star in stackView.arrangedSubviews {
            if let button = star as? UIButton {
                button.tintColor = .lightGray
            }
        }
        
        // Highlight the selected star and all previous stars
        if let index = stackView.arrangedSubviews.firstIndex(of: sender) {
            // Highlight stars up to the tapped one
            for i in 0...index {
                if let button = stackView.arrangedSubviews[i] as? UIButton {
                    button.tintColor = .systemYellow
                }
            }
        }
        
        // Store the rating in the selectedStarRating property
        self.selectedStarRating = sender.tag
        print("Star selected: \(selectedStarRating)")
    }
    
    // Save the star rating to Firestore
    func saveStarRating(stars: Int, eventID: String) {
        let db = Firestore.firestore()
        
        // Prepare the data to be saved (without timestamp)
        let feedbackData: [String: Any] = [
            "Stars": stars,
            "EventID": eventID  // Store the eventID here
        ]
        
        // Save the star rating in the Feedbacks collection
        db.collection("FeedBack").addDocument(data: feedbackData) { error in
            if let error = error {
                print("Error saving star rating: \(error.localizedDescription)")
            } else {
                print("Star rating saved successfully in Feedbacks collection!")
            }
        }
        
    }
    
    // Method to navigate to the feedback page
    func navigateToFeedbackPage(forEvent eventID: String) {
        let storyboardName = "FeedBack"  // Ensure this matches the name of your storyboard
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        if let feedbackVC = storyboard.instantiateViewController(withIdentifier: "WriteFeedbackViewController") as? WriteFeedbackViewController {
            feedbackVC.starRating = self.selectedStarRating  // Pass the selected star rating here
            feedbackVC.eventID = eventID  // Pass the eventID here
            
            feedbackVC.modalPresentationStyle = .fullScreen
            self.present(feedbackVC, animated: true, completion: nil)
        } else {
            print("Could not instantiate WriteFeedbackViewController from the storyboard.")
        }
    }
}
    





class WriteFeedbackViewController: UIViewController {
    
    
    @IBOutlet weak var SubmitButtn: UIButton!
    @IBOutlet weak var FeedBackTxt: UITextView!
    
    // The star rating passed from the previous view controller
    var eventID: String?
    var starRating: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Star rating received: \(starRating)")
        
        
        if let eventID = eventID {
            print("Event ID received: \(eventID)")
        } else {
            print("No Event ID received")
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.29, green: 0.00, blue: 0.51, alpha: 1.0).cgColor, // Purple
            UIColor(red: 0.87, green: 0.19, blue: 0.56, alpha: 1.0).cgColor, // Pink
            UIColor(red: 1.00, green: 0.49, blue: 0.31, alpha: 1.0).cgColor, // Orange
            UIColor(red: 1.00, green: 0.80, blue: 0.50, alpha: 1.0).cgColor // Peach
        ]
        gradient.locations = [0.0, 0.33, 0.66, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    
    @IBAction func submitFeedbackButton(_ sender: Any) {
        
        let feedbackDescription = FeedBackTxt.text ?? ""
        
        if feedbackDescription.isEmpty {
            // Show an alert if no feedback was entered
            let alert = UIAlertController(title: "Error", message: "Please enter some feedback before submitting.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            // Save feedback description and star rating to Firebase
            if let eventID = eventID {  // Ensure eventID is not nil
                saveFeedback(description: feedbackDescription, stars: starRating, eventID: eventID)
            }
            
            // Optionally reset the text view after submission
            FeedBackTxt.text = ""
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    func saveFeedback(description: String, stars: Int, eventID: String) {
        let db = Firestore.firestore()
        
        let eventRef = db.collection("Events").document(eventID)
        
        // Create feedback data
        let feedbackData: [String: Any] = [
            "FeedBack": description,
            "Stars": stars,
            "EventID": eventRef,  // Now store EventID as a reference to the Event document
        ]
        
        // Save feedback in the Feedbacks collection
        db.collection("FeedBack").addDocument(data: feedbackData) { error in
            if let error = error {
                print("Error adding feedback: \(error.localizedDescription)")
            } else {
                print("Feedback successfully added to Feedbacks collection!")
            }
        }
    }
    
    func fetchEventDetails(for feedbackID: String) {
        let db = Firestore.firestore()
        
        // Fetch the feedback document by its ID
        db.collection("FeedBack").document(feedbackID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching feedback: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                // Get the reference to the Event document
                if let eventRef = document.data()?["EventID"] as? DocumentReference {
                    // Now use the reference to fetch the associated Event document
                    eventRef.getDocument { (eventDocument, error) in
                        if let error = error {
                            print("Error fetching event details: \(error.localizedDescription)")
                        } else if let eventDocument = eventDocument, eventDocument.exists {
                            // Successfully fetched the Event document
                            let eventData = eventDocument.data()
                            print("Event Data: \(String(describing: eventData))")
                        }
                    }
                }
            }
        }
    }
}
