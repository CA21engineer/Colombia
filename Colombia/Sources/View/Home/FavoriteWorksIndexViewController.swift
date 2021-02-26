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
//            let cellSize = (collectionView.bounds.width - 30) / 3.5
            let cellSize = (250) / 3.5
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
            .subscribe(onNext: {[weak self] work, actionAt in
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
                
//                //お気に入り画面にお気に入りしたアイコンの追加 / 解除したアイコンの削除
//                let value = work.isFavorited ? favoriteWorks.value + [work] : favoriteWorks.value.filter({ $0.id != work.id })
        
                if actionAt != ActionAt.favorite {
                    self.collectionView?.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        //お気に入り作品のデータ更新時にお気に入り画面のCollectionViewをreload
        worksIndexModel.favoriteWorks.subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.collectionView?.reloadData()
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Int(ceil(Double(worksIndexModel.works.value.count) / 3))
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorksIndexCollectionViewCell.identifier, for: indexPath) as! WorksIndexCollectionViewCell

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
            cell.isFavorited = work.isFavorited
        }
        
        // お気に入り機能
        cell.favoriteButton.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                cell.isFavorited = !cell.isFavorited
                work.isFavorited = cell.isFavorited
                self.worksIndexModel.favoriteValueChanged.accept((work, ActionAt.favorite))
            })
            .disposed(by: cell.disposeBag)
        return cell
    }
}
