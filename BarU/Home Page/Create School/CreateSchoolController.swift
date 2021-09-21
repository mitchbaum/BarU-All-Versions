//
//  AddSchoolController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/20/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import JGProgressHUD


class CreateSchoolController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // create title for this view controller
        navigationItem.title = "Add School"
        view.backgroundColor = UIColor.darkBlue
        
        // add cancel button to dismiss view
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        setupUI()
    }
    
    // check the fields and validate that the data is correct. If everything is correct, this method returns nil, otherwise it returns an error message as a string
    func validateFields() -> String? {
        // check that all fields are filled in
        if schoolTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || confirmSchoolTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || stateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""  { // this takes away all white spaces and new lines
            return "Please fill in all required fields."
        }
        
        // check if the state is two letters
        let cleanedState = stateTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedState.count > 2 {
            // state isnt abbreviated
            return "Please make sure the state is abbreviated in correct format."
        }
        
        return nil
    }
    
    @objc func handleCreateSchool(sender: UIButton) {
        print("New school is being created")
        
        // add animation to the button
        Utilities.animateView(sender)
        hud.textLabel.text = "Creating School"
        hud.show(in: view, animated: true)
        
        // validate the fields
        let error = validateFields()
        if error != nil {
            // there is something wrong with the fields, show error message
            self.hud.dismiss(animated: true)
            return showError(title: "Unable to create school", message: error!)
        } else {
            
            // school was created successfully, now store the organization name
            let db = Firestore.firestore()
            
            // create cleaned versions of the data
            let school = schoolTextField.text! // forced unwrap is ok because it already went through the validation
            let city = cityTextField.text!
            let state = stateTextField.text!
            
            db.collection("Schools").document(school).setData(["name" : school,
                                                               "logo url" : "",
                                                               "city": city,
                                                               "state" : state])
            { (error) in
                if error != nil {
                    self.hud.dismiss(animated: true)
                    // show error message
                    self.showError(title: "Error saving school data", message: "School name wasn't saved.")
                    
                }
            }
            // upload logo pic to storage
            // this gives unique string for each image
        
            let storageRef = Storage.storage().reference().child("school logos/\(school).png")
            
            if let uploadData = self.logoImageView.image!.jpeg(.lowest) {
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
                            self.showError(title: "Download \(school) logo error", message: error.debugDescription)
                            return
                        }
                        let urlString = url.absoluteString
                        print("Download URL: \(urlString)")
                        db.collection("Schools").document(school).updateData(["logo url" : urlString])
                    }
                }
            }
        
        }
        self.hud.dismiss(animated: true)
        // transition to home screen
        self.transitionToHome()
    }
    
    func transitionToHome() {
        let homeController = HomeController()
        navigationController?.pushViewController(homeController, animated: true)
    }

    // create image picker option school logo
    // lazy var enables self to be something other than nil, so that handleSelectPhoto actually works
    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "pints_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // alters the squashed look to make the image appear normal in the view, fixes aspect ratio
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.width / 3
        
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
            
            logoImageView.image = editedImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // set image if it has not been edited
            logoImageView.image = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            logoImageView.image = selectedImage
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
    
    // create school name label
    let schoolLabel: UILabel = {
        let label = UILabel()
        label.text = "School"
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for name entry
    let schoolTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter school name",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create confirm school name label
    let confirmSchoolLabel: UILabel = {
        let label = UILabel()
        label.text = "Re-enter School"
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create confrim text field for name entry
    let confirmSchoolTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Re-enter school name",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create school city label
    let cityLabel: UILabel = {
        let label = UILabel()
        label.text = "City"
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for school city entry
    let cityTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter city name",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create school state label
    let stateLabel: UILabel = {
        let label = UILabel()
        label.text = "State (Format: XX)"
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for school state entry
    let stateTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter state name",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    // create button for create account
    let createButton: UIButton = {
        let button = UIButton()
        

        button.backgroundColor = UIColor.systemBlue
        button.setTitle("Create School", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleCreateSchool(sender:)), for: .touchUpInside)
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
        silverBackgroundView.heightAnchor.constraint(equalToConstant: 550).isActive = true
        
        //add image picker view
        view.addSubview(logoImageView)
        // gives padding of image from top
        logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(tapToChangeLabel)
        (tapToChangeLabel).topAnchor.constraint(equalTo: logoImageView.bottomAnchor).isActive = true
        (tapToChangeLabel).centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // add and position name label
        view.addSubview(schoolLabel)
        schoolLabel.topAnchor.constraint(equalTo: tapToChangeLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        schoolLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        schoolLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        schoolLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(schoolTextField)
        schoolTextField.leftAnchor.constraint(equalTo: schoolLabel.rightAnchor).isActive = true
        schoolTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        schoolTextField.bottomAnchor.constraint(equalTo: schoolLabel.bottomAnchor).isActive = true
        schoolTextField.topAnchor.constraint(equalTo: schoolLabel.topAnchor).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // add and position name label
        view.addSubview(confirmSchoolLabel)
        confirmSchoolLabel.topAnchor.constraint(equalTo: schoolLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        confirmSchoolLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        confirmSchoolLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        confirmSchoolLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(confirmSchoolTextField)
        confirmSchoolTextField.leftAnchor.constraint(equalTo: confirmSchoolLabel.rightAnchor).isActive = true
        confirmSchoolTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        confirmSchoolTextField.bottomAnchor.constraint(equalTo: confirmSchoolLabel.bottomAnchor).isActive = true
        confirmSchoolTextField.topAnchor.constraint(equalTo: confirmSchoolLabel.topAnchor).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // add and position name label
        view.addSubview(cityLabel)
        cityLabel.topAnchor.constraint(equalTo: confirmSchoolLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        cityLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        cityLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        cityLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(cityTextField)
        cityTextField.leftAnchor.constraint(equalTo: cityLabel.rightAnchor).isActive = true
        cityTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        cityTextField.bottomAnchor.constraint(equalTo: cityLabel.bottomAnchor).isActive = true
        cityTextField.topAnchor.constraint(equalTo: cityLabel.topAnchor).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // add and position name label
        view.addSubview(stateLabel)
        stateLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor).isActive = true
        // move label to the right a bit
        stateLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        stateLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        stateLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(stateTextField)
        stateTextField.leftAnchor.constraint(equalTo: stateLabel.rightAnchor).isActive = true
        stateTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        stateTextField.bottomAnchor.constraint(equalTo: stateLabel.bottomAnchor).isActive = true
        stateTextField.topAnchor.constraint(equalTo: stateLabel.topAnchor).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        
        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(createButton)
        createButton.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 20).isActive = true
        createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        createButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
    
    }
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
}

    
