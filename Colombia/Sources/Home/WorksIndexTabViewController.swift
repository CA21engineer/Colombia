//
//  IndexTabViewController.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/14.
//

import UIKit

class WorksIndexTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ここでAPIリクエストを取得し
        // 一覧用レポジトリとお気に入り用レポジトリを作成
        // WorksIndexViewControllerの引数にレポジトリを入れてあげる

        let worksIndexVC = WorksIndexViewController()
        worksIndexVC.tabBarItem.title = "一覧"
        worksIndexVC.tabBarItem.tag = 1
        worksIndexVC.tabBarItem.image = UIImage(named: "document")
        
        let favoriteWorksIndexVC = WorksIndexViewController()
        favoriteWorksIndexVC.tabBarItem.title = "お気に入り"
        favoriteWorksIndexVC.tabBarItem.tag = 2
        favoriteWorksIndexVC.tabBarItem.image = UIImage(named: "favorite")
        
        let vcList: [ UIViewController ] = [ worksIndexVC, favoriteWorksIndexVC ]
        setViewControllers(vcList, animated: true)
    }
}
