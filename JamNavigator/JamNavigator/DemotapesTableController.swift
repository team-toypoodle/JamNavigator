//
//  DemotapesTableController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/08.
//

import UIKit
import Amplify
import AWSAPIPlugin

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
    
    // IDを指定して、デモテープインスタンスを取得する（コールバックで）
    func getDemotape(idString: String, callback: @escaping (Bool, Demotape?) -> Void) {
        Amplify.API.query(request: .get(Demotape.self, byId: idString)) {
            event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let demotape):
                    guard let demotape = demotape else {
                        print("Could not find demotape")
                        return
                    }
                    print("Successfully retrieved demotape: \(demotape)")
                    callback(true, demotape)
                    
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    callback(false, nil)
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
                callback(false, nil)
            }
        }
    }
    
    func listTodos(callback: @escaping (Bool, List<Demotape>?) -> Void) {
        let demotape = Demotape.keys
        let predicate = demotape.name != ""
        Amplify.API.query(request: .paginatedList(Demotape.self, where: predicate, limit: 1000)) {
            event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let tapes):
                    print("Successfully retrieved list of todos count=: \(tapes.count)")
                    callback(true, tapes)
                    
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    callback(false, nil)
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
                callback(false, nil)
            }
        }
    }
    
}
