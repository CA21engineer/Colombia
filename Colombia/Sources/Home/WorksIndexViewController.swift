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
        }
    }
    private let disposeBag = DisposeBag()
    
    //状態の変化を保存しておく（仮）
    private var favoriteStatus : [Bool] = []
    private let works: [TemporaryWork]
    
    init(works: [TemporaryWork]){
        self.works = works
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        favoriteStatus = [Bool](repeating: false, count: works.count)
        for (index, work) in works.enumerated() {
            favoriteStatus[index] = work.isFavorite
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
            cell.configure(work: works[index])
            cell.isFavorite = favoriteStatus[index]
        }
        else {
            cell.isHidden = true
            return cell
        }
        
        // cellを再利用する際にdisposeBagを初期化すること！
        // お気に入り機能
        cell.favoriteButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                cell.isFavorite = cell.isFavorite ? false : true
                let index = indexPath.section * 3 + indexPath.row
                self?.favoriteStatus[index] = cell.isFavorite
                
                //*****Todo***
            })
            .disposed(by: cell.disposeBag)
        return cell
    }
}
