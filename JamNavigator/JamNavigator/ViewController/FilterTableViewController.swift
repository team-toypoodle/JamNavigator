import UIKit

class FilterTableViewController:UITableViewController{

    @IBAction func didTapDoneButton(_ sender: Any) {
        dismiss(animated: true)
    }
    let filterContents = [
        "guiter",
        "piano",
        "violin",
        "other"
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterContents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell",for: indexPath)
        cell.textLabel?.text = filterContents[indexPath.row]
        cell.accessoryType = .checkmark
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        switch cell?.accessoryType {
        case .checkmark:
            cell?.accessoryType = .none
        case .none?:
            cell?.accessoryType = .checkmark
        default:
            cell?.accessoryType = .none
        }
    }
    
}
