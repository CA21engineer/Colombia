//
//  WorksIndexCollectionViewCell.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/14.
//

import UIKit
import RxSwift
import Nuke

final class WorksIndexCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    var disposeBag = DisposeBag()
    var isFavorited : Bool = false {
        didSet {
            if isFavorited {
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
//        isHidden = false
        disposeBag = DisposeBag()
    }
    
    func configure(work: Work) {
        titleLabel.text = work.title
        
        //空文字を入れてどうなるか検証
//        guard let imageUrl = work.image.recommendedUrl, imageUrl != "" else {
        guard let imageUrl = "" as String? else {
            let image = UIImage(named: "no_image")
            self.iconImageView.image = image
            return
        }
        if let imageUrl = URL(string: imageUrl) {
            loadImage(with: imageUrl, into: self.iconImageView)
        }
    }
}
