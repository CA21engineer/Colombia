//
//  WorksIndexCollectionViewCell.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/14.
//

import UIKit

class WorksIndexCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
