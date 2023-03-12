//
//  ViewController.swift
//  ChuckNorris
//
//  Created by Roman Yarmoliuk on 01.02.2023.
//

import UIKit
import CoreHaptics

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let tabBarVC = UITabBarController()
        
        let categoryVC = UINavigationController(rootViewController: CategoriesVC())
        let searchVC = UINavigationController(rootViewController: SearchVC())
        let savedVC = UINavigationController(rootViewController: SavedVC())
        
        categoryVC.title = "Categories"
        searchVC.title = "Search"
        savedVC.title = "Saved"
        
        tabBarVC.setViewControllers([categoryVC, searchVC, savedVC], animated: false)
        
        guard let items = tabBarVC.tabBar.items else {
            return
        }
        let images = ["line.horizontal.3", "magnifyingglass", "bookmark.fill"]
        
        for x in 0..<items.count {
            items[x].image = UIImage(systemName: images[x])
        }
        
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: false)
        
    }
    
}

class VibrationManager {
    
    static let shared = VibrationManager()
    
    private init() {}
    
    var isOn = true
    
    func vibrate(for type: VibrationType) {
        type.apply()
    }
    
}

enum VibrationType {
    case tap, correct, wrong, win, lose
    
    func apply() {
        guard VibrationManager.shared.isOn else { return }
        
        switch self {
        case .tap:
            selectionVibrate()
        case .correct:
            vibrate(for: .success)
        case .wrong:
            vibrate(for: .warning)
        case .win:
            var i = 0
            
            Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { Timer in
                i += 1
                vibrate(for: .success)
                if i == 2 {
                    Timer.invalidate()
                }
            }
        case .lose:
            vibrate(for: .error)
        }
    }
    
}

extension VibrationType {
    
    private func selectionVibrate() {
        DispatchQueue.main.async {
            let selectionFidbackGenerator = UISelectionFeedbackGenerator()
            selectionFidbackGenerator.prepare()
            selectionFidbackGenerator.selectionChanged()
        }
    }
    
    private func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let notificationGenerator = UINotificationFeedbackGenerator()
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(type)
        }
    }
    
    private func fidback(for style: UIImpactFeedbackGenerator.FeedbackStyle) {
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
    private func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    
}

