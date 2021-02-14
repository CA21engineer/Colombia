//
//  IndexViewController.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/14.
//

import UIKit

class WorksIndexViewController: UIViewController {
    
    @IBOutlet weak var worksIndexCollectionView: UICollectionView! {
        didSet {
            worksIndexCollectionView.delegate = self
            worksIndexCollectionView.dataSource = self
            worksIndexCollectionView.register(WorksIndexCollectionViewCell.nib, forCellWithReuseIdentifier: WorksIndexCollectionViewCell.identifier)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:20, left:30, bottom:5, right: 30)
        layout.minimumInteritemSpacing = 10
        let size = UIScreen.main.bounds.size
        let cellSize = (size.width - 30) / 4
        layout.itemSize = CGSize(width: cellSize, height: cellSize + 15)
        worksIndexCollectionView.collectionViewLayout = layout
        
        let bgImage = UIImageView()
        bgImage.image = UIImage(named: "annict.png")
        bgImage.contentMode = .scaleToFill
        worksIndexCollectionView.backgroundView = bgImage
        
        // Do any additional setup after loading the view.
    }
}

extension WorksIndexViewController : UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 9
    }
}

extension WorksIndexViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = worksIndexCollectionView.dequeueReusableCell(withReuseIdentifier: WorksIndexCollectionViewCell.identifier, for: indexPath) as! WorksIndexCollectionViewCell
        return cell
    }
    
    
}
