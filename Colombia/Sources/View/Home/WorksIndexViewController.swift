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
            let cellSize = (collectionView.bounds.width - 30) / 3.5
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
                
                if actionAt != ActionAt.index {
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
        fetchAPI()
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
                    
                    let favoriteWorks = works.compactMap { $0.isFavorited ? $0 : nil }
                    self.worksIndexModel.favoriteWorks.accept(favoriteWorks)
                    
                    self.collectionView?.reloadData()
                    self.afterFetch()
                },
                onError: {[weak self] error in
                    self?.showRetryAlert(with: error, retryhandler: {[weak self] in
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
    
    private func showRetryAlert(with error: Error, retryhandler: @escaping () -> ()) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            retryhandler()
        })
        present(alertController, animated: true, completion: nil)
    }
}

extension WorksIndexViewController : UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Int(ceil(Double(worksIndexModel.works.value.count) / 3))
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorksIndexCollectionViewCell.identifier, for: indexPath) as! WorksIndexCollectionViewCell
        
        let works = self.worksIndexModel.works.value
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
 
        // cellを再利用する際にdisposeBagを初期化すること！
        cell.favoriteButton.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                guard let self = self else { return }
                work.isFavorited = !work.isFavorited
                cell.isFavorited = work.isFavorited
                self.worksIndexModel.favoriteValueChanged.accept((work, ActionAt.index))
            })
            .disposed(by: cell.disposeBag)
        return cell
    }
}
