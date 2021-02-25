//
//  IndexTabViewController.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/14.
//
import UIKit

class WorksIndexTabViewController: UITabBarController {
    private let repository: AnnictDataRepository
    
    init(repository: AnnictDataRepository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let worksIndexVC = WorksIndexViewController(repository: repository)
        let favoriteWorksIndexVC = FavoriteWorksIndexViewController()
        
        worksIndexVC.tabBarItem.title = "一覧"
        worksIndexVC.tabBarItem.tag = 1
        worksIndexVC.tabBarItem.image = UIImage(named: "document")
        
        favoriteWorksIndexVC.tabBarItem.title = "お気に入り"
        favoriteWorksIndexVC.tabBarItem.tag = 2
        favoriteWorksIndexVC.tabBarItem.image = UIImage(named: "favorite")
        
        let vcList: [UIViewController] = [ worksIndexVC, favoriteWorksIndexVC ]
        setViewControllers(vcList, animated: true)
    }
}
