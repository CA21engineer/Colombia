//
//  IndexTabViewController.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/14.
//

import UIKit
import RxSwift
import RxCocoa

//後々消去
struct TemporaryWork {
    let id: Int
    let title: String
    let imageUrl: String
    var isFavorite: Bool
}

class WorksIndexTabViewController: UITabBarController {
    //仮設定
    private var works: [Work] = []
    private var favoriteWorks: [Work] = []
    private let disposeBag = DisposeBag()
    private let repository : AnnictDataRepository
    
    private let worksIndexVC = WorksIndexViewController()
    private let favoriteWorksIndexVC = WorksIndexViewController()
    
    init(repository: AnnictDataRepository){
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ここでAPIリクエストを取得し
        // 一覧用レポジトリとお気に入り用レポジトリを作成
        // WorksIndexViewControllerの引数にレポジトリを入れてあげる
        
        worksIndexVC.tabBarItem.title = "一覧"
        worksIndexVC.tabBarItem.tag = 1
        worksIndexVC.tabBarItem.image = UIImage(named: "document")
        worksIndexVC.works = works
        
        favoriteWorksIndexVC.tabBarItem.title = "お気に入り"
        favoriteWorksIndexVC.tabBarItem.tag = 2
        favoriteWorksIndexVC.tabBarItem.image = UIImage(named: "favorite")
        favoriteWorksIndexVC.works = favoriteWorks
        
        let vcList: [ UIViewController ] = [ worksIndexVC, favoriteWorksIndexVC ]
        setViewControllers(vcList, animated: true)

        worksIndexVC.activityIndicator.startAnimating()
        favoriteWorksIndexVC.activityIndicator.startAnimating()
        fetchAPI()
        //一覧画面でお気に入りの状態に変更があった時
        worksIndexVC.favoriteValueChanged
            .subscribe(onNext: { work in
                
                //お気に入り画面にお気に入りしたアイコンの追加 / 解除したアイコンの削除
                if(work.isFavorite) {
                    self.favoriteWorksIndexVC.works.append(work)
                }
                else {
                    self.favoriteWorksIndexVC.works.removeAll { $0.id == work.id }
                }
                self.favoriteWorksIndexVC.worksIndexCollectionView?.reloadData()
            })
            .disposed(by: disposeBag)
        
        //お気に入り画面でお気に入りの状態に変更があった時
        favoriteWorksIndexVC.favoriteValueChanged
            .subscribe(onNext: { [ weak self ] work in
                guard let self = self else { return }
                
                //おきに入り画面でお気に入り解除 → お気に入り画面からそのアイコンを削除, 一覧画面でのそのアイコンのお気に入り状態の解除
                if( work.isFavorite == false ) {
                    let index = self.works.firstIndex { $0.id == work.id }
                    if let index = index {
                        self.worksIndexVC.works[index].isFavorite = false
                        self.worksIndexVC.worksIndexCollectionView?.reloadData()
                    }
                    self.favoriteWorksIndexVC.works.removeAll { $0.id == work.id }
                    self.favoriteWorksIndexVC.worksIndexCollectionView?.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        worksIndexVC.worksIndexCollectionView?
            .refreshControl?
            .rx
            .controlEvent(.valueChanged)
            .subscribe(
                onNext: { [weak self] in
                    self?.fetchAPI()
                })
            .disposed(by: disposeBag)
    }
    
    private func showRetryAlert(with error: Error, retryhandler: @escaping () -> ()) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            retryhandler()
        })
        present(alertController, animated: true, completion: nil)
    }
    
    private func fetchAPI() {
        repository.fetch()
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { model in
                    self.works = model.works
                    for work in self.works {
                       if work.isFavorite {
                        self.favoriteWorks.append(work)
                       }
                    }
                    self.worksIndexVC.works = self.works
                    self.favoriteWorksIndexVC.works = self.favoriteWorks
                    self.worksIndexVC.worksIndexCollectionView?.reloadData()
                    self.favoriteWorksIndexVC.worksIndexCollectionView?.reloadData()
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
        self.worksIndexVC.activityIndicator.stopAnimating()
        self.favoriteWorksIndexVC.activityIndicator.stopAnimating()
        worksIndexVC.worksIndexCollectionView.refreshControl?.endRefreshing()
    }
}
