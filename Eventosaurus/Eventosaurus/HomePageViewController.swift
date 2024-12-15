//
//  HomePageViewController.swift
//  Eventosaurus
//
//  Created by BP-36-201-21 on 04/12/2024.
//

import UIKit








class HomePageViewController: UIViewController {
    @IBOutlet weak var CollectionEventView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CollectionEventView.dataSource = self
        CollectionEventView.delegate = self
        CollectionEventView.collectionViewLayout = UICollectionViewFlowLayout()
        
    }
    
}

extension HomePageViewController: UICollectionViewDataSource{
    func CollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventies.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventSearchCollectionViewCell", for: IndexPath) as! EventSearchCollectionViewCell
        cell.setup(with: eventies[indexPath.row])
        return cell
    }
}











struct Eventi {
    let title: String
    let image: UIImage
}

let eventies: [Eventi] = [
Eventi(title: "Damn", image:#imageLiteral(resourceName: "damn.jpeg")),
Eventi(title: "Damn Damn", image: #imageLiteral(resourceName: "damn.jpeg")),
Eventi(title: "Damn Damn Damn", image: #imageLiteral(resourceName: "damn.jpeg")),
Eventi(title: "Damn Damn Damn Damn", image: #imageLiteral(resourceName: "damn.jpeg"))
]















class EventHomeViewController: UIViewController {
    
    @IBOutlet weak var collectionoView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionoView.dataSource = self
        collectionoView.delegate = self
        collectionoView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
}


    



extension EventHomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCell", for: indexPath) as! EventCollectionViewCell
        cell.setup(with: eventies[indexPath.row])
        return cell
    }
}






extension EventHomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 352, height: 150)
    }
}





extension EventHomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(eventies[indexPath.row].title)
    }
}









class EventCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func setup(with eventi: Eventi) {
        eventImageView.image = eventi.image
        titleLabel.text = eventi.title
    }
}






class ContactUsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}











class FilterSearchViewController: UIViewController {
    
    @IBOutlet weak var HAbutton: UIButton!
    var HAChecked = false
    
    @IBOutlet weak var SPButton: UIButton!
    var SPChecked = false
    
    @IBOutlet weak var FNButton: UIButton!
    var FNChecked = false
    
    @IBOutlet weak var ENButton: UIButton!
    var ENChecked = false
    
    @IBOutlet weak var ARButton: UIButton!
    var ARChecked = false
    
    @IBOutlet weak var CMButton: UIButton!
    var CMChecked = false
    
    @IBOutlet weak var MSButton: UIButton!
    var MSChecked = false
    
    @IBOutlet weak var LTButton: UIButton!
    var LTChecked = false
    
    @IBOutlet weak var PHButton: UIButton!
    var PHChecked = false
    
    @IBOutlet weak var EDButton: UIButton!
    var EDChecked = false
    
    @IBOutlet weak var SLButton: UIButton!
    var SLChecked = false
    
    @IBOutlet weak var FDButton: UIButton!
    var FDChecked = false
    
    
    
    @IBOutlet weak var NRButton: UIButton!
    var NRChecked = false
    
    @IBOutlet weak var CLButton: UIButton!
    var CLChecked = false
    
    @IBOutlet weak var MQButton: UIButton!
    var MQChecked = false
    
    @IBOutlet weak var SRButton: UIButton!
    var SRChecked = false
    
    
    
    
    @IBOutlet weak var WEButton: UIButton!
    var WEChecked = false
    
    @IBOutlet weak var MOButton: UIButton!
    var MOChecked = false
    
    
    
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func HATapped(_ sender: UIButton) {
        HAChecked = !HAChecked
        let imageName = HAChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        HAbutton.setImage(image, for: .normal)
    }
    
    @IBAction func PHTapped(_ sender: UIButton) {
        PHChecked = !PHChecked
        let imageName = PHChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        PHButton.setImage(image, for: .normal)
    }
    
    @IBAction func SPTapped(_ sender: UIButton) {
        SPChecked = !SPChecked
        let imageName = SPChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        SPButton.setImage(image, for: .normal)
    }
    
    @IBAction func FNTapped(_ sender: UIButton) {
        FNChecked = !FNChecked
        let imageName = FNChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        FNButton.setImage(image, for: .normal)
    }
    
    @IBAction func ENTapped(_ sender: Any) {
        ENChecked = !ENChecked
        let imageName = ENChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        ENButton.setImage(image, for: .normal)
    }
    
    @IBAction func ARTapped(_ sender: Any) {
        ARChecked = !ARChecked
        let imageName = ARChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        ARButton.setImage(image, for: .normal)
    }
    
    @IBAction func CMTapped(_ sender: UIButton) {
        CMChecked = !CMChecked
        let imageName = CMChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        CMButton.setImage(image, for: .normal)
    }
    
    @IBAction func EDTapped(_ sender: UIButton) {
        EDChecked = !EDChecked
        let imageName = EDChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        EDButton.setImage(image, for: .normal)
    }
    
    @IBAction func SLTapped(_ sender: UIButton) {
        SLChecked = !SLChecked
        let imageName = SLChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        SLButton.setImage(image, for: .normal)
    }
    
    @IBAction func FDTapped(_ sender: UIButton) {
        FDChecked = !FDChecked
        let imageName = FDChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        FDButton.setImage(image, for: .normal)
    }
    
    @IBAction func LRTapped(_ sender: Any) {
        LTChecked = !LTChecked
        let imageName = LTChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        LTButton.setImage(image, for: .normal)
    }
    
    @IBAction func MSTapped(_ sender: UIButton) {
        MSChecked = !MSChecked
        let imageName = MSChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        MSButton.setImage(image, for: .normal)
    }
    
    
    
    @IBAction func NRTapped(_ sender: UIButton) {
        NRChecked = !NRChecked
        let imageName = NRChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        NRButton.setImage(image, for: .normal)
    }
    
    
    @IBAction func CLTapped(_ sender: UIButton) {
        CLChecked = !CLChecked
        let imageName = CLChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        CLButton.setImage(image, for: .normal)
    }
    
    @IBAction func MQTapped(_ sender: UIButton) {
        MQChecked = !MQChecked
        let imageName = MQChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        MQButton.setImage(image, for: .normal)
    }
    
    @IBAction func SRTapped(_ sender: UIButton) {
        SRChecked = !SRChecked
        let imageName = SRChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        SRButton.setImage(image, for: .normal)
    }
    
    
    
    
    @IBAction func WETapped(_ sender: UIButton) {
        WEChecked = !WEChecked
        let imageName = WEChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        WEButton.setImage(image, for: .normal)
    }
    
    @IBAction func MOTapped(_ sender: UIButton) {
        MOChecked = !MOChecked
        let imageName = MOChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        MOButton.setImage(image, for: .normal)
    }
    
    
    
}


