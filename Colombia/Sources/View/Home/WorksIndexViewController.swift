//
//  IndexViewController.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/14.
//

import UIKit
import RxSwift
import RxCocoa

//一覧画面
final class WorksIndexViewController: UIViewController {
    
    private let activityIndicator = UIActivityIndicatorView()

    private let repository: AnnictDataRepository
    private let worksIndexModel: WorksIndexModel
    
    private let disposeBag = DisposeBag()
    
    init(repository: AnnictDataRepository, worksIndexModel: WorksIndexModel = .shared) {
        self.repository = repository
        self.worksIndexModel = worksIndexModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(WorksIndexCollectionViewCell.nib, forCellWithReuseIdentifier: WorksIndexCollectionViewCell.identifier)
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 5, right: 30)
            layout.minimumInteritemSpacing = 5

            let cellSize = 280 / 3.5
            layout.itemSize = CGSize(width: cellSize, height: cellSize + 15)
            collectionView.collectionViewLayout = layout
            
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = .white
            collectionView.refreshControl = refreshControl
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setComponent()
        
        
        //一覧画面のハートを赤くする灰色にする
        //お気に入りの状態に変更があった時
        worksIndexModel.favoriteValueChanged
            .subscribe(onNext: {[weak self] work, actionAt in
                guard let self = self else { return }
                
                let index = self.worksIndexModel.works.value.firstIndex { $0.id == work.id }
                if let index = index {
                    var works =  self.worksIndexModel.works.value
                    works[index].isFavorited = work.isFavorited
                    self.worksIndexModel.works.accept(works)
                }
                
                if actionAt != CallingVC.index {
                    self.collectionView?.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        //リフレッシュ（お気に入りの時はださないようにしたい）
        collectionView.refreshControl?.rx.controlEvent(.valueChanged)
            .subscribe(
                onNext: {[weak self] in
                    self?.fetchAPI()
                })
            .disposed(by: disposeBag)
        
        activityIndicator.startAnimating()
       //21個のアニメのデータを一覧画面用に取得
        fetchAPI()
        
        // ① Realmからデータを取り出す。
        // Realm(DB)からお気に入りデータを取り出す。
        // Result<AnnictData> ->  works [Work]
        
        // favoriteWorksの中にそのデータを入れる。
        // worksIndexModel.favoriteWorks.accept(works)
    }

    private func setComponent() {
        
        let bgImage = UIImageView()
        bgImage.image = UIImage(named: "annict")
        bgImage.contentMode = .scaleToFill
        collectionView.backgroundView = bgImage
        
        DispatchQueue.main.async {
            // メインスレッドの中にいれないと真ん中にならない
            self.activityIndicator.center = self.view.center
            self.activityIndicator.color = .white
            self.activityIndicator.style = .large
            self.view.addSubview(self.activityIndicator)
        }
    }
    
    private func fetchAPI() {
        repository.fetch()
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] decodeData in
                    guard let self = self else { return }
                    let works = decodeData.works
                    self.worksIndexModel.works.accept(works)
                    
                    self.collectionView?.reloadData()
                    self.afterFetch()
                },
                onError: {[weak self] error in
                    self?.showRetryAlert(with: error, retryHandler: {[weak self] in
                        self?.activityIndicator.startAnimating()
                        self?.fetchAPI()
                    })
                    self?.afterFetch()
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func afterFetch() {
        activityIndicator.stopAnimating()
        collectionView.refreshControl?.endRefreshing()
    }
    
    private func showRetryAlert(with error: Error, retryHandler: @escaping () -> ()) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            retryHandler()
        })
        present(alertController, animated: true)
    }
}

extension WorksIndexViewController : UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Int(ceil(Double(worksIndexModel.works.value.count) / Double(collectionView.rowNum)))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // *TODO* 詳細画面に移動
    }
}

extension WorksIndexViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.rowNum
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorksIndexCollectionViewCell.identifier, for: indexPath) as! WorksIndexCollectionViewCell
        
        let works = self.worksIndexModel.works.value
        let index = indexPath.section * collectionView.rowNum + indexPath.row
        
        if index < works.count {
            
            DispatchQueue.main.async {
                let work = works[index]
                cell.configure(work: work)
                cell.isFavorited = work.isFavorited
            }
            
            // cellを再利用する際にdisposeBagを初期化すること！
            cell.favoriteButton.rx.tap
                .asDriver()
                .drive(onNext: {[weak self] in
                    guard let self = self else { return }
                    var work = works[index]
                    work.isFavorited.toggle()
                    cell.isFavorited = work.isFavorited
                    self.worksIndexModel.favoriteValueChanged.accept((work, CallingVC.index))
                })
                .disposed(by: cell.disposeBag)
        }
        else {
            DispatchQueue.main.async {
                cell.isHidden = true
            }
        }
        return cell
    }
}
