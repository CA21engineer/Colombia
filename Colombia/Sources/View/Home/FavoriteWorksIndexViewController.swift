//
//  FavoriteWorksIndexViewController.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/25.
//

import UIKit
import RxSwift
import RxCocoa

class FavoriteWorksIndexViewController: UIViewController {
    // DIを利用
    init(){
        self.worksIndexModel = .shared
        super.init(nibName: nil, bundle: nil)
        
        //お気に入りの状態に変更があった時
        self.worksIndexModel.favoriteValueChanged
            .subscribe(onNext: { [weak self] work in
                guard let self = self else { return }
                let favoriteWorks =  self.worksIndexModel.favoriteWorks
                
                //お気に入り画面にお気に入りしたアイコンの追加 / 解除したアイコンの削除
                
                if work.isFavorite {
                    favoriteWorks.accept(favoriteWorks.value + [work])
                }
                else {
                    favoriteWorks.accept(favoriteWorks.value.filter({ $0.id != work.id }))
                }
            })
            .disposed(by: disposeBag)
        
        //お気に入り作品のデータ更新時にお気に入り画面のCollectionViewをreload
        worksIndexModel.favoriteWorks.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.worksIndexCollectionView?.reloadData()
        })
        .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var worksIndexCollectionView: UICollectionView! {
        didSet {
            worksIndexCollectionView.delegate = self
            worksIndexCollectionView.dataSource = self
            worksIndexCollectionView.register(WorksIndexCollectionViewCell.nib, forCellWithReuseIdentifier: WorksIndexCollectionViewCell.identifier)
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = .white
        }
    }
    
    private let disposeBag = DisposeBag()
    private let worksIndexModel: WorksIndexModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setComponent()
    }
    
    private func setComponent() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 5, right: 30)
        layout.minimumInteritemSpacing = 5
        let size = UIScreen.main.bounds.size
        let cellSize = (size.width - 30) / 3.5
        layout.itemSize = CGSize(width: cellSize, height: cellSize + 15)
        worksIndexCollectionView.collectionViewLayout = layout
        
        let bgImage = UIImageView()
        bgImage.image = UIImage(named: "annict")
        bgImage.contentMode = .scaleToFill
        worksIndexCollectionView.backgroundView = bgImage
    }
}

extension FavoriteWorksIndexViewController : UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(ceil(Double(worksIndexModel.works.value.count) / 3))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 詳細画面に移動
    }
}

extension FavoriteWorksIndexViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = worksIndexCollectionView.dequeueReusableCell(withReuseIdentifier: WorksIndexCollectionViewCell.identifier, for: indexPath) as! WorksIndexCollectionViewCell
        //一覧画面ではfavoriteworks→works
        let works = self.worksIndexModel.favoriteWorks.value
        let index = indexPath.section * 3 + indexPath.row
        
        guard index < works.count else {
            DispatchQueue.main.async {
                cell.isHidden = true
            }
            return cell
        }
        
        var work = works[index]
        DispatchQueue.main.async {
            cell.configure(work: work)
            cell.isFavorite = work.isFavorite
        }
        
        // お気に入り機能
        cell.favoriteButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                cell.isFavorite = cell.isFavorite ? false : true
                work.isFavorite = cell.isFavorite
                self.worksIndexModel.favoriteValueChanged.accept(work)
                // 一覧画面に
                // DB更新
            })
            .disposed(by: cell.disposeBag)
        return cell
    }
}
