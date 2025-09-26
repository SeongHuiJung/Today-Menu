//
//  BaseViewController.swift
//  ModuClass
//
//  Created by 정성희 on 9/3/25.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    func configureView() {
        view.backgroundColor = .customBackground
        
        navigationItem.backButtonTitle = ""
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .customBackground
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.fontBlack]
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    }
    
    func configureHierarchy() { }
    func configureLayout() { }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}
