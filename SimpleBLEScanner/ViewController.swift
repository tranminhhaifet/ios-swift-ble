//
//  ViewController.swift
//  SimpleBLEScanner
//
//  Created by hai on 2/12/20.
//  Copyright © 2020 biorithm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints =  false
        imageView.image = UIImage(named: "login")
        imageView.layer.cornerRadius = 150/2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let emailField: UITextField = {
        let emailField = UITextField()
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.placeholder = "Email Address"
        emailField.layer.borderColor = UIColor.lightGray.cgColor
        emailField.layer.borderWidth = 1
        emailField.layer.cornerRadius = 10
        return emailField
    }()
    
    private let passwordField: UITextField = {
        let passwordField = UITextField()
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.placeholder = "Password"
        passwordField.layer.borderColor = UIColor.lightGray.cgColor
        passwordField.layer.borderWidth  = 1
        passwordField.isSecureTextEntry = true
        passwordField.layer.cornerRadius = 10
        return passwordField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Continue", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        addContraints()
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    }
    
    private func addContraints() {
        var contraints  = [NSLayoutConstraint]()
        
        // Image size
        let imageWidth =  CGFloat(150)
        
        // Add image
        contraints.append(imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100))
        contraints.append(imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        contraints.append(imageView.widthAnchor.constraint(equalToConstant: imageWidth))
        contraints.append(imageView.heightAnchor.constraint(equalToConstant: imageWidth))
        
        // Add email
        contraints.append(emailField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 100))
        contraints.append(emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
        contraints.append(emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20))
        contraints.append(emailField.heightAnchor.constraint(equalToConstant: 50))
        
        // Add passowrd
        contraints.append(passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20))
        contraints.append(passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
        contraints.append(passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20))
        contraints.append(passwordField.heightAnchor.constraint(equalToConstant: 50))
        
        // Add button
        contraints.append(loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20))
        contraints.append(loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
        contraints.append(loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20))
        contraints.append(loginButton.heightAnchor.constraint(equalToConstant: 50))
        
        // Activate
        NSLayoutConstraint.activate(contraints)
    }
    
    
    @objc func didTapLoginButton()  {
        
        let tabBarVC = UITabBarController()
        let scanner = generateNavController(vc: BLEViewController(), title: "Scanner",  color: .cyan)
        let aws = generateNavController(vc: AWSIoTViewController(), title: "AWSIoT", color: .cyan)
        let setting = generateNavController(vc: SettingViewController(), title: "Setting", color: .cyan)
        
        tabBarVC.tabBar.barTintColor = .cyan
        tabBarVC.setViewControllers([scanner, aws, setting], animated: false)
        tabBarVC.modalPresentationStyle =  .fullScreen
        present(tabBarVC, animated: true)
    }
    
    func generateNavController(vc: UIViewController, title: String, color: UIColor) ->  UINavigationController {
        let nc = UINavigationController(rootViewController: vc)
        nc.navigationBar.barTintColor =  color
        nc.title = title
        return  nc
    }
}

