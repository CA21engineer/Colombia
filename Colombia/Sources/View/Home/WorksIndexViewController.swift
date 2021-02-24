//
//  IndexViewController.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/14.
//

import UIKit
import RxSwift
import RxCocoa

class WorksIndexViewController: UIViewController {
    
    @IBOutlet weak var worksIndexCollectionView: UICollectionView! {
        didSet {
            worksIndexCollectionView.delegate = self
            worksIndexCollectionView.dataSource = self
            worksIndexCollectionView.register(WorksIndexCollectionViewCell.nib, forCellWithReuseIdentifier: WorksIndexCollectionViewCell.identifier)
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = .white
            worksIndexCollectionView.refreshControl = refreshControl
        }
    }
    
    private let disposeBag = DisposeBag()
    let activityIndicator = UIActivityIndicatorView()
    var works: [Work] = []
    let favoriteValueChanged = PublishRelay<Work>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setComponent()
    }
    
    private func setComponent() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:20, left:30, bottom:5, right: 30)
        layout.minimumInteritemSpacing = 5
        let size = UIScreen.main.bounds.size
        let cellSize = (size.width - 30) / 3.5
        layout.itemSize = CGSize(width: cellSize, height: cellSize + 15)
        worksIndexCollectionView.collectionViewLayout = layout
        
        let bgImage = UIImageView()
        bgImage.image = UIImage(named: "annict")
        bgImage.contentMode = .scaleToFill
        worksIndexCollectionView.backgroundView = bgImage
        
        DispatchQueue.main.async {
            // メインスレッドの中にいれないと真ん中にならない
            self.activityIndicator.center = self.view.center
            self.activityIndicator.color = .white
            self.activityIndicator.style = .large
            self.view.addSubview(self.activityIndicator)
        }
    }
}

extension WorksIndexViewController : UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(ceil(Double(works.count) / 3))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 詳細画面に移動
    }
}

extension WorksIndexViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = worksIndexCollectionView.dequeueReusableCell(withReuseIdentifier: WorksIndexCollectionViewCell.identifier, for: indexPath) as! WorksIndexCollectionViewCell

        
        let index = indexPath.section * 3 + indexPath.row
        if index < works.count {
            let work = works[index]
            
            DispatchQueue.main.async {
                cell.configure(work: work)
                cell.isFavorite = work.isFavorite
            }
        }
        else {
            DispatchQueue.main.async {
                cell.isHidden = true
            }
            return cell
        }
        
        // cellを再利用する際にdisposeBagを初期化すること！
        // お気に入り機能
        cell.favoriteButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                cell.isFavorite = cell.isFavorite ? false : true
                let index = indexPath.section * 3 + indexPath.row
                
                self.works[index].isFavorite = cell.isFavorite
                self.favoriteValueChanged.accept(self.works[index])
                //*****Todo***
            })
            .disposed(by: cell.disposeBag)
        return cell
    }
}
