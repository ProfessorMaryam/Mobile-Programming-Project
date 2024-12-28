import UIKit
import Firebase

class OrganizerEditViewController: UIViewController {
   
   let db = Firestore.firestore()
   @IBOutlet weak var saveBtn: UIButton!
  

    @IBOutlet weak var brieftxt: UITextField!
    @IBOutlet weak var emailtxt: UITextField!
   @IBOutlet weak var usernametxt: UITextField!
   
   override func viewDidLoad() {
       super.viewDidLoad()
       loadUserData()
   }
   
   func loadUserData() {
       let userEmail = User.loggedInemail
       
       db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { [weak self] snapshot, error in
           if let error = error {
               print("Error fetching user data: \(error.localizedDescription)")
               return
           }
           
           guard let documents = snapshot?.documents,
                 let document = documents.first else {
               print("User document not found")
               return
           }
           
           // Get the user data
           let fullName = document.get("Full Name") as? String ?? ""
           let email = document.get("Email") as? String ?? ""
           let brief = document.get("Brief") as? String ?? ""
           
           // Update the UI on the main thread
           DispatchQueue.main.async {
               self?.usernametxt.text = fullName
               self?.emailtxt.text = email
               self?.brieftxt.text = brief
           }
       }
   }
   
   @IBAction func saveButtonTapped(_ sender: UIButton) {
       guard let username = usernametxt.text, !username.isEmpty,
             let email = emailtxt.text, !email.isEmpty else {
           showAlert(title: "Error", message: "Username and email cannot be empty")
           return
       }
       
       let brief = brieftxt.text ?? ""
       let userEmail = User.loggedInemail
       
       db.collection("Users").whereField("Email", isEqualTo: userEmail).getDocuments { [weak self] snapshot, error in
           if let error = error {
               print("Error fetching user document: \(error.localizedDescription)")
               self?.showAlert(title: "Error", message: "Failed to update profile. Please try again.")
               return
           }
           
           guard let document = snapshot?.documents.first else {
               print("User document not found")
               self?.showAlert(title: "Error", message: "User not found")
               return
           }
           
           // Update the user data
           document.reference.updateData([
               "Full Name": username,
               "Email": email,
               "Brief": brief
           ]) { error in
               if let error = error {
                   print("Error updating user data: \(error.localizedDescription)")
                   self?.showAlert(title: "Error", message: "Failed to update profile. Please try again.")
               } else {
                   print("Profile updated successfully!")
                   self?.showAlert(title: "Success", message: "Profile updated successfully!")
               }
           }
       }
   }
   
   func showAlert(title: String, message: String) {
       let alert = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "OK", style: .default))
       DispatchQueue.main.async {
           self.present(alert, animated: true)
       }
   }
}
