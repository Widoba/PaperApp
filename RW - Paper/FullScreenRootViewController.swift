//
//  FullScreenRootViewController.swift
//  RW - Paper
//
//  Created for fixing full-screen display issues
//

import UIKit

class FullScreenRootViewController: UIViewController {
    
    // The view controller we're wrapping
    private var contentViewController: UIViewController?
    
    // Background color for the app
    let backgroundColor = UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1.0)
    
    // Add a proper initializer
    init(contentViewController: UIViewController) {
        self.contentViewController = contentViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the view
        view.backgroundColor = backgroundColor
        
        // Add the content view controller using proper containment
        if let contentVC = contentViewController {
            // Add as child view controller
            addChild(contentVC)
            
            // Add the content view to our view
            view.addSubview(contentVC.view)
            
            // Set up Auto Layout constraints
            contentVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentVC.view.topAnchor.constraint(equalTo: view.topAnchor),
                contentVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                contentVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                contentVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            // Notify child it's now in our view hierarchy
            contentVC.didMove(toParent: self)
            
            print("FullScreenRootViewController - Content view controller added: \(type(of: contentVC))")
        }
    }
    
    // MARK: - Status Bar Appearance
    
    override var prefersStatusBarHidden: Bool {
        return contentViewController?.prefersStatusBarHidden ?? false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return contentViewController?.preferredStatusBarStyle ?? .default
    }
    
    // MARK: - Orientation Support
    
    override var shouldAutorotate: Bool {
        return contentViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return contentViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
} 