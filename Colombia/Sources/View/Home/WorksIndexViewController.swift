//
//  IndexViewController.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/14.
//

import UIKit
import RxSwift
import RxCocoa

//一覧画面・お気に入り画面
class WorksIndexViewController: UIViewController {
    
    // DIを利用
    init(repository: AnnictDataRepository) {
        self.repository = repository
        self.worksIndexModel = .shared
        super.init(nibName: nil, bundle: nil)
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
            worksIndexCollectionView.refreshControl = refreshControl
        }
    }
    
    private let disposeBag = DisposeBag()
    private let activityIndicator = UIActivityIndicatorView()
    private let worksIndexModel: WorksIndexModel
    private let repository: AnnictDataRepository
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setComponent()
        
        //お気に入りの状態に変更があった時
        worksIndexModel.favoriteValueChanged
            .subscribe(onNext: { [weak self] notification in
                guard let self = self else { return }
                
                let work = notification.0
                let actionAt = notification.1
                
                let index = self.worksIndexModel.works.value.firstIndex { $0.id == work.id }
                if let index = index {
                    var works =  self.worksIndexModel.works.value as [Work]
                    works[index].isFavorite = work.isFavorite
                    self.worksIndexModel.works.accept(works)
                }
                
                if actionAt == Action.favorite {
                    self.worksIndexCollectionView?.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        //リフレッシュ（お気に入りの時はださないようにしたい）
        worksIndexCollectionView
            .refreshControl?
            .rx
            .controlEvent(.valueChanged)
            .subscribe(
                onNext: { [weak self] in
                    self?.fetchAPI()
                })
            .disposed(by: disposeBag)
        
        activityIndicator.startAnimating()
        fetchAPI()
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
        
        DispatchQueue.main.async {
            // メインスレッドの中にいれないと真ん中にならない
            self.activityIndicator.center = self.view.center
            self.activityIndicator.color = .white
            self.activityIndicator.style = .large
            self.view.addSubview(self.activityIndicator)
        }
    }
    
    //処理を別のファイルに書き上げる必要はない
    private func fetchAPI() {
        repository.fetch()
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] decodeData in
                    guard let self = self else { return }
                    let works = decodeData.works
                    self.worksIndexModel.works.accept(works)
                    
                    //お気に入りデータを更新させる
                    var favoriteWorks: [Work] = []
                    for work in works {
                       if work.isFavorite {
                         favoriteWorks.append(work)
                       }
                    }
                    self.worksIndexModel.favoriteWorks.accept(favoriteWorks)
                    self.worksIndexCollectionView?.reloadData()
                    self.afterFetch()
                },
                onError: { error in
                    self.showRetryAlert(with: error, retryhandler: { self.fetchAPI() })
                    self.afterFetch()
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func afterFetch() {
        activityIndicator.stopAnimating()
        worksIndexCollectionView.refreshControl?.endRefreshing()
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
        return Int(ceil(Double(worksIndexModel.works.value.count) / 3))
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
            cell.isFavorite = work.isFavorite
        }
 
        // cellを再利用する際にdisposeBagを初期化すること！
        // お気に入り機能
        cell.favoriteButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                work.isFavorite = !work.isFavorite
                cell.isFavorite = work.isFavorite
                self.worksIndexModel.favoriteValueChanged.accept((work, Action.index))
                // 一覧画面に
                // DB更新
                // お気に入り画面のfavroite DIを使って書く
            })
            .disposed(by: cell.disposeBag)
        return cell
    }
}
