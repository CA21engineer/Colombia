//
//  FavoriteWorksIndexViewController.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/25.
//
import UIKit
import RxSwift
import RxCocoa

//お気に入り画面
final class FavoriteWorksIndexViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(WorksIndexCollectionViewCell.nib, forCellWithReuseIdentifier: WorksIndexCollectionViewCell.identifier)
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 5, right: 30)
            layout.minimumInteritemSpacing = 5
            let cellSize = 240 / collectionView.showingRowNum
            layout.itemSize = CGSize(width: cellSize, height: cellSize + 15)
            collectionView.collectionViewLayout = layout
            
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = .white
        }
    }
    
    private let disposeBag = DisposeBag()
    private let worksIndexModel: WorksIndexModel
    
    init(worksIndexModel: WorksIndexModel = .shared) {
        self.worksIndexModel = worksIndexModel
        super.init(nibName: nil, bundle: nil)
        
        //お気に入りの状態に変更があった時
        self.worksIndexModel.favoriteValueChanged
            .subscribe(onNext: {[weak self] work, callingVC in
                guard let self = self else { return }
                
                let favoriteWorks =  self.worksIndexModel.favoriteWorks
                
                if work.isFavorited {
                    //お気に入り追加されたとき
                    let value = favoriteWorks.value + [work]
                    favoriteWorks.accept(value)
                    // ② work をRealmに新しく追加する
                }
                else {
                    //お気に入り解除された時
                    let value = favoriteWorks.value.filter({ $0.id != work.id })
                    favoriteWorks.accept(value)
                    // ③work をRealmから削除する
                }
        
                if callingVC == .index {
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        //お気に入り作品のデータ更新時にお気に入り画面のCollectionViewをreload
        worksIndexModel.favoriteWorks.subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        })
        .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setComponent()
    }
    
    private func setComponent() {
        
        let bgImage = UIImageView()
        bgImage.image = UIImage(named: "annict")
        bgImage.contentMode = .scaleToFill
        collectionView.backgroundView = bgImage
    }
}

extension FavoriteWorksIndexViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // **TODO** 詳細画面に移動
    }
}

extension FavoriteWorksIndexViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        worksIndexModel.works.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorksIndexCollectionViewCell.identifier, for: indexPath) as! WorksIndexCollectionViewCell

        let works = self.worksIndexModel.favoriteWorks.value
        let index = indexPath.row
        
        guard index < works.count else {
            DispatchQueue.main.async {
                cell.isHidden = true
            }
            return cell
        }
        
        let work = works[index]
        DispatchQueue.main.async {
            cell.configure(work: work)
            cell.isFavorited = work.isFavorited
        }
        
        // お気に入り機能
        cell.favoriteButton.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                var work = self.worksIndexModel.favoriteWorks.value[index]
                work.isFavorited.toggle()
                cell.isFavorited = work.isFavorited
                self.worksIndexModel.favoriteValueChanged.accept((work, .favorite))
            })
            .disposed(by: cell.disposeBag)
        return cell
    }
}
