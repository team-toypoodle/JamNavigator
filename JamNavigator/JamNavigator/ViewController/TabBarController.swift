import UIKit

protocol BadgeControlDelegate: AnyObject {
    func updateBadge()
}

class TabBarController: UITabBarController, BadgeControlDelegate {
    
    var userSub: String = ""
    var meetTableVC: MeetsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let recVC = self.viewControllers?[0] as? RecordingViewController
        let demoNavVC = self.viewControllers?[1] as? UINavigationController
        let demoVC = demoNavVC?.topViewController as? DemotapesTableViewClass
        let reqNavVC = self.viewControllers?[2] as? UINavigationController
        let reqVC = reqNavVC?.topViewController as? MatchConfirmTableViewController
        let meetNavVC = self.viewControllers?[3] as? UINavigationController
        meetTableVC = meetNavVC?.topViewController as? MeetsTableViewController
        recVC?.userSub = userSub
        demoVC?.userSub = userSub
        demoVC?.delegate = self
        reqVC?.userSub = userSub
        reqVC?.delegate = self
        meetTableVC?.userSub = userSub
        meetTableVC?.delegate = self
        
        updateBadge()
    }
    
    func updateBadge() {
    
        listMatchingItems(targetUseId: userSub) {success, matchingItems in
            guard
                let matchingItems = matchingItems
            else { return }
            DispatchQueue.main.async {
                self.initBadges(count: matchingItems.count, index: 2)
            }
        }
        
        listMeetsItems(targetUseId: userSub) {[weak self] success, matchingItems in
            guard
                let matchingItems = matchingItems
            else { return }
            self?.meetTableVC?.meetsItems = matchingItems
            DispatchQueue.main.async {
                self?.initBadges(count: matchingItems.count, index: 3)
            }
        }
    }
    
    private func initBadges(count: Int, index: Int) {
        guard let item = self.tabBar.items?[index] else { return }
        if count > 0 {
            item.badgeValue = count.description
        } else {
            item.badgeValue = nil
        }
    }
}
