//
//  FetchCode.swift
//  BarU
//
//  Created by Mitch Baumgartner on 9/27/21.
//
import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import JGProgressHUD


class MyOrgCodeController: UIViewController {
    
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
        
        
        navigationItem.title = "Org Code"
        
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
        db.collection("Codes").document("Organizations").getDocument { (snapshot, error) in
            if let data = snapshot?.data() {
                guard let code = data["code"] as? String else { return }
                self.orgCodeTextField.text = code
            }
        }
    }
    
    @objc func handleUpdateOrgSettings(sender: UIButton) {
        // add animation to the button
        Utilities.animateView(sender)
        hud.textLabel.text = "Saving..."
        hud.show(in: view, animated: true)
        print("trying to save new org code...")

        // handle editing the crew member code
        if orgCodeTextField.text != nil {
            if orgCodeTextField.text?.count == 6 {
                db.collection("Codes").document("Organizations").updateData(["code" : orgCodeTextField.text!])
            } else if orgCodeTextField.text!.count < 6 || orgCodeTextField.text!.count > 6 {
                self.hud.dismiss(animated: true)
                return showError(title: "Invalid Code", message: "Code length must be 6 digits.")
            }
            
        }
        self.hud.dismiss(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    func transitionToMyOrg() {
        let homeController = HomeController()
        navigationController?.pushViewController(homeController, animated: true)
    }
    

    
    
    // create code label
    let orgCodeSelectorLabel: UILabel = {
        let label = UILabel()
        label.text = "Organization Onboarding Code"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for code entry
    let orgCodeTextField: UITextField = {
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
    
    let editIcon: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "update_GRAY"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // alters the squashed look to make the image appear normal in the view, fixes aspect ratio
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintColor = .lightGray
        return imageView
        
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
        view.addSubview(orgCodeSelectorLabel)
        orgCodeSelectorLabel.topAnchor.constraint(equalTo: silverBackgroundView.topAnchor).isActive = true
        // move label to the right a bit
        orgCodeSelectorLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        orgCodeSelectorLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        orgCodeSelectorLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(orgCodeTextField)
        orgCodeTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        //crewCodeTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        orgCodeTextField.widthAnchor.constraint(equalToConstant: 150).isActive = true
        orgCodeTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        orgCodeTextField.topAnchor.constraint(equalTo: orgCodeSelectorLabel.bottomAnchor).isActive = true
        
        view.addSubview(editIcon)
        // gives padding of image from top
        editIcon.topAnchor.constraint(equalTo: orgCodeTextField.topAnchor, constant: 12.5).isActive = true
        //editSloganIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        editIcon.heightAnchor.constraint(equalToConstant: 15).isActive = true
        editIcon.leftAnchor.constraint(equalTo: orgCodeTextField.rightAnchor, constant: 6).isActive = true
        //editSloganIcon.bottomAnchor.constraint(equalTo: sloganTextField.bottomAnchor).isActive = true
        editIcon.widthAnchor.constraint(equalToConstant: 15).isActive = true
        
        view.addSubview(saveButton)
        saveButton.topAnchor.constraint(equalTo: orgCodeTextField.bottomAnchor, constant: 35).isActive = true
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
