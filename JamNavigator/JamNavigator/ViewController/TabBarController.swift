import UIKit

class TabBarController: UITabBarController {
    
    var userSub: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 0
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let recVC = self.viewControllers?[0] as? RecordingViewController
        let demoNavVC = self.viewControllers?[1] as? UINavigationController
        let demoVC = demoNavVC?.topViewController as? DemotapesTableViewClass
        let reqNavVC = self.viewControllers?[2] as? UINavigationController
        let reqVC = reqNavVC?.topViewController as? MatchConfirmTableViewController
        let meetNavVC = self.viewControllers?[3] as? UINavigationController
        let meetTableVC = meetNavVC?.topViewController as? MeetsTableViewController
        recVC?.userSub = userSub
        demoVC?.userSub = userSub
        reqVC?.userSub = userSub
        listMatchingItems(targetUseId: userSub) {success, matchingItems in
            guard
                let matchingItems = matchingItems,
                matchingItems.count > 0
            else { return }
            DispatchQueue.main.async {
                self.initBadges(count: matchingItems.count.description, index: 2)
            }
        }
        
        listMeetsItems(targetUseId: userSub) {[weak self] success, matchingItems in
            guard
                let matchingItems = matchingItems,
                matchingItems.count > 0
            else { return }
            meetTableVC?.meetsItems = matchingItems
            DispatchQueue.main.async {
                self?.initBadges(count: matchingItems.count.description, index: 3)
            }
        }
    }
    
    
    
    private func initBadges(count: String, index: Int) {
        guard let item = self.tabBar.items?[index] else { return }
        item.badgeValue = count
    }
}
