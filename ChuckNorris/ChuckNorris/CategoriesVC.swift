//
//  CategoriesVC.swift
//  ChuckNorris
//
//  Created by Roman Yarmoliuk on 06.02.2023.
//

import UIKit

class CategoriesVC: UIViewController {
    
    let tableView = UITableView()
    var categories = ["random"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Categories"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRequest()
//        VibrationManager.shared.selectionVibrate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func getRequest() {
        
        let categoryURL = "https://api.chucknorris.io/jokes/categories"
       
        guard let url = URL(string: categoryURL) else { return }
        
        let session = URLSession.shared
        
        session.dataTask(with: url) { (data, response, error) in
           
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print (json)
                self.didUpdateMenu(with: json as! [String])
            } catch {
                print (error)
            }
        }.resume()
        
    }
    
    func didUpdateMenu(with categories: [String]) {
        DispatchQueue.main.async {
            self.categories = ["random"]
            self.categories += categories
            self.tableView.reloadData()
        }
    }
    
}

extension CategoriesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var url = ""
        
        let cell = tableView.cellForRow(at: indexPath)
        
        let title = cell?.textLabel?.text!
        
        if title == "random" {
            url = "https://api.chucknorris.io/jokes/random"
        } else {
            url = "https://api.chucknorris.io/jokes/random?category=\(title!)"
        }
                
        let vc = ChuckNorrisVC()
        vc.url = url
        
        navigationController?.pushViewController(vc, animated: false)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        VibrationManager.shared.vibrate(for: .tap)
    }

}

