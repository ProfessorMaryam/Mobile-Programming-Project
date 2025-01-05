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
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
}
    




protocol WriteFeedbackDelegate: AnyObject {
    func didSubmitFeedbackSuccessfully()
}

class WriteFeedbackViewController: UIViewController {
    
    
    @IBOutlet weak var SubmitButtn: UIButton!
    @IBOutlet weak var FeedBackTxt: UITextView!
    
    weak var delegate: WriteFeedbackDelegate?
        
        var eventID: String?
        var selectedStarRating = 0  // Track the selected star rating
        
        override func viewDidLoad() {
            super.viewDidLoad()
            print("Event ID in WriteFeedbackViewController: \(eventID ?? "No event ID")")
               
        }
        
        // Action for the submit button when the user writes feedback
        @IBAction func submitFeedbackButton(_ sender: UIButton) {
            let feedbackDescription = FeedBackTxt.text ?? ""
            
            // Check if feedback is empty
            if feedbackDescription.isEmpty {
                let alert = UIAlertController(title: "Error", message: "Please enter some feedback before submitting.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            
            // Show the star rating alert after the feedback is written
            showStarRatingAlert { [weak self] selectedRating in
                guard let self = self else { return }
                self.selectedStarRating = selectedRating
                
                // Save both feedback description and star rating to Firebase
                self.saveFeedbackAndRating(description: feedbackDescription, stars: selectedRating)
            }
        }

        // Show star rating alert to allow user to select stars
        func showStarRatingAlert(completion: @escaping (Int) -> Void) {
            let alertController = UIAlertController(title: "How would you rate the event?", message: nil, preferredStyle: .alert)
            
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
            
            // Add "Submit" button to confirm the rating
            let confirmAction = UIAlertAction(title: "Submit", style: .default) { _ in
                completion(self.selectedStarRating)  // Pass the selected star rating to the completion handler
            }
            
            // Add "Cancel" button to dismiss the alert without selecting a rating
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            // Present the alert to the user
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }

        // Handle star taps in the star rating alert
        @objc func starTapped(_ sender: UIButton) {
            // Get the stack view containing the star buttons
            guard let stackView = sender.superview as? UIStackView else { return }
            
            // Reset the tint color of all stars to light gray
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
            
            // Set the selected star rating based on the tapped button's tag
            self.selectedStarRating = sender.tag
        }

        // Save the feedback and star rating to Firestore
        func saveFeedbackAndRating(description: String, stars: Int) {
            guard let eventID = eventID else {
                print("Event ID is missing")
                return
            }
            
            let db = Firestore.firestore()
            let eventRef = db.collection("Events").document(eventID)  // Reference to the Event document
            
            // Create feedback data
            let feedbackData: [String: Any] = [
                "FeedBack": description,
                "Stars": stars,
                "EventID": eventRef  // Store the EventID as a reference
            ]
            
            // Save feedback in the Feedbacks collection
            db.collection("FeedBack").addDocument(data: feedbackData) { error in
                if let error = error {
                    print("Error adding feedback: \(error.localizedDescription)")
                } else {
                    print("Feedback and star rating successfully saved!")
                    
                    // Notify the delegate when feedback is submitted successfully
                    self.delegate?.didSubmitFeedbackSuccessfully()
                    
                    // Dismiss this view controller
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
