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
    private var demotapes: List<Demotape> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listDemotapes(){
            (success, list) in
            if success {
                if let list = list{
                    self.demotapes = list
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }
        }
        tableView.allowsSelection = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demotapes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemotapeCell", for: indexPath)
        let item = demotapes[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.imageView?.image = UIImage(named: "PlayButton")
        cell.detailTextLabel?.text = Array(item.instruments?.map{$0!} ?? []).joined(separator: ", ") + "   " + Array(item.genres?.map{$0!} ?? []).joined(separator: ", ")
        
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
    
    // デモテープの一覧をクラウドから収集
    func listDemotapes(callback: @escaping (Bool, List<Demotape>?) -> Void) {
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
