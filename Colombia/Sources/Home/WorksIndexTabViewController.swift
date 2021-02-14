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

        let worksIndexVC = WorksIndexViewController()
        worksIndexVC.tabBarItem.title = "一覧"
        worksIndexVC.tabBarItem.tag = 1
        worksIndexVC.tabBarItem.image = UIImage(named: "document.png")
        
        let favoriteWorksIndexVC = WorksIndexViewController()
        favoriteWorksIndexVC.tabBarItem.title = "お気に入り"
        favoriteWorksIndexVC.tabBarItem.tag = 2
        favoriteWorksIndexVC.tabBarItem.image = UIImage(named: "favorite.png")
        
        let vcList: [UIViewController] = [ worksIndexVC, favoriteWorksIndexVC ]
        setViewControllers(vcList, animated: true)
        
//        worksIndexVC.tabBarItem.badgeValue = "5"
//        worksIndexVC.tabBarItem.image = UIImage(named: "file")?.resize(width: 30)
        
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
