//
//  SavedVC.swift
//  ChuckNorris
//
//  Created by Roman Yarmoliuk on 10.02.2023.
//

import UIKit

class SavedVC: UIViewController {
    
    let tableView = UITableView()
    var arrOfJokes = [Result]()
    var numberOfRows = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved"
                
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.delegate = self 
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSavedData()
//        VibrationManager.shared.selectionVibrate()
    }
      
    func getSavedData() {

        let data = UserDefaultsManager.shared.getData()!
       
        arrOfJokes = data
        numberOfRows = data.count
        
        tableView.reloadData()
    }
    
}

extension SavedVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
       
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        let value = arrOfJokes[indexPath.row].value.replaceToPedro()
        let categories = arrOfJokes[indexPath.row].categories
       
        cell?.textLabel?.text = value
        
        if !categories.isEmpty {
            var category = ""
            
            categories.forEach { str in
                category += str + ", "
            }
            category.removeLast(2) // removing ", "

            cell?.detailTextLabel?.text = "category: \(category)"
        } else {
            cell?.detailTextLabel?.text = "category: none"
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = arrOfJokes[indexPath.row]
                
        let vc = ChuckNorrisVC()
        vc.data = data
        vc.isAbleRefreshingJoke = true
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        VibrationManager.shared.vibrate(for: .tap)
    }

    
}

