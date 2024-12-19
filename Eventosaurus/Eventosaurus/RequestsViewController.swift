import UIKit
import FirebaseFirestore

class RequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var notifs: [String] = []  // Array to hold the full names

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
        
        // Fetch user names from Firestore
        fetchUserNames()
    }

    // Fetch Full Names from the Users collection in Firestore
    func fetchUserNames() {
        db.collection("Requests").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                // Debugging: Print the number of documents fetched
                print("Documents count: \(snapshot?.documents.count ?? 0)")
                
                // Clear the existing names in case the data is reloaded
                self.notifs.removeAll()
                
                // Loop through the documents and get the "Full Name"
                for document in snapshot!.documents {
                    if let fullName = document.get("Full Name") as? String {
                        // Add the full name to the notifs array
                        self.notifs.append(fullName)
                    }
                }
                
                // Debugging: Print the fetched names
                print("Fetched names: \(self.notifs)")
                
                // Reload the table view after fetching data
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }


    // MARK: - UITableViewDataSource methods

    // Number of rows in the table (equal to the number of names)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifs.count
    }

    // Populate the table view cells with the names
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the custom cell with the correct identifier
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayRequestsCell", for: indexPath) as? DisplayRequestsTVCTableViewCell {
            // Set the label of the cell to the full name from the notifs array
            cell.DisplayName.text = notifs[indexPath.row] + " has requested to be an organizer"
            return cell
        }
        
        // If the cell couldn't be dequeued, return a default cell
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90 // Height for each cell
    }
}
