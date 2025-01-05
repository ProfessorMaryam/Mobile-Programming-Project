import UIKit
import FirebaseFirestore
import FirebaseAuth

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var eventsTextView: UITextView!

    var selectedDate = Date()
    var totalSquares = [String]()
    var events: [[String: Any]] = []
    var eventsByDate: [String: [[String: Any]]] = [:]
    let db = Firestore.firestore()
    var userEmail: String? {
        return Auth.auth().currentUser?.email
    }

    // DateFormatter is now a global variable accessible throughout the class
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setCellsView()
        fetchJoinedEvents()
    }

    func fetchJoinedEvents() {
         let userEmail = User.loggeduser

        db.collection("Event_User")
            .whereField("email", isEqualTo: userEmail)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching events: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No joined events found.")
                    return
                }

                let eventIDs = documents.compactMap { $0.data()["event_id"] as? String }
                self.db.collection("Events").whereField(FieldPath.documentID(), in: eventIDs).getDocuments { eventSnapshot, error in
                    if let error = error {
                        print("Error fetching event details: \(error)")
                        return
                    }

                    guard let eventDocs = eventSnapshot?.documents else { return }
                    self.events = eventDocs.map { doc in
                        var data = doc.data()
                        data["eventID"] = doc.documentID
                        return data
                    }

                    // Map events to their respective dates
                    self.eventsByDate = self.events.reduce(into: [String: [[String: Any]]]()) { result, event in
                        if let timestamp = event["Date"] as? Timestamp {
                            let date = self.dateFormatter.string(from: timestamp.dateValue())
                            result[date, default: []].append(event)
                        }
                    }

                    DispatchQueue.main.async {
                        self.setMonthView()
                    }
                }
            }
    }

    func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 8
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }

    func setMonthView() {
        totalSquares.removeAll()

        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)

        var count = 1
        while count <= 42 {
            if count <= startingSpaces || count - startingSpaces > daysInMonth {
                totalSquares.append("")
            } else {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }

        monthLabel.text = CalendarHelper().monthString(date: selectedDate) + " " + CalendarHelper().yearString(date: selectedDate)
        collectionView.reloadData()
        updateEventsTextView()
    }

    func updateEventsTextView() {
        guard let eventsTextView = eventsTextView else {
            print("eventsTextView is nil.")
            return
        }

        let currentMonthYear = CalendarHelper().monthString(date: selectedDate) + " " + CalendarHelper().yearString(date: selectedDate)
        let eventsInMonth = events.filter {
            if let timestamp = $0["Date"] as? Timestamp {
                let eventDate = timestamp.dateValue()
                return CalendarHelper().monthString(date: eventDate) + " " + CalendarHelper().yearString(date: eventDate) == currentMonthYear
            }
            return false
        }

        if eventsInMonth.isEmpty {
            eventsTextView.text = "No events this month."
        } else {
            eventsTextView.text = eventsInMonth.map { event in
                guard let eventName = event["Event Name"] as? String,
                      let timestamp = event["Date"] as? Timestamp else { return "" }
                let eventDate = dateFormatter.string(from: timestamp.dateValue())
                return "\(eventDate): \(eventName)"
            }.joined(separator: "\n")
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalendarCell
        let day = totalSquares[indexPath.item]
        cell.dayOfMonth.text = day
        cell.dayOfMonth.textColor = .black
        cell.backgroundColor = .clear

        if let dayInt = Int(day), dayInt > 0 {
            let fullDate = dateFormatter.string(from: CalendarHelper().setDay(date: selectedDate, day: dayInt))
            if eventsByDate[fullDate] != nil {
                cell.backgroundColor = .systemBlue
                cell.dayOfMonth.textColor = .white
            }
        }

        return cell
    }

    @IBAction func previousMonth(_ sender: Any) {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }

    @IBAction func nextMonth(_ sender: Any) {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }

    override open var shouldAutorotate: Bool {
        return false
    }
}
