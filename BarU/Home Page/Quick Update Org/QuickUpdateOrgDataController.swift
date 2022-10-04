//
//  UpdateOrgDataController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/7/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage

class QuickUpdateOrgDataController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    

    var now = Date()
    
    let waitTimes = ["None", "5 min", "10 min", "15+ min"]
    let coverCharges = ["None", "$5", "$10", "$15", "$20"]
    let poppinStatus = ["No", "Getting there", "Pretty close", "Yes!!"]
    
    //create variable to reference the firebase data so we can read, wirte and update it
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add cancel button to dismiss view
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.title = "Quick Update"
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = UIColor.matteBlack
        

        waitTimeTextfield.inputView = waitTimePicker
        waitTimePicker.delegate = self
        waitTimePicker.dataSource = self
        
        coverTextField.inputView = coverPicker
        coverPicker.delegate = self
        coverPicker.dataSource = self
        
        poppinTextField.inputView = poppinPicker
        poppinPicker.delegate = self
        poppinPicker.dataSource = self
        
        setupUI()
        fetchUserData()
    }
    
    // fetch org data frome Firebase
    func fetchUserData() {
        print("fetching data")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).getDocument { (snapshot, error) in
            if let data = snapshot?.data() {
                guard let school = data["school"] as? String else { return print("error quick update school fetch") }
                guard let org = data["org name"] as? String else { return print("error quick update org name fetch") }
                
                self.db.collection("Schools").document(school).collection("Orgs").document(org).getDocument { (snapshot, error) in
                    if let data = snapshot?.data() {
                        guard let established = data["established"] as? String else { return print("error quick update established fetch") }
                        guard let slogan = data["slogan"] as? String else { return print("error quick update slogan fetch")  }
                        guard let cover = data["cover"] as? String else { return print("error quick update cover fetch")  }
                        guard let waitTime = data["wait time"] as? String else { return print("error quick update wait time fetch") }
                        guard let capacity = data["capacity"] as? Int else { return print("error quick update capacity fetch") }
                        guard let poppin = data["poppin"] as? String else { return print("error quick update poppin fetch") }
                    

//                        let getOrgIconURL = UserDefaults.standard.string(forKey: "orgIconURL") ?? ""
//                        print("orgLogo = ", orgLogo)
//                        print("getOrgIconURL = ", getOrgIconURL)
//                        let defaults = UserDefaults.standard
//                        defaults.set(orgLogo, forKey: "orgIconURL")
                        // download the org logo image from Firestore
                       // user this code below whenever trying to download an image from firebase
                       if let orgLogo = data["logo url"] as? String {
                           let url = NSURL(string: orgLogo)
                           URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                               if error != nil {
                                   print(error ?? "")
                                   return
                               }
                               // run image setter on main queue
                               DispatchQueue.main.async {
                                   self.orgImageView.image = UIImage(data: data!)
                               }
                           }).resume()
                       }
                    
                        self.establishedLabel.text = "Est. " + established
                        if slogan == "" {
                            self.sloganLabel.text = " "
                        } else {
                            self.sloganLabel.text = "\"\(slogan)\""
                        }
                        self.coverTextField.text = cover
                        self.waitTimeTextfield.text = waitTime
                        self.poppinTextField.text = poppin
                        if capacity == 1 {
                            self.capacitySwitch.isOn = true
                        } else {
                            self.capacitySwitch.isOn = false
                        }

                    }
                }
                self.orgNameLabel.text = org

                
            }
        }
    }
    
    
    
    
    
    
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    
    // check the fields and validate that the data is correct. If everything is correct, this method returns nil, otherwise it returns an error message as a string
    func validateFields() -> String? {
        return nil
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleUpdateOrg(sender: UIButton) {
        // add animation to the button
        self.animateView(sender)
        print("updating org")
        // update changes to data in Firebase
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).getDocument { (snapshot, error) in
            if let data = snapshot?.data() {
                guard let school = data["school"] as? String else { return }
                guard let org = data["org name"] as? String else { return }
                // to save date in Firebase use Unic Epoch Conversation
                let timestamp = NSDate().timeIntervalSince1970
                self.db.collection("Schools").document(school).collection("Orgs").document(org).updateData(["cover" : self.coverTextField.text ?? "",
                                                                                                            "wait time" : self.waitTimeTextfield.text ?? "",
                                                                                                            "poppin" : self.poppinTextField.text ?? "",
                                                                                                            "timestamp" : "\(timestamp)"
                                                           ])
//                self.db.collection(school).document(org).updateData(["cover" : self.coverTextField.text ?? "",
//                                                                     "wait time" : self.waitTimeTextfield.text ?? "",
//                                                                     "timestamp" : "\(timestamp)"
//                    ])
                
                // capacity and poppin switch handle
                if self.capacitySwitch.isOn == true {
                    self.db.collection("Schools").document(school).collection("Orgs").document(org).updateData(["capacity" : 1])
                } else {
                    self.db.collection("Schools").document(school).collection("Orgs").document(org).updateData(["capacity" : 0])
                }
                
            }
        }
        dismiss(animated: true, completion: nil)
    
        
    }
    

    
    
    
    // create image picker option profile picture
    // lazy var enables self to be something other than nil, so that handleSelectPhoto actually works
    lazy var orgImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "pints_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // alters the squashed look to make the image appear normal in the view, fixes aspect ratio
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderColor = UIColor.matteBlack.cgColor
        imageView.layer.borderWidth = 0.8
        return imageView
        
    }()

    // create org name label
    let orgNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Org Name"
        label.font = UIFont(name: "Rokkitt-SemiBold", size: 30)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create established label
    let establishedLabel: UILabel = {
        let label = UILabel()
        label.text = "Est. XXXX"
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .darkGray
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // create slogan label
    let sloganLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // create cover label
    let coverLabel: UILabel = {
        let label = UILabel()
        label.text = "Cover"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create cover picker view
    let coverPicker: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    // create text field for cover entry
    let coverTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Select",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        textField.tintColor = UIColor.clear
        textField.textAlignment = .center
        textField.backgroundColor = .pickerViewGray
        textField.layer.cornerRadius = 15
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create wait time label
    let waitTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Wait Time"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    
    // create wait time picker view
    let waitTimePicker: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    
    // create text field for wait time entry
    let waitTimeTextfield: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Select",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        textField.tintColor = UIColor.clear
        textField.textAlignment = .center
        textField.backgroundColor = .pickerViewGray
        textField.layer.cornerRadius = 15
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    

    // create is it poppin label
    let poppinLabel: UILabel = {
        let label = UILabel()
        label.text = "Is it Poppin'?"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create poppin picker view
    let poppinPicker: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    // create text field for poppin entry
    let poppinTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Select",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        textField.tintColor = UIColor.clear
        textField.textAlignment = .center
        textField.backgroundColor = .pickerViewGray
        textField.layer.cornerRadius = 15
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create at capacity label
    let atCapacityLabel: UILabel = {
        let label = UILabel()
        label.text = "At Capacity?"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // at capacity Switch
    let capacitySwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.onTintColor = UIColor.logoRed
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        return mySwitch
        
    }()
    
    
    
    // create button for create account
    let createButton: UIButton = {
        let button = UIButton()
        

        button.backgroundColor = UIColor.logoRed
        button.setTitle("Update", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleUpdateOrg(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    
    // all code to add any layout UI elements
    private func setupUI() {
        // add and position background color in relationship to the view elements on the view controller
        let offWhiteBackgroundView = UIView()
        offWhiteBackgroundView.backgroundColor = UIColor.offWhite
        offWhiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(offWhiteBackgroundView)
        offWhiteBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        offWhiteBackgroundView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        offWhiteBackgroundView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        //silverBackgroundView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        
        
        //add image picker view
        view.addSubview(orgImageView)
        // gives padding of image from top
        orgImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        orgImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
//        orgImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100).isActive = true
        orgImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        orgImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        // add and position name label
        view.addSubview(orgNameLabel)
        orgNameLabel.topAnchor.constraint(equalTo: orgImageView.topAnchor).isActive = true
        // move label to the right a bit
        orgNameLabel.leftAnchor.constraint(equalTo: orgImageView.rightAnchor, constant: 32).isActive = true
        
        orgNameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        //orgNameLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true

        
        // add and position last name label
        view.addSubview(establishedLabel)
        establishedLabel.topAnchor.constraint(equalTo: orgNameLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        establishedLabel.leftAnchor.constraint(equalTo: orgImageView.rightAnchor, constant: 40).isActive = true
        establishedLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        
        // add and position coc label
        view.addSubview(sloganLabel)
        sloganLabel.topAnchor.constraint(equalTo: establishedLabel.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        sloganLabel.leftAnchor.constraint(equalTo: orgImageView.rightAnchor, constant: 32).isActive = true
        sloganLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        
        let orgDetailsContainerView = UIView()
        //orgDetailsContainerView.backgroundColor = .green
        orgDetailsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(orgDetailsContainerView)
        orgDetailsContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        orgDetailsContainerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        orgDetailsContainerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        //orgDetailsContainerView.bottomAnchor.constraint(equalTo: sloganLabel.bottomAnchor).isActive = true
        //orgDetailsContainerView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        orgDetailsContainerView.bottomAnchor.constraint(equalTo: sloganLabel.bottomAnchor, constant: 20).isActive = true
        
        // add and position invoice label
        view.addSubview(coverLabel)
        coverLabel.topAnchor.constraint(equalTo: orgDetailsContainerView.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        coverLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        coverLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        coverLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        
        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(coverTextField)
        //coverTextField.leftAnchor.constraint(equalTo: coverLabel.rightAnchor).isActive = true
        coverTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        coverTextField.bottomAnchor.constraint(equalTo: coverLabel.bottomAnchor, constant: -4).isActive = true
        coverTextField.topAnchor.constraint(equalTo: coverLabel.topAnchor, constant: 4).isActive = true
        coverTextField.widthAnchor.constraint(equalToConstant: 120).isActive = true
    
        
        // add and position deductible label
        view.addSubview(waitTimeLabel)
        waitTimeLabel.topAnchor.constraint(equalTo: coverLabel.bottomAnchor, constant: 5).isActive = true
        // move label to the right a bit
        waitTimeLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        waitTimeLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        waitTimeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(waitTimeTextfield)
        //waitTimeTextfield.leftAnchor.constraint(equalTo: waitTimeLabel.rightAnchor).isActive = true
        waitTimeTextfield.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        waitTimeTextfield.bottomAnchor.constraint(equalTo: waitTimeLabel.bottomAnchor, constant: -4).isActive = true
        waitTimeTextfield.topAnchor.constraint(equalTo: waitTimeLabel.topAnchor, constant: 4).isActive = true
        waitTimeTextfield.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        // add and position deductible label
        view.addSubview(poppinLabel)
        poppinLabel.topAnchor.constraint(equalTo: waitTimeLabel.bottomAnchor, constant: 5).isActive = true
        // move label to the right a bit
        poppinLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        poppinLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        poppinLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // add poppin switch
        view.addSubview(poppinTextField)
        //poppinSwitch.leftAnchor.constraint(equalTo: poppinLabel.rightAnchor).isActive = true
        poppinTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        poppinTextField.bottomAnchor.constraint(equalTo: poppinLabel.bottomAnchor, constant: -4).isActive = true
        poppinTextField.topAnchor.constraint(equalTo: poppinLabel.topAnchor, constant: 4).isActive = true
        poppinTextField.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        // add and position school selector label
        view.addSubview(atCapacityLabel)
        atCapacityLabel.topAnchor.constraint(equalTo: poppinLabel.bottomAnchor, constant: 5).isActive = true
        // move label to the right a bit
        atCapacityLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        atCapacityLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        atCapacityLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(capacitySwitch)
        //capacitySwitch.leftAnchor.constraint(equalTo: atCapacityLabel.rightAnchor).isActive = true
        capacitySwitch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        capacitySwitch.bottomAnchor.constraint(equalTo: atCapacityLabel.bottomAnchor).isActive = true
        capacitySwitch.topAnchor.constraint(equalTo: atCapacityLabel.topAnchor, constant: 4).isActive = true
        
        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(createButton)
        createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        createButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        createButton.topAnchor.constraint(equalTo: atCapacityLabel.bottomAnchor, constant: 25).isActive = true
        offWhiteBackgroundView.bottomAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 20).isActive = true
        
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
//        // add and position datepicker element
//        view.addSubview(datePicker)
//        datePicker.topAnchor.constraint(equalTo: deductibleLabel.bottomAnchor).isActive = true
//        datePicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        datePicker.bottomAnchor.constraint(equalTo: lightBlueBackgroundView.bottomAnchor).isActive = true
        
    }
    
    // animation for the buttons
    fileprivate func animateView(_ viewToAnimate: UIView) {
        UIView.animate(withDuration: 0.06, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.9, options: .curveEaseIn, animations: {
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        }) { (_) in
            UIView.animate(withDuration: 0.30, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
    
}
