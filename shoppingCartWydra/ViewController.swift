//
//  ViewController.swift
//  shoppingCartWydra
//
//  Created by BRENDEN WYDRA on 10/31/23.
//

import UIKit

struct Item: Codable {
    var name: String
    var category: String
    var isChecked: Bool
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var itemInput: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryInput: UITextField!
    
    let defaults = UserDefaults.standard
    
    var items = [Item]()
    
    var currentIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        if let temp = defaults.data(forKey: "items") {
            let decoder = JSONDecoder()
            if let temp2 = try? decoder.decode([Item].self, from: temp){
                items = temp2
            }
        }
    }

    @IBAction func addItemPress(_ sender: UIButton) {
        if (itemInput.text != "" && categoryInput.text != "") {
            if items.contains(where: {item in item.name == itemInput.text}) {
                let alert = UIAlertController(title: "ERROR", message: "Item already exists", preferredStyle: .alert)
                let alertExit = UIAlertAction(title: "OK", style: .default)
                alert.addAction(alertExit)
                present(alert, animated: true)
                return
            }
            items.append(Item(name: itemInput.text!, category: categoryInput.text!, isChecked: false))
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items){
                defaults.set(encoded, forKey: "items")
            }
            itemInput.text = ""
            categoryInput.text = ""
            tableView.reloadData()
        }
    }
    
    @IBAction func sortPress(_ sender: UIButton) {
        items.sort(by: {
            if ($0.category == $1.category){
                return $0.name < $1.name
            }
            return $0.category < $1.category
        })
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(items){
            defaults.set(encoded, forKey: "items")
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].isChecked = !items[indexPath.row].isChecked
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(items){
            defaults.set(encoded, forKey: "items")
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")! as! MyCell
        cell.nameLabel?.text = items[indexPath.row].name
        cell.categoryLabel?.text = items[indexPath.row].category
        if items[indexPath.row].isChecked {
            cell.checkedLabel.text = "✅"
        }
        else {
            cell.checkedLabel.text = "❎"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {_,_,_ in
            self.items.remove(at: indexPath.row)
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.items){
                self.defaults.set(encoded, forKey: "items")
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: {_,_,_ in
            let cell = tableView.cellForRow(at: indexPath) as! MyCell
            self.itemInput.text = cell.nameLabel.text
            self.categoryInput.text = cell.categoryLabel.text
            self.items.remove(at: indexPath.row)
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(self.items){
                self.defaults.set(encoded, forKey: "items")
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        editAction.backgroundColor = UIColor.systemOrange
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
}

