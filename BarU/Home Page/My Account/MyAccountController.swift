//
//  MyAccountController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/10/21.
//
import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage


class MyAccountController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UIActionSheetDelegate {
    
    //create variable to reference the firebase data so we can read, wirte and update it
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add cancel button to dismiss view
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleSignOut))
        
        navigationItem.title = "My Account"
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = UIColor.darkBlue
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
                guard let firstName = data["first name"] as? String else { return }
                guard let lastName = data["last name"] as? String else { return }
                guard let email = data["email"] as? String else { return }
                guard let school = data["school"] as? String else { return }
                guard let org = data["org name"] as? String else { return }
                // download the user profile picture image from Firestore
                // user this code below whenever trying to download an image from firebase
                if let profilePic = data["profile pic url"] as? String {
                    let url = NSURL(string: profilePic)
                    URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error ?? "")
                            return
                        }
                        // run image setter on main queue
                        DispatchQueue.main.async {
                            self.userImageView.image = UIImage(data: data!)
                        }
                    }).resume()
                }
                
                
                self.firstNameTextField.text = firstName
                self.lastNameTextField.text = lastName
                self.emailTextField.text = email
                self.schoolSelectorMessage.text = school
                self.orgSelectorMessage.text = org

                
            }
        }
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
    
    
    @objc func handleUpdateAccount(sender: UIButton) {
        // add animation to the button
        Utilities.animateView(sender)
        print("saving account...")
        // check the uid is a string
        let email = Auth.auth().currentUser?.email
        let currentUser = Auth.auth().currentUser
        // check that theres actually an email entered in the textfield
        if firstNameTextField.text != nil && lastNameTextField.text != nil && emailTextField.text != nil {
            let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if Utilities.isValidEmail(cleanedEmail) == false {
                return showError(title: "Invalid Email", message: "Double check your email entry.")
            } else {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                db.collection("Users").document(uid).getDocument { (snapshot, error) in
                    if let data = snapshot?.data() {
                        print("user data loaded")
                        guard let school = data["school"] as? String else { return }
                        guard let org = data["org name"] as? String else { return }
                        
                        let storageRef = Storage.storage().reference().child("crew images/\(uid).png")
                        
                        if let uploadData = self.userImageView.image!.jpeg(.lowest) {
                            print("getting image jpeg data at lowest compression")
                            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                                if error != nil {
                                    print(error ?? "")
                                    return
                                }
                                print(metadata ?? "")
                            
                                storageRef.downloadURL { (url, error) in
                                    guard let url = url, error == nil else {
                                        self.showError(title: "SEROR", message: error.debugDescription)
                                        return
                                    }
                                    let urlString = url.absoluteString
                                    print("Download URL: \(urlString)")
                                    self.db.collection("Users").document(uid).updateData(["profile pic url" : urlString])
                                    //self.db.collection(school).document(org).collection("Crew").document(uid).updateData(["profile pic url" : urlString])
                                    self.db.collection("Schools").document(school).collection("Orgs").document(org).collection("Crew").document(uid).updateData(["profile pic url" : urlString])
                                }
                            }
                        }
                    }
                }
                db.collection("Users").document(uid).updateData(["first name" : firstNameTextField.text!,
                                                                 "last name" : lastNameTextField.text!,
                                                                 "email" : emailTextField.text!
                ])
                persistUserDataInOrg()
                if emailTextField.text != email {
                    currentUser?.updateEmail(to: emailTextField.text!, completion: { (err) in
                        if let err = err {
                            print(err)
                        }
                    })
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func persistUserDataInOrg() {
        guard let school = schoolSelectorMessage.text else { return }
        guard let org = orgSelectorMessage.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //db.collection(school).document(org).collection("Crew").document(uid).updateData(["first name" : firstNameTextField.text!,
                                                                                         //"last name" : lastNameTextField.text!,
                                                                                         //"email" : emailTextField.text!])
        db.collection("Schools").document(school).collection("Orgs").document(org).collection("Crew").document(uid).updateData(["first name" : firstNameTextField.text!,
                                                                                                                                "last name" : lastNameTextField.text!,
                                                                                                                                "email" : emailTextField.text!])
        print("user data persisted in org")
    }
    
    // create image picker option profile picture
    // lazy var enables self to be something other than nil, so that handleSelectPhoto actually works
    lazy var userImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "profile_pic_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // alters the squashed look to make the image appear normal in the view, fixes aspect ratio
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderColor = UIColor.matteBlack.cgColor
        imageView.layer.borderWidth = 0.8
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
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            userImageView.image = editedImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // set image if it has not been edited
            userImageView.image = originalImage
        }
        // dismiss entire view image controller
        dismiss(animated: true, completion: nil)
        
    }
    
    // create tap to change photo label
    let tapToChangeLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to change picture"
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .lightGray
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create first name label
    let firstNameLabel: UILabel = {
        let label = UILabel()
        label.text = "First Name"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for first name entry
    let firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Empty",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        textField.text = "First"
        textField.addLine(position: .bottom, color: .lightGray, width: 0.5)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create last name label
    let lastNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Last Name"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for last name entry
    let lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Empty",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        textField.text = "Last"
        textField.addLine(position: .bottom, color: .lightGray, width: 0.5)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
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
        label.text = "School Name"
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
        label.text = "Organization Name"
        label.textColor = .darkGray
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // save button for save data
    let saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.logoRed
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleUpdateAccount(sender:)), for: .touchUpInside)
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
        silverBackgroundView.heightAnchor.constraint(equalToConstant: 460).isActive = true
        
        view.addSubview(userImageView)
        userImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        userImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(tapToChangeLabel)
        (tapToChangeLabel).topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 5).isActive = true
        (tapToChangeLabel).centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // add and position name label
        view.addSubview(firstNameLabel)
        firstNameLabel.topAnchor.constraint(equalTo: tapToChangeLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        firstNameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        firstNameLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        firstNameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(firstNameTextField)
        firstNameTextField.leftAnchor.constraint(equalTo: firstNameLabel.rightAnchor).isActive = true
        firstNameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        firstNameTextField.bottomAnchor.constraint(equalTo: firstNameLabel.bottomAnchor).isActive = true
        firstNameTextField.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        firstNameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        firstNameTextField.topAnchor.constraint(equalTo: firstNameLabel.topAnchor).isActive = true
        
        // add and position name label
        view.addSubview(lastNameLabel)
        lastNameLabel.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        lastNameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        lastNameLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        lastNameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(lastNameTextField)
        lastNameTextField.leftAnchor.constraint(equalTo: lastNameLabel.rightAnchor).isActive = true
        lastNameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        lastNameTextField.bottomAnchor.constraint(equalTo: lastNameLabel.bottomAnchor).isActive = true
        lastNameTextField.topAnchor.constraint(equalTo: lastNameLabel.topAnchor).isActive = true
        
        // add and position name label
        view.addSubview(emailLabel)
        emailLabel.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        emailLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        emailLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
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
        
        schoolSelectorLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
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
        
        orgSelectorLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        orgSelectorLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(orgSelectorMessage)
        orgSelectorMessage.leftAnchor.constraint(equalTo: orgSelectorLabel.rightAnchor).isActive = true
        orgSelectorMessage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        orgSelectorMessage.bottomAnchor.constraint(equalTo: orgSelectorLabel.bottomAnchor).isActive = true
        orgSelectorMessage.topAnchor.constraint(equalTo: orgSelectorLabel.topAnchor).isActive = true
        
        view.addSubview(saveButton)
        saveButton.topAnchor.constraint(equalTo: orgSelectorMessage.bottomAnchor, constant: 15).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
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
