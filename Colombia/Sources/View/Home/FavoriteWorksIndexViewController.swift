//
//  FavoriteWorksIndexViewController.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/25.
//
import UIKit
import RxSwift
import RxCocoa

final class FavoriteWorksIndexViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(WorksIndexCollectionViewCell.nib, forCellWithReuseIdentifier: WorksIndexCollectionViewCell.identifier)
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 5, right: 30)
            layout.minimumInteritemSpacing = 5
            
            let showingRowNum = 3
            let cellSize = (collectionView.bounds.width - 130) / CGFloat(showingRowNum)
            layout.itemSize = CGSize(width: cellSize, height: cellSize + 15)
            collectionView.collectionViewLayout = layout
            
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = .white
            
            let bgImage = UIImageView()
            bgImage.image = UIImage(named: "annict")
            bgImage.contentMode = .scaleToFill
            collectionView.backgroundView = bgImage
        }
    }
    
    private let disposeBag = DisposeBag()
    private let worksIndexModel: WorksIndexModel
    
    init(worksIndexModel: WorksIndexModel = .shared) {
        self.worksIndexModel = worksIndexModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //お気に入り作品のデータ更新時にお気に入り画面のCollectionViewをreload
        worksIndexModel.favoriteWorks.subscribe(
            onNext: {[weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension FavoriteWorksIndexViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // **TODO** 詳細画面に移動
    }
}

extension FavoriteWorksIndexViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        worksIndexModel.favoriteWorks.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorksIndexCollectionViewCell.identifier, for: indexPath) as! WorksIndexCollectionViewCell
        
        let index = indexPath.row
        let work = worksIndexModel.favoriteWorks.value[index]
        
        cell.configure(work: work)
        cell.isFavorited = work.isFavorited
        
        // cellを再利用する際にdisposeBagを初期化すること！
        cell.favoriteButton.rx.tap
            .subscribe(
                onNext: {[weak self] in
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
