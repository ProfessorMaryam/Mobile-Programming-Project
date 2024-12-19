import UIKit
import FirebaseFirestore

class UsersDisplayController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var UserSearch: UISearchBar!  // Reference to your UISearchBar
    
    // Array to store tuples of (full name, email)
    var usersList: [(fullName: String, email: String)] = []
    var filteredUsersList: [(fullName: String, email: String)] = []  // Array to store filtered results based on the search query
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTableView.delegate = self
        userTableView.dataSource = self
        
        // Register the NIB or class for the custom cell
        let nib = UINib(nibName: "DisplayUsersTableViewCell", bundle: nil)
        userTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // Fetch user names and emails from Firestore
        fetchUserNamesFromFirestore()
        
        // Set up the search bar delegate
        UserSearch.delegate = self
        UserSearch.placeholder = "Search User"
    }

    // Fetch user names and emails from Firestore
    func fetchUserNamesFromFirestore() {
        let db = Firestore.firestore()
        
        // Query the 'Users' collection
        db.collection("Users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching user names: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else { return }

            var fetchedUsers: [(String, String)] = [] // Array to store (full name, email) pairs

            // Loop through the documents and extract the 'Full Name' and 'Email' fields
            for document in snapshot.documents {
                if let fullName = document.get("Full Name") as? String,
                   let email = document.get("Email") as? String {
                    fetchedUsers.append((fullName, email)) // Store the pair as a tuple
                }
            }

            // Update the users list with the fetched data
            self.usersList = fetchedUsers
            self.filteredUsersList = fetchedUsers  // Initially, filtered list is the same as all users

            // Reload the table view on the main thread
            DispatchQueue.main.async {
                self.userTableView.reloadData()
            }
        }
    }

    // MARK: - UITableViewDataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsersList.count // Use filtered data to determine number of rows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90 // Height for each cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? DisplayUsersTableViewCell {
            let user = filteredUsersList[indexPath.row]
            
            // Set the full name and email labels
            cell.NameDisplayLbl.text = user.fullName
            cell.EmailDisplayLbl.text = user.email
            
            return cell
        }
        return UITableViewCell() // Return a default cell if dequeueing fails
    }

    // MARK: - UISearchBarDelegate Methods

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Reset the filtered list to the full users list when cancel is clicked
        filteredUsersList = usersList
        userTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // Function to filter the users based on the search text
    func filterContentForSearchText(_ searchText: String) {
        // Filter the users list by full name or email
        if searchText.isEmpty {
            filteredUsersList = usersList  // If search text is empty, show all users
        } else {
            filteredUsersList = usersList.filter { user in
                let fullNameMatch = user.fullName.lowercased().contains(searchText.lowercased())
                let emailMatch = user.email.lowercased().contains(searchText.lowercased())
                return fullNameMatch || emailMatch  // Return true if either full name or email matches the search
            }
        }
        
        // Reload the table view with the filtered data
        userTableView.reloadData()
    }

    // MARK: - UITableViewDelegate Methods

    // This method handles the swipe-to-delete action
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the user to delete
            let userToDelete = filteredUsersList[indexPath.row]

            // Find the document in Firestore that corresponds to this user
            let db = Firestore.firestore()
            
            // Assuming you have a unique identifier for the user (like email or user ID)
            // Here I'm assuming the user's email is unique and using it to delete from Firestore.
            // Update the query if you have a different unique identifier like userID
            db.collection("Users").whereField("Email", isEqualTo: userToDelete.email).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching user for deletion: \(error.localizedDescription)")
                    return
                }
                
                // Ensure we find the user in Firestore and delete
                if let document = snapshot?.documents.first {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting user: \(error.localizedDescription)")
                        } else {
                            print("User deleted successfully")
                            
                            // After deletion, remove the user from the local list and reload the table
                            self.usersList.removeAll { $0.email == userToDelete.email }
                            self.filteredUsersList.removeAll { $0.email == userToDelete.email }
                            
                            // Reload table view
                            DispatchQueue.main.async {
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                    }
                }
            }
        }
    }
}
