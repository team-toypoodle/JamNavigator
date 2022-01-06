import UIKit
import Amplify
import AWSAPIPlugin
import AVFoundation

class MeetsTableViewController :UITableViewController{

    @IBOutlet var meetsTableView: UITableView!
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    var meetsItems = Array<Demotape>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let meetsViewNavVC = segue.destination as? UINavigationController,
            let destination = meetsViewNavVC.topViewController as? MeetsViewController,
            let indexPath = meetsTableView.indexPathForSelectedRow
        else { return }
        destination.meetsItem = meetsItems[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetsItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meetsCell", for: indexPath)
        let item = meetsItems[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
}
