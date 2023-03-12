//
//  ChuckNorrisVC.swift
//  ChuckNorris
//
//  Created by Roman Yarmoliuk on 02.02.2023.
//

import UIKit

class ChuckNorrisVC: UIViewController {
    
    var url = ""
    
    var isAbleRefreshingJoke = false
   
    var data = Result(categories: [""], created_at: "", id: "", value: "")

    private let edgeSpacing: CGFloat = 12
    
    private var isSaved = false {
        didSet {
            let imageName = isSaved ? "bookmark.fill" : "bookmark"
            image = UIImage(systemName: imageName)!
            navigationItem.rightBarButtonItem?.image = image
        }
    }
    
    private var image = UIImage(systemName: "bookmark")!
    
    private lazy var jokeManager = JokeManager(urlStr: url)
        
    private let jokeLabel: UILabel = {
        let label = UILabel()
        
        label.text = "wait for download"
        label.numberOfLines = 0
        label.textAlignment = .natural
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
                
        label.text = "date: "
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5

        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        
        label.text = "category: none"
        label.textAlignment = .right
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    
    private let chuckImage: UIImageView = {
        let image = UIImage(named: "pedro")
        let chuckImageView = UIImageView(image: image!)
        return chuckImageView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = UIStackView.Distribution.fill
        stackView.alignment = .fill
        stackView.spacing = 12

        
        return stackView
    }()
    private let smallStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = .fill
        stackView.spacing = 32
        
        return stackView
    }()
   
    let scrollView = UIScrollView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(saveTapped))
        if isAbleRefreshingJoke {
            getSavedJoke()
        } else {
            jokeManager.standartCallBack = { (model) -> Void in
                self.didUpdateJoke(with: model)
                self.data = model
            }
            jokeManager.fetch(type: .standart)
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(buttonTapped))
            view.addGestureRecognizer(tapGesture)
        }

        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        
        smallStackView.addArrangedSubview(dateLabel)
        smallStackView.addArrangedSubview(categoryLabel)
        
        mainStackView.addArrangedSubview(chuckImage)
        mainStackView.addArrangedSubview(jokeLabel)
        mainStackView.addArrangedSubview(smallStackView)
        
        scrollView.backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeSpacing).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeSpacing).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        mainStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        // important to scroll
        mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
    }
        
    
    deinit {
        print("deinited")
    }
    
    
    @objc func saveTapped() {
        if isSaved {
            UserDefaultsManager.shared.removeFromData(data: data)
        } else {
            UserDefaultsManager.shared.setData(dataToSave: data)
        }
        isSaved.toggle()
        
        VibrationManager.shared.vibrate(for: .tap)

        navigationItem.rightBarButtonItem?.image = image
    }
    
    @objc func buttonTapped() {
        jokeLabel.text = ""
        jokeManager.fetch(type: .standart)
    }
    
    func getSavedJoke() {
        updateVC(model: data)
    }
    
    func updateVC(model: Result) {
       
        jokeLabel.text = model.value.replaceToPedro()
        dateLabel.text = String(model.created_at.prefix(10))
      
        categoryLabel.text = {
            if model.categories.isEmpty {
                return "category: none"
            } else {
                return "category: \(model.categories[0])"
            }
        }()
        
        checkIfJokeIsSaved(model: model)
    }
    
    func didUpdateJoke(with model: Result) {
        DispatchQueue.main.async {
            self.updateVC(model: model)
        }
    }
    
    func checkIfJokeIsSaved(model: Result) {
        let dataToCheck = UserDefaultsManager.shared.getData()!
        
        self.isSaved = false
        
        dataToCheck.forEach { item in
            if item.id == model.id {
                self.isSaved = true
            }
        }
        self.navigationItem.rightBarButtonItem?.image = self.image
    }
    
}

extension String {
    func replaceToPedro() -> String {
        let changedText = self.replacingOccurrences(of: "chuck", with: "Pedro", options: .caseInsensitive)
        let textToShow = changedText.replacingOccurrences(of: "norris", with: "Pascal", options: .caseInsensitive)

        return textToShow
    }
    
}
