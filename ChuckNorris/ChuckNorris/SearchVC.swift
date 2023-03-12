//
//  SearchVC.swift
//  ChuckNorris
//
//  Created by Roman Yarmoliuk on 10.02.2023.
//

import UIKit

class SearchVC: UIViewController {
    
    let tableView = UITableView()
    var arrOfJokes = [Result]()
    var numberOfRows = 0
    
    private var timer: Timer? // used for search delay


    var url = "https://api.chucknorris.io/jokes/search?query="
    
    let searchController = UISearchController()
    
    lazy var jokeManager = JokeManager(urlStr: url)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search joke"
        
        jokeManager.searchCallBack = { (model) -> Void in
            self.didUpdateJokeWithSearch(with: model)
        }
                
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
    
    
    func didUpdateJokeWithSearch(with model: JokeData) {
        DispatchQueue.main.async {
            self.numberOfRows = model.total
            self.arrOfJokes = model.result
            self.tableView.reloadData()
        }

    }
    
}

extension SearchVC: UISearchBarDelegate {
    
    override class func accessibilityLanguage() -> String? {
        "en"
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var query = ""
        
        searchText.forEach { char in
            if char == " " {
                query.append("_")
            } else {
                query.append(char)
            }
        }

        url = "https://api.chucknorris.io/jokes/search?query=\(query)"

        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.jokeManager.urlStr = self.url
            self.jokeManager.fetch(type: .search)
        })
        
    }
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
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
       
        cell?.detailTextLabel?.isEnabled = true
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
