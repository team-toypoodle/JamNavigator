//
//  DemotapesTableViewController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/08.
//

import UIKit

final class DemotapesTableViewClass: UITableViewController {
    private var demotapes:[String] = [
        "世界にひとつだけの花", "パプリカ"
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
        
        return cell
    }

}
