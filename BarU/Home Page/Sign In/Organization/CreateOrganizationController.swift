//
//  CreateOrganizationController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/3/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import JGProgressHUD
import FirebaseStorage


class CreateOrganizationController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, OrgVerificationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // create dataset for schools
    var schools = [School]()
    var schoolCollectionReference: CollectionReference!
    let schoolsTestEnvironment = ["University of Iowa", "University of Illinois", "Northwestern University", "15+ min"]
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create title for this view controller
        navigationItem.title = "Create Org"
        view.backgroundColor = UIColor.matteBlack
        navigationItem.largeTitleDisplayMode = .never
        
        schoolSelectorTextField.inputView = schoolPicker
        schoolPicker.delegate = self
        schoolPicker.dataSource = self
        
        schoolCollectionReference = Firestore.firestore().collection("Schools")
        
        fetchSchoolData()
        
        setupUI()
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
        // check that all fields are filled in
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || establishedTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || reenterPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || schoolSelectorTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" { // this takes away all white spaces and new lines
            return "Please fill in all required fields."
        }
        
        // check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // password isnt secure enough
            return "Please make sure your password contains at least 8 characters and a number."
        }
        if passwordTextField.text != reenterPasswordTextField.text {
            return "Passwords do not match."
        }
        
        // check if email is correct format
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isValidEmail(cleanedEmail) == false {
            return "Invalid email."
        }
        
        return nil
    }
    
    func verificationCode() {
        let orgVerificationController = OrgVerificationController()
        let navController = CustomNavigationController(rootViewController: orgVerificationController)
        // push into new viewcontroller
        // this delegate gives access to this view controller's functions to other view controllers. 
        orgVerificationController.delegate = self
        present(navController, animated: true, completion: nil)
        
        
    }
    
    @objc func handleCreateOrg(sender: UIButton) {
        print("New Orgnization is being created")
        
        // add animation to the button
        Utilities.animateView(sender)
        hud.textLabel.text = "Creating Org"
        hud.show(in: view, animated: true)
        
        // validate the fields
        let error = validateFields()
        
        // ask for code entry to continue to create a new orgnaization


        if error != nil {
            // there is something wrong with the fields, show error message
            self.hud.dismiss(animated: true)
            return showError(title: "Unable to create organization", message: error!)
        } else {
            self.hud.dismiss(animated: true)
            verificationCode()
        }

        
    }
    
    func transitionToHome() {
        let homeController = HomeController()
        navigationController?.pushViewController(homeController, animated: true)
    }
    
    func buildOrg() {
        print("verification completed, building org")
        // create cleaned versions of the data
        let orgName = nameTextField.text! // forced unwrap is ok because it already went through the validation
        let established = establishedTextField.text!
        let slogan = sloganTextField.text
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let school = schoolSelectorTextField.text!
        // to save date in Firebase use Unic Epoch Conversation
        let timestamp = NSDate().timeIntervalSince1970
        
        
        // create the user
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            // check for errors
            if err != nil {
                //  there was an error
                self.hud.dismiss(animated: true)
                self.showError(title: "Unable to create organization", message: "Email already in use.")
            } else {
                
                // org was created successfully, now store the organization name
                let db = Firestore.firestore() // this returns the firestore object where we can call all our methods to add the data to the database
                
                // this data is ONLY for authentication.
                db.collection("Users").document(result!.user.uid).setData(["uid" : result!.user.uid,
                                                                 "org name" : orgName,
                                                                 "password" : password,
                                                                 "email" : email,
                                                                 "school" : school,
                                                                 "isAdmin" : true,
                                                                 "logo url" : "",
                                                                 "established" : established])
                { (error) in
                    if error != nil {
                        self.hud.dismiss(animated: true)
                        // show error message
                        self.showError(title: "Error saving user data", message: "Org name wasn't saved.")
                        
                    }
                }
                
                db.collection("Schools").document(school).collection("Orgs").document(orgName).setData(["uid" : result!.user.uid,
                                                                "org name" : orgName,
                                                                "established" : established,
                                                                "slogan" : slogan ?? "",
                                                                "email" : email,
                                                                "school" : school,
                                                                "logo url" : "",
                                                                "cover" : "",
                                                                "wait time" : "",
                                                                "capacity" : 0,
                                                                "poppin" : "",
                                                                "sunSpecial" : "",
                                                                "monSpecial" : "",
                                                                "tuesSpecial" : "",
                                                                "wedSpecial" : "",
                                                                "thurSpecial" : "",
                                                                "friSpecial" : "",
                                                                "satSpecial" : "",
                                                                "announcement" : "",
                                                                "timestamp" : "\(timestamp)",
                                                                "code": "\(arc4random_uniform(900000) + 100000)"])
                { err in
                    if err != nil {
                        // show error message
                        self.hud.dismiss(animated: true)
                        self.showError(title: "Error saving user data", message: "Org name wasn't saved.")
                    }
                }
                // upload profile pic to storage
                // this gives unique string for each image
                // check if the logo is the same or different than the stock photo, if its the same dont do anything, if its different, save the logo in storage
                if let stockImage = UIImage(named: "pints_icon") {
                    let stockData = stockImage.pngData()
                    let userInputData = self.orgImageView.image?.pngData()
                    if stockData != userInputData {
                        print("org icon is different than stock photo")
                        if let uploadData = self.orgImageView.image!.jpeg(.lowest) {
                            let storageRef = Storage.storage().reference().child("org logos/\(result!.user.uid).png")
                            //print("is not equal")
                            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                                if error != nil {
                                    print(error ?? "")
                                    self.hud.dismiss(animated: true)
                                    return
                                }
                                print(metadata ?? "")
                            
                                storageRef.downloadURL { (url, error) in
                                    guard let url = url, error == nil else {
                                        self.hud.dismiss(animated: true)
                                        self.showError(title: "SEROR", message: error.debugDescription)
                                        return
                                    }
                                    let urlString = url.absoluteString
                                    print("Download URL: \(urlString)")
                                    db.collection("Users").document(result!.user.uid).updateData(["logo url" : urlString])
                                    db.collection("Schools").document(school).collection("Orgs").document(orgName).updateData(["logo url" : urlString])
                                    //db.collection(school).document(orgName).updateData(["logo url" : urlString])
                                }
                            }
                        }
                    }
                }
                
            }
            self.hud.dismiss(animated: true)
            // transition to home screen
            self.transitionToHome()
            
        }
    }
    
    // this function will fetch all school data in database. Do not activate until GUI is finished.
    func fetchSchoolData() {
        schoolCollectionReference.getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            } else {
                guard let snap = snapshot else { return }
                let emptyRow = School(name: "")
                self.schools.append(emptyRow)
                for document in snap.documents {
                    let data = document.data()

                    let name = data["name"] as? String ?? "No school found"
 
                    
                    let newSchool = School(name: name)
                    self.schools.append(newSchool)
                    
                }
            }
            self.schools.sort(by: {$0.name! < $1.name!})
        }
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
        imageView.layer.borderColor = UIColor.beerOrange.cgColor
        imageView.layer.borderWidth = 0.8
        imageView.backgroundColor = .white
        // to make user image interactive so user can choose a photo
        imageView.isUserInteractionEnabled = true
        // similar to button handler, need user to be able to gesture to open up images
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto)))
        return imageView
        
    }()
    @objc private func handleSelectPhoto() {
        print("trying to select photo...")
        
        // pop up for user to choose photo from their campera roll
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        // makes text in search bar white
        imagePickerController.navigationBar.barStyle = .black
        
        
        // allow editing of photo
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    // when user selects photo have a cancel option
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    // get image user selects
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info) // info contains image we are selecting
        // to get image out of info dictionary
        // if the image is edited, then use the edited image, otherwise use the original image
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            orgImageView.image = editedImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // set image if it has not been edited
            orgImageView.image = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            orgImageView.image = selectedImage
        }
        // dismiss entire view image controller
        dismiss(animated: true, completion: nil)
        
    }
    
    // create tap to change photo label
    let tapToChangeLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to change logo"
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .lightGray
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create organization name label
    let orgNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Org Name (this cannot be changed later)"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .beerOrange
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for name entry
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter org name",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create established label
    let establishedLabel: UILabel = {
        let label = UILabel()
        label.text = "Established"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .beerOrange
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for established entry
    let establishedTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter year",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        textField.keyboardType = UIKeyboardType.numberPad
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create slogan label
    let sloganLabel: UILabel = {
        let label = UILabel()
        label.text = "Slogan"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .beerOrange
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // create text field for slogan entry
    let sloganTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter slogan",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create password label
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .beerOrange
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // create text field for password
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter password",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry.toggle()
        return textField
    }()
    // create reenterpassword label
    let reenterPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Re-enter Password"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .beerOrange
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for reentered password
    let reenterPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Re-enter password",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry.toggle()
        return textField
    }()
    // create email label
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .beerOrange
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // create text field for email entry
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter email",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create school selector label
    let schoolSelectorLabel: UILabel = {
        let label = UILabel()
        label.text = "School"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .beerOrange
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create school picker view
    let schoolPicker: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    // create text field for school entry
    let schoolSelectorTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Select affiliate school",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create button for create account
    let createButton: UIButton = {
        let button = UIButton()
        

        button.backgroundColor = UIColor.beerOrange
        button.setTitle("Create Organization", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleCreateOrg(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 105)
    // add scroll to view controller
    lazy var scrollView : UIScrollView = {
        let view = UIScrollView(frame : .zero)
        view.frame = self.view.bounds
        view.contentInsetAdjustmentBehavior = .never
        view.contentSize = contentViewSize
        view.backgroundColor = .matteBlack
        return view
    }()
    
    lazy var containerView : UIView = {
        let view = UIView()
        view.frame.size = contentViewSize
        view.backgroundColor = .matteBlack
        return view
    }()
    
    

    
    // all code to add any layout UI elements
    private func setupUI() {
        self.view.addSubview(scrollView)
        
        self.scrollView.addSubview(containerView)

        //add image picker view
        view.addSubview(orgImageView)
        // gives padding of image from top
        orgImageView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        orgImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        orgImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        orgImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(tapToChangeLabel)
        (tapToChangeLabel).topAnchor.constraint(equalTo: orgImageView.bottomAnchor, constant: 5).isActive = true
        (tapToChangeLabel).centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // add and position name label
        view.addSubview(orgNameLabel)
        orgNameLabel.topAnchor.constraint(equalTo: tapToChangeLabel.bottomAnchor, constant: 20).isActive = true
        orgNameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        orgNameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        orgNameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(nameTextField)
        nameTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        nameTextField.topAnchor.constraint(equalTo: orgNameLabel.bottomAnchor).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // add and position established label
        view.addSubview(establishedLabel)
        establishedLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10).isActive = true
        establishedLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        establishedLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        establishedLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // add and position coc textfield element to the right of the nameLabel
        view.addSubview(establishedTextField)
        establishedTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        establishedTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        establishedTextField.topAnchor.constraint(equalTo: establishedLabel.bottomAnchor).isActive = true
        establishedTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true

        // add and position established label
        view.addSubview(sloganLabel)
        sloganLabel.topAnchor.constraint(equalTo: establishedTextField.bottomAnchor, constant: 10).isActive = true
        sloganLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        sloganLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        sloganLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // add and position coc textfield element to the right of the nameLabel
        view.addSubview(sloganTextField)
        sloganTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        sloganTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        sloganTextField.topAnchor.constraint(equalTo: sloganLabel.bottomAnchor).isActive = true
        sloganTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true

        // add and position coc label
        view.addSubview(passwordLabel)
        passwordLabel.topAnchor.constraint(equalTo: sloganTextField.bottomAnchor, constant: 10).isActive = true
        passwordLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        passwordLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        passwordLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // add and position coc textfield element to the right of the nameLabel
        view.addSubview(passwordTextField)
        passwordTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true


        // add and position invoice label
        view.addSubview(reenterPasswordLabel)
        reenterPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        reenterPasswordLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        reenterPasswordLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        reenterPasswordLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // add and position invoice textfield element to the right of the nameLabel
        view.addSubview(reenterPasswordTextField)
        reenterPasswordTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        reenterPasswordTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        reenterPasswordTextField.topAnchor.constraint(equalTo: reenterPasswordLabel.bottomAnchor).isActive = true
        reenterPasswordTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        // add and position deductible label
        view.addSubview(emailLabel)
        emailLabel.topAnchor.constraint(equalTo: reenterPasswordTextField.bottomAnchor, constant: 10).isActive = true
        emailLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        emailLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(emailTextField)
        emailTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        emailTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        // add and position school label
        view.addSubview(schoolSelectorLabel)
        schoolSelectorLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10).isActive = true
        schoolSelectorLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        schoolSelectorLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        schoolSelectorLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(schoolSelectorTextField)
        schoolSelectorTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        schoolSelectorTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        schoolSelectorTextField.topAnchor.constraint(equalTo: schoolSelectorLabel.bottomAnchor).isActive = true
        schoolSelectorTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(createButton)
        createButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        createButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 64).isActive = true
        createButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -64).isActive = true
        createButton.topAnchor.constraint(equalTo: schoolSelectorTextField.bottomAnchor, constant: 40).isActive = true
        //createButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20.0).isActive = true

    }
    
    
}
