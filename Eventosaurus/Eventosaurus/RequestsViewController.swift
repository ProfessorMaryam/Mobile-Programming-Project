import UIKit
import FirebaseFirestore

class RequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var requests: [String] = []  // Array to hold the concatenated strings for each request
    var emails: [String] = []    // Array to store emails corresponding to requests

    // Firestore reference
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register the custom cell with the correct identifier
        let nib = UINib(nibName: "DisplayRequestsTVCTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DisplayRequestsCell")
        
        // Fetch data from Firestore
        fetchRequests()
    }

    // Fetch data from the "Requests" collection in Firestore
    func fetchRequests() {
        db.collection("Requests").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                // Clear the existing requests in case the data is reloaded
                self.requests.removeAll()
                self.emails.removeAll() // Clear emails as well
                
                // Loop through the documents and fetch required fields
                for document in snapshot!.documents {
                    if let fullName = document.get("Full Name") as? String,
                       let email = document.get("Email") as? String,
                       let message = document.get("Message") as? String,
                       let qualifications = document.get("Qualifications") as? String {
                        
                        // Trim leading and trailing whitespaces
                        let trimmedFullName = fullName.trimmingCharacters(in: .whitespaces)
                        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
                        let trimmedMessage = message.trimmingCharacters(in: .whitespaces)
                        let trimmedQualifications = qualifications.trimmingCharacters(in: .whitespaces)
                        
                        // Concatenate the fields into a single string and append to the array
                        let requestString = "\(trimmedFullName) - \(trimmedEmail) - \(trimmedMessage) - \(trimmedQualifications)"
                        self.requests.append(requestString)
                        self.emails.append(trimmedEmail) // Add email to array for later use
                    }
                }
                
                // Reload the table view on the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - UITableViewDataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the custom cell with the correct identifier
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayRequestsCell", for: indexPath) as? DisplayRequestsTVCTableViewCell {
            // Get the concatenated request string for this row
            let requestString = requests[indexPath.row]
            
            // Split the string into individual components (e.g., name, email, message, qualifications)
            let components = requestString.split(separator: " - ")
            
            if components.count >= 4 {
                let fullName = components[0]
                let email = components[1]
                let message = components[2]
                let qualifications = components[3]
                
                // Set the labels with the data from the split string
                cell.DisplayName.text = fullName + " wants to be an organizer"
                cell.displayEmail.text = String(email)
                cell.displayMessage.text = String(message)
                cell.qualifications.text = String(qualifications)
            }
            
            return cell
        }
        
        // If the cell couldn't be dequeued, return a default cell
        return UITableViewCell()
    }
    
    // MARK: - Swipe Actions for Accept Button
    
    // Leading swipe action (for Accept)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let acceptAction = UIContextualAction(style: .normal, title: "Accept") { (action, view, completionHandler) in
            // Get the email corresponding to the row that was swiped
            let email = self.emails[indexPath.row]
            // Call the acceptRequest function to update and delete the request
            self.acceptRequest(email: email)
            completionHandler(true)
        }
        
        acceptAction.backgroundColor = .green
        let configuration = UISwipeActionsConfiguration(actions: [acceptAction])
        configuration.performsFirstActionWithFullSwipe = true // Ensure it is fully swiped
        return configuration
    }
    
    // Trailing swipe action (for Delete)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            // Get the email corresponding to the row that was swiped
            let email = self.emails[indexPath.row]
            // Call the deleteRequest function to remove the request from Firestore
            self.deleteRequest(email: email)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    // MARK: - Accept Request Action
    
    func acceptRequest(email: String) {
        // Access the Users collection and update the "Is Organizer" field
        db.collection("Users").whereField("Email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }
            
            // If a matching user is found, update the "Is Organizer" field
            if let document = snapshot?.documents.first {
                // Update the "Is Organizer" field to true
                document.reference.updateData([
                    "Is Organizer": true
                ]) { error in
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                    } else {
                        print("User updated successfully")
                        
                        // After the update is successful, delete the request from the "Requests" collection
                        self.deleteRequest(email: email)
                    }
                }
            } else {
                print("No user found with the email \(email)")
            }
        }
    }
    
    // Delete the request from the "Requests" collection after accepting or deleting
    func deleteRequest(email: String) {
        // Find the request in the "Requests" collection and delete it
        db.collection("Requests").whereField("Email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }
            
            // If a matching request is found, delete the request
            if let document = snapshot?.documents.first {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting request: \(error.localizedDescription)")
                    } else {
                        print("Request deleted successfully")
                        
                        // Optionally, update the requests array to remove the deleted request
                        if let index = self.emails.firstIndex(of: email) {
                            self.requests.remove(at: index)
                            self.emails.remove(at: index)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250 // Height for each cell
    }
}
