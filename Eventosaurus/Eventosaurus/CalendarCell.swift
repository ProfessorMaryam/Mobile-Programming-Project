//
//  CalendarCell.swift
//  Eventosaurus
//
//  Created by BP-36-201-21 on 04/12/2024.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedDate = Date()
    var totalSquares = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCellsView()
    }
    
    func setCellsView {
        
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        
    }
    
    @IBOutlet weak var dayOfMonth: UILabel!
}
