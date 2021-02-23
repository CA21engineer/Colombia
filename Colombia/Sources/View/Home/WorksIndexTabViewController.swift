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
//    private var works: [TemporaryWork] = []
//    private var favoriteWorks: [TemporaryWork] = []
    private var works: [Work] = []
    private var favoriteWorks: [Work] = []
    private let disposeBag = DisposeBag()
    private let repository : AnnictDataRepository
    
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
        
        fetchAPI()
        let worksIndexVC = WorksIndexViewController()
        worksIndexVC.tabBarItem.title = "一覧"
        worksIndexVC.tabBarItem.tag = 1
        worksIndexVC.tabBarItem.image = UIImage(named: "document")
        worksIndexVC.works = works
        
        let favoriteWorksIndexVC = WorksIndexViewController()
        favoriteWorksIndexVC.tabBarItem.title = "お気に入り"
        favoriteWorksIndexVC.tabBarItem.tag = 2
        favoriteWorksIndexVC.tabBarItem.image = UIImage(named: "favorite")
        favoriteWorksIndexVC.works = favoriteWorks
        
        //一覧画面でお気に入りの状態に変更があった時
        worksIndexVC.favoriteValueChanged
            .subscribe(onNext: { work in
                
                //お気に入り画面にお気に入りしたアイコンの追加 / 解除したアイコンの削除
                if(work.isFavorite) {
                    favoriteWorksIndexVC.works.append(work)
                }
                else {
                    favoriteWorksIndexVC.works.removeAll { $0.id == work.id }
                }
                favoriteWorksIndexVC.worksIndexCollectionView?.reloadData()
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
                        worksIndexVC.works[index].isFavorite = false
                        worksIndexVC.worksIndexCollectionView.reloadData()
                    }
                    favoriteWorksIndexVC.works.removeAll { $0.id == work.id }
                    favoriteWorksIndexVC.worksIndexCollectionView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        let vcList: [ UIViewController ] = [ worksIndexVC, favoriteWorksIndexVC ]
        setViewControllers(vcList, animated: true)
    }
    
    private func fetchAPI() {
        // フェッチ処理
        // repository.fetch() etc...
        
        //サンプルデータ
        for num in 1...40 {
            if num % 2 == 0 {
                let work = Work(id: 4168 + num, title: "しろばこ\(num)", image: Image(recommendedUrl: "http://shirobako-anime.com/images/ogp.jpg"), isFavorite: false)
                works.append(work)
            }
            else {
                let work = Work(id: 4168 + num, title: "しろばこ\(num)", image: Image(recommendedUrl: "http://shirobako-anime.com/images/ogp.jpg"), isFavorite: true)
                works.append(work)
            }
        }
        
        for work in works {
            if work.isFavorite {
                favoriteWorks.append(work)
            }
        }
    }
}
