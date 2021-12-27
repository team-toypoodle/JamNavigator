import UIKit

class FilterTableViewController:UITableViewController{

    @IBAction func didTapDoneButton(_ sender: Any) {
        delegate?.applyFilter(filter: activeFilter)
        dismiss(animated: true)
    }
    var activeFilter = FilterContents()
    
    weak var delegate: FilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell",for: indexPath)
        cell.textLabel?.text = activeFilter.all[indexPath.row].name
        if activeFilter.all[indexPath.row].isActive {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        switch cell?.accessoryType {
        case .checkmark:
            cell?.accessoryType = .none
            activeFilter.all[indexPath.row].isActive = false
        case .none?:
            cell?.accessoryType = .checkmark
            activeFilter.all[indexPath.row].isActive = true
        default:
            cell?.accessoryType = .none
        }
    }
    
}
