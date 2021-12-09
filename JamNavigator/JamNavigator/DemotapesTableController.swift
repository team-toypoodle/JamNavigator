//
//  DemotapesTableController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/08.
//

import UIKit

final class DemotapesTableViewClass: UITableViewController {
    private var demotapes:[String] = [
        "テルツェット三重奏曲", "ビバルディ 春", "ショパン 革命", "パプリカ", "夜に駆ける", "うっせぇわ"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demotapes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemotapeCell", for: indexPath)
        
        cell.textLabel?.text = demotapes[indexPath.row]
        cell.imageView?.image = UIImage(named: "PlayButton")
        
        return cell
    }

}
