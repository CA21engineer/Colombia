//
//  IndexTabViewController.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/14.
//

import UIKit

//後々消去
struct TemporaryWork {
    let id: Int
    let title: String
    let imageUrl: String
    let isFavorite: Bool
}

class WorksIndexTabViewController: UITabBarController {
    
    //仮設定
    private var works: [TemporaryWork] = []
    private var favoriteWorks: [TemporaryWork] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ここでAPIリクエストを取得し
        // 一覧用レポジトリとお気に入り用レポジトリを作成
        // WorksIndexViewControllerの引数にレポジトリを入れてあげる
        
        fetchAPI()
        let worksIndexVC = WorksIndexViewController(works: works)
        worksIndexVC.tabBarItem.title = "一覧"
        worksIndexVC.tabBarItem.tag = 1
        worksIndexVC.tabBarItem.image = UIImage(named: "document")
        
        let favoriteWorksIndexVC = WorksIndexViewController(works: favoriteWorks)
        favoriteWorksIndexVC.tabBarItem.title = "お気に入り"
        favoriteWorksIndexVC.tabBarItem.tag = 2
        favoriteWorksIndexVC.tabBarItem.image = UIImage(named: "favorite")
        
        let vcList: [ UIViewController ] = [ worksIndexVC, favoriteWorksIndexVC ]
        setViewControllers(vcList, animated: true)
    }
    
    private func fetchAPI() {
        // フェッチ処理
        // repository.fetch() etc...
        
        for num in 1...23 {
            if num % 2 == 0 {
                let work = TemporaryWork(id: 4168, title: "しろばこ\(num)", imageUrl: "http://shirobako-anime.com/images/ogp.jpg", isFavorite: false)
                works.append(work)
            }
            else {
                let work = TemporaryWork(id: 4168, title: "しろばこ\(num)", imageUrl: "http://shirobako-anime.com/images/ogp.jpg", isFavorite: true)
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
