//
//  ViewController.swift
//  Marathon4
//
//  Created by Diyor Tursunov on 12/11/24.
//

import UIKit

class Mock {
    let title: String
    var isSelected: Bool
    
    init(title: String, isSelected: Bool) {
        self.title = title
        self.isSelected = isSelected
    }
    
    static func prepare() -> [Mock] {
        var result: [Mock] = []
        for i in 1 ... 30 {
            result.append(.init(title: "Item \(i)", isSelected: false))
        }
        return result
    }
}

class ViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var items = Mock.prepare()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Marathon 4"
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        tableView.register(cellType: UITableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "test", style: .done, target: self, action: #selector(shufflePressed))
    }
    
    @objc func shufflePressed() {
        items.shuffle()
        tableView.reloadSections(.init(integer: 0), with: .fade)
    }
    
    func moveToTop(from index: Int) {
        guard index < items.count else { return }

        // Get the item to move
        let item = items[index]

        // Remove it from the current position and insert at the beginning
        items.remove(at: index)
        items.insert(item, at: 0)

        // Update the table view with animations
        tableView.beginUpdates()
        let fromIndexPath = IndexPath(row: index, section: 0)
        let toIndexPath = IndexPath(row: 0, section: 0)
        tableView.moveRow(at: fromIndexPath, to: toIndexPath)
        tableView.endUpdates()
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(UITableViewCell.self, for: indexPath)
        cell.prepareForReuse()
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isSelected ? .checkmark : .none
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        item.isSelected.toggle()
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = item.isSelected ? .checkmark : .none
        }
        
        if item.isSelected {
            moveToTop(from: indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}


extension UITableView {
    public func register(cellType: (some UITableViewCell & Reusable).Type) {
        register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
    }

    public func registerNib(cellType: (some UITableViewCell & Reusable).Type) {
        register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
    }

    public func dequeueCell<Cell: UITableViewCell & Reusable>(_ cell: Cell.Type, for indexPath: IndexPath) -> Cell {
        let dequeuedCell = dequeueReusableCell(withIdentifier: cell.reuseIdentifier, for: indexPath)
        guard let typedCell = dequeuedCell as? Cell else {
            fatalError(
                "Wrong cell type \(String(describing: dequeuedCell.self)) for identifier \(cell.reuseIdentifier)"
            )
        }
        return typedCell
    }
}


public protocol Reusable {
    static var reuseIdentifier: String { get }
    static var nib: UINib { get }
}

extension Reusable {
    public static var reuseIdentifier: String {
        String(describing: self)
    }

    public static var nib: UINib {
        UINib(nibName: String(describing: self), bundle: nil)
    }
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}
