//
//  AccountDeletedController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/22/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import JGProgressHUD


class AccountDeletedController: UIViewController {
    
    //create variable to reference the firebase data so we can read, wirte and update it
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.title = "My Account"
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = UIColor.matteBlack
        
        // add cancel button to dismiss view
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleSignOut))
        
        setupUI()
    }

    
    @objc func handleDeleteAccount(sender: UIButton) {
        // add animation to the button
        Utilities.animateView(sender)
        print("deleting account...")
        
        // style hud
        hud.textLabel.text = "Deleting Account"
        hud.show(in: view, animated: true)
        
        let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        let storageRef = Storage.storage().reference().child("crew images/\(uid!).png")
        // Removes image from storage
        storageRef.delete { error in
            if let error = error {
                print("error deleting crew member profile pic")
                self.hud.dismiss(animated: true)
                self.showError(title: "Unable to Delete Account", message: error.localizedDescription)
            } else {
                user?.delete(completion: { (error) in
                    if let error = error {
                        // error ocurred
                        self.hud.dismiss(animated: true)
                        self.showError(title: "Unable to Delete Account", message: error.localizedDescription)
                    } else {
                        // delete successful
                        // dismiss loading hud if there's no error
                        self.hud.dismiss(animated: true)
                        self.transitionToHome()
                        }
                    })
        
            }
        }
        
    }
    
    func transitionToHome() {
        let homeController = HomeController()
        navigationController?.pushViewController(homeController, animated: true)
    }
    
    @objc func handleSignOut() {
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
                print("user signed out")
            } catch let err {
                print("Failed to sign out with error ", err)
                self.showError(title: "Sign Out Error", message: "Please try again.")
            }
        }
        // alert
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(signOutAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
    
    // create delete label
    let deleteLabel: UILabel = {
        let label = UILabel()
        label.text = "Your account has been terminated by your affiliate organization. If you need to create a new account with this email address, please delete this account using the button below."
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    // delete button to delete the account from authentication and storage of profile pic
    let deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.logoRed
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleDeleteAccount(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // all code to add any layout UI elements
    private func setupUI() {
        // add and position background color in relationship to the view elements on the view controller
        let silverBackgroundView = UIView()
        silverBackgroundView.backgroundColor = UIColor.silver
        silverBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(silverBackgroundView)
        silverBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        silverBackgroundView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        silverBackgroundView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        silverBackgroundView.heightAnchor.constraint(equalToConstant: 250).isActive = true
    

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(deleteLabel)
        deleteLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        // move label to the right a bit
        deleteLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        deleteLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        deleteLabel.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        view.addSubview(deleteButton)
        deleteButton.topAnchor.constraint(equalTo: deleteLabel.bottomAnchor, constant: 15).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
        

}




