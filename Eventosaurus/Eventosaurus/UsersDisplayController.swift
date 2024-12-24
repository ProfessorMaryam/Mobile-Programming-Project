import UIKit
import FirebaseFirestore

class UsersDisplayController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var UserSearch: UISearchBar!
    
    var usersList: [(fullName: String, email: String)] = []
    var filteredUsersList: [(fullName: String, email: String)] = []
    
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
        let db = Firestore.firestore()

        db.collection("Users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching user names: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else { return }

            var fetchedUsers: [(String, String)] = []
            
            for document in snapshot.documents {
                if let fullName = document.get("Full Name") as? String,
                   let email = document.get("Email") as? String,
                   let isAdmin = document.get("Is Admin") as? Bool, !isAdmin {
                    fetchedUsers.append((fullName, email))
                }
            }

            self.usersList = fetchedUsers
            self.filteredUsersList = fetchedUsers

            print("Fetched Users: \(self.usersList)") // Debug log

            DispatchQueue.main.async {
                self.userTableView.reloadData()
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
            cell.NameDisplayLbl.text = user.fullName
            cell.EmailDisplayLbl.text = user.email
            return cell
        }
        return UITableViewCell()
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
        userInfoVC.userEmail = userEmail  // <-- Pass email here

        // Push the view controller onto the navigation stack
        self.navigationController?.pushViewController(userInfoVC, animated: true)
    }
}
