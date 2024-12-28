import UIKit
import FirebaseFirestore

class UsersDisplayController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var UserSearch: UISearchBar!
    
    var usersList: [(fullName: String, email: String)] = []  //tuple containing the full name and email of each user
    var filteredUsersList: [(fullName: String, email: String)] = [] //for the search function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTableView.delegate = self
        userTableView.dataSource = self
        
        let nib = UINib(nibName: "DisplayUsersTableViewCell", bundle: nil)
        userTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        fetchUserNamesFromFirestore()
        
        UserSearch.delegate = self
        UserSearch.placeholder = "Search User"
    }

    // Fetch users from Firestore and update the table view
    func fetchUserNamesFromFirestore() {
        let db = Firestore.firestore() //firestore database reference

        db.collection("Users").getDocuments { (snapshot, error) in //goes to the "Users" Collection and gets all the documents in there
            if let error = error {
                print("Error fetching user names: \(error.localizedDescription)")
                return
            }

            //making shut snapshot is valid and contains documents
            guard let snapshot = snapshot else { return }

            var fetchedUsers: [(String, String)] = [] //fetched users are stored here
            
            for document in snapshot.documents { //sloops through every document in the snapshot
                if let fullName = document.get("Full Name") as? String, //get the full name from the field
                   let email = document.get("Email") as? String, //get the email from the field
                   let isAdmin = document.get("Is Admin") as? Bool, !isAdmin { //if user is not an admin...
                    fetchedUsers.append((fullName, email)) //... append to the fetched users list
                    
                    //Admin account does not append just in cause they accidentally delete their own account
                }
            }

            //at this point in time both contain the same data
            self.usersList = fetchedUsers
            self.filteredUsersList = fetchedUsers

            print("Fetched Users: \(self.usersList)") // Debug log

            DispatchQueue.main.async {
                self.userTableView.reloadData() //loads all the fetched data
            }
        }
    }

    // Table View DataSource and Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsersList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? DisplayUsersTableViewCell {
            let user = filteredUsersList[indexPath.row]
            cell.NameDisplayLbl.text = user.fullName //refrencing the label in the nib
            cell.EmailDisplayLbl.text = user.email //referencing the label in th enib
            return cell
        }
        return UITableViewCell() //return cell
    }

    // MARK: - UISearchBarDelegate Methods

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredUsersList = usersList
        userTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredUsersList = usersList
        } else {
            filteredUsersList = usersList.filter { user in
                let fullNameMatch = user.fullName.lowercased().contains(searchText.lowercased())
                let emailMatch = user.email.lowercased().contains(searchText.lowercased())
                return fullNameMatch || emailMatch
            }
        }
        userTableView.reloadData()
    }

    // MARK: - UITableViewDelegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected user's email
        let selectedUser = filteredUsersList[indexPath.row]
        print("Selected email: \(selectedUser.email)") // Debug log

        // Pass the selected user's email to the next view controller
        navigateToUserInfoViewController(userEmail: selectedUser.email)
    }

    // Navigate to UserInfoViewController with the selected user's email
    func navigateToUserInfoViewController(userEmail: String) {
        // Instantiate the UserInfoViewController from the storyboard
        guard let userInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoVC") as? UserInfoViewController else {
            print("Error: Could not instantiate UserInfoViewController.")
            return
        }

        // Set the title of the navigation bar for the UserInfoViewController
        userInfoVC.title = "User Information"

        // Pass the selected user's email to UserInfoViewController
        userInfoVC.userEmail = userEmail

        // Push the view controller onto the navigation stack
        self.navigationController?.pushViewController(userInfoVC, animated: true)
    }

    

 
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the email of the user to delete
            let userToDelete = filteredUsersList[indexPath.row]
            deleteUserFromFirestore(email: userToDelete.email)

            // Remove the user from the local data arrays (usersList and filteredUsersList)
            filteredUsersList.remove(at: indexPath.row)
            usersList.removeAll { $0.email == userToDelete.email }

            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // Delete user from Firestore
    func deleteUserFromFirestore(email: String) {
        let db = Firestore.firestore()

        // Find the document by email and delete it
        db.collection("Users").whereField("Email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot, let document = snapshot.documents.first else {
                print("Error: User not found in Firestore.")
                return
            }

            // Delete the document
            document.reference.delete { error in
                if let error = error {
                    print("Error deleting document: \(error.localizedDescription)")
                } else {
                    print("User deleted successfully.")
                }
            }
        }
    }
}
