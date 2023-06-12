//
//  MainTabBarController.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 04.03.2023.
//

import UIKit
import VisionKit

protocol AddTabBarDelegate: AnyObject {
    func plusDidTapped()
}

class MainTabBarController: UITabBarController {
    
    weak var routDelegate: AddTabBarDelegate?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        setValue(CustomTabBar(), forKey: "tabBar")
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .tabBarItemAccent
        tabBar.tintColor = .white
        delegate = self
        
        let homeNav = UINavigationController(rootViewController: ViewController())
        
        let settingsNav = UINavigationController()
        
        let newPostVC = UINavigationController(rootViewController: ViewController())
        
        
        homeNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        settingsNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        newPostVC.tabBarItem = UITabBarItem(title: nil, image: nil, selectedImage: nil)
        
        
        let viewControllers = [homeNav, newPostVC, settingsNav]
        self.setViewControllers(viewControllers, animated: false)
        
        
        guard let tabBar = self.tabBar as? CustomTabBar else { return }
        
        tabBar.didTapButton = { [unowned self] in
            self.routDelegate?.plusDidTapped()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBar.frame.size.height = 95
        tabBar.frame.origin.y = view.frame.height - 95
    }
    
    private func generateVC(viewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        return viewController
    }
    
    func routeToCreateNewAd() {
    }
}

// MARK: - UITabBarController Delegate
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        
        if selectedIndex == 1 {
            return false
        }
        return true
    }
}

class CustomTabBar: UITabBar {
    
    // MARK: - Variables
    public var didTapButton: (() -> ())?
    
    public lazy var middleButton: UIButton! = {
        let middleButton = UIButton()
        
        middleButton.frame.size = CGSize(width: 100, height: 100)
        
        let image = UIImage(named: "btn")!
        middleButton.setImage(image, for: .normal)
        middleButton.tintColor = .white
        middleButton.layer.cornerRadius = 8
        
        middleButton.addTarget(self, action: #selector(self.middleButtonAction), for: .touchUpInside)
        
        self.addSubview(middleButton)
        
        return middleButton
    }()
    
    // MARK: - View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.4
        self.layer.masksToBounds = false

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        middleButton.center = CGPoint(x: frame.width / 2, y: 10)
    }
    
    // MARK: - Actions
    @objc func middleButtonAction(sender: UIButton) {
        didTapButton?()
    }
    
    // MARK: - HitTest
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        
        return self.middleButton.frame.contains(point) ? self.middleButton : super.hitTest(point, with: event)
    }
}
