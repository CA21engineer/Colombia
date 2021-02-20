//
//  WorksIndexCollectionViewCell.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/14.
//

import UIKit
import RxSwift
import Nuke

class WorksIndexCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var disposeBag = DisposeBag()
    var isFavorite : Bool = false {
        didSet {
            if isFavorite {
                let image = UIImage(named: "red_heart")
                favoriteButton.setBackgroundImage(image, for: .normal)
            }
            else {
                let image = UIImage(named: "gray_heart")
                favoriteButton.setBackgroundImage(image, for: .normal)
            }
        }
    }
    
    
    override func prepareForReuse() {
        isHidden = false
        disposeBag = DisposeBag()
    }
    
    func configure(work: TemporaryWork) {
        titleLabel.text = work.title
        if let imageUrl = URL(string: work.imageUrl) {
            self.iconImageView.setImage(with: imageUrl)
        }
    }
}
