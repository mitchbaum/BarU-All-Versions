//
//  settingsController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/14/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import JGProgressHUD


class MyOrgSettingsController: UIViewController {
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    //create variable to reference the firebase data so we can read, wirte and update it
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.title = "Settings"
        
        view.backgroundColor = UIColor.matteBlack
        navigationItem.largeTitleDisplayMode = .never
        
        // add cancel button to dismiss view
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        setupUI()
        fetchUserData()
        dismissKeyboardGesture()
    }
    
    // fetch crew member data frome Firebase
    func fetchUserData() {
        print("fetching data")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).getDocument { (snapshot, error) in
            if let data = snapshot?.data() {
                guard let org = data["org name"] as? String else { return }
                guard let email = data["email"] as? String else { return }
                guard let school = data["school"] as? String else { return }
                
                self.emailTextField.text = email
                self.schoolSelectorMessage.text = school
                self.orgSelectorMessage.text = org
                
                self.db.collection("Schools").document(school).collection("Orgs").document(org).getDocument { (snapshot, error) in
                    if let data = snapshot?.data() {
                        guard let code = data["code"] as? String else { return print("could not fetch org code")}
                        self.crewCodeTextField.text = code
                    }
                }

                
            }
        }
    }
    
    @objc func handleUpdateOrgSettings(sender: UIButton) {
        // add animation to the button
        Utilities.animateView(sender)
        hud.textLabel.text = "Saving..."
        hud.show(in: view, animated: true)
        print("trying to save  org settings...")
        
        let email = Auth.auth().currentUser?.email
        let currentUser = Auth.auth().currentUser
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // check that theres actually an email entered in the textfield
        if emailTextField.text != nil {
            let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if Utilities.isValidEmail(cleanedEmail) == false {
                self.hud.dismiss(animated: true)
                return showError(title: "Invalid Email", message: "Double check your email entry.")
            } else {
                if emailTextField.text != email {
                    db.collection("Users").document(uid).updateData(["email" : emailTextField.text!])
                    let school = schoolSelectorMessage.text!
                    let org = orgSelectorMessage.text!
                    db.collection("Schools").document(school).collection("Orgs").document(org).updateData(["email" : emailTextField.text!])
                    currentUser?.updateEmail(to: emailTextField.text!, completion: { (err) in
                        if let err = err {
                            print(err)
                        }
                    })
                }
            }
        }
        // handle editing the crew member code
        if crewCodeTextField.text != nil {
            if crewCodeTextField.text?.count == 6 {
                db.collection("Schools").document(schoolSelectorMessage.text!).collection("Orgs").document(orgSelectorMessage.text!).updateData(["code" : crewCodeTextField.text!])
            } else if crewCodeTextField.text!.count < 6 || crewCodeTextField.text!.count > 6 {
                self.hud.dismiss(animated: true)
                return showError(title: "Invalid Code", message: "Code length must be 6 digits.")
            }
            
        }
        self.hud.dismiss(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    func transitionToMyOrg() {
        let myOrgController = MyOrgController()
        navigationController?.pushViewController(myOrgController, animated: true)
    }
    
    // create email label
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // create text field for email entry
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Empty",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        textField.text = "email@email.com"
        textField.addLine(position: .bottom, color: .lightGray, width: 0.5)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let editIcon: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "update_GRAY"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // alters the squashed look to make the image appear normal in the view, fixes aspect ratio
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintColor = .lightGray
        return imageView
        
    }()
    
    // create school selector label
    let schoolSelectorLabel: UILabel = {
        let label = UILabel()
        label.text = "School"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create label for school
    let schoolSelectorMessage: UILabel = {
        let label = UILabel()
        //label.font = UIFont.italicSystemFont(ofSize: 18)
        label.textColor = .darkGray
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create organization selector label
    let orgSelectorLabel: UILabel = {
        let label = UILabel()
        label.text = "Organization"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for name entry
    let orgSelectorMessage: UILabel = {
        let label = UILabel()
        label.text = "Org"
        //label.font = UIFont.italicSystemFont(ofSize: 18)
        label.textColor = .darkGray
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create code label
    let crewCodeSelectorLabel: UILabel = {
        let label = UILabel()
        label.text = "New Crew Member Verification Code"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for code entry
    let crewCodeTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Tap to create a code",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        textField.text = "XXXXXX"
        textField.font = .boldSystemFont(ofSize: 20)
        textField.keyboardType = UIKeyboardType.numberPad
        
        textField.textAlignment = .center
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 7;
        textField.backgroundColor = UIColor.white
        
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // save button for save data
    let saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.logoRed
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleUpdateOrgSettings(sender:)), for: .touchUpInside)
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
        //silverBackgroundView.heightAnchor.constraint(equalToConstant: 330).isActive = true
        
        
        // add and position name label
        view.addSubview(emailLabel)
        emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        // move label to the right a bit
        emailLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        emailLabel.widthAnchor.constraint(equalToConstant: 135).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(emailTextField)
        emailTextField.leftAnchor.constraint(equalTo: emailLabel.rightAnchor).isActive = true
        emailTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        emailTextField.bottomAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: emailLabel.topAnchor).isActive = true
        
        // add and position name label
        view.addSubview(schoolSelectorLabel)
        schoolSelectorLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        schoolSelectorLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        schoolSelectorLabel.widthAnchor.constraint(equalToConstant: 135).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        schoolSelectorLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(schoolSelectorMessage)
        schoolSelectorMessage.leftAnchor.constraint(equalTo: schoolSelectorLabel.rightAnchor).isActive = true
        schoolSelectorMessage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        schoolSelectorMessage.bottomAnchor.constraint(equalTo: schoolSelectorLabel.bottomAnchor).isActive = true
        schoolSelectorMessage.topAnchor.constraint(equalTo: schoolSelectorLabel.topAnchor).isActive = true
        
        // add and position name label
        view.addSubview(orgSelectorLabel)
        orgSelectorLabel.topAnchor.constraint(equalTo: schoolSelectorLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        orgSelectorLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        orgSelectorLabel.widthAnchor.constraint(equalToConstant: 135).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        orgSelectorLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(orgSelectorMessage)
        orgSelectorMessage.leftAnchor.constraint(equalTo: orgSelectorLabel.rightAnchor).isActive = true
        orgSelectorMessage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        orgSelectorMessage.bottomAnchor.constraint(equalTo: orgSelectorLabel.bottomAnchor).isActive = true
        orgSelectorMessage.topAnchor.constraint(equalTo: orgSelectorLabel.topAnchor).isActive = true
        
        // add and position name label
        view.addSubview(crewCodeSelectorLabel)
        crewCodeSelectorLabel.topAnchor.constraint(equalTo: orgSelectorLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        crewCodeSelectorLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        crewCodeSelectorLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        crewCodeSelectorLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(crewCodeTextField)
        crewCodeTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        //crewCodeTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        crewCodeTextField.widthAnchor.constraint(equalToConstant: 150).isActive = true
        crewCodeTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        crewCodeTextField.topAnchor.constraint(equalTo: crewCodeSelectorLabel.bottomAnchor).isActive = true
        
        view.addSubview(editIcon)
        // gives padding of image from top
        editIcon.topAnchor.constraint(equalTo: crewCodeTextField.topAnchor, constant: 12.5).isActive = true
        //editSloganIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        editIcon.heightAnchor.constraint(equalToConstant: 15).isActive = true
        editIcon.leftAnchor.constraint(equalTo: crewCodeTextField.rightAnchor, constant: 6).isActive = true
        //editSloganIcon.bottomAnchor.constraint(equalTo: sloganTextField.bottomAnchor).isActive = true
        editIcon.widthAnchor.constraint(equalToConstant: 15).isActive = true
        
        view.addSubview(saveButton)
        saveButton.topAnchor.constraint(equalTo: crewCodeTextField.bottomAnchor, constant: 35).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        silverBackgroundView.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20).isActive = true
        
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
    
    private func dismissKeyboardGesture() {
        // dismiss keyboard when user taps outside of keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        let swipeDown = UIPanGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeDown)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
        

}
