//
//  MyOrgController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/10/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage


class MyOrgController: UIViewController, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate {
    
    //create variable to reference the firebase data so we can read, wirte and update it
    let db = Firestore.firestore()
    
    let waitTimes = ["None", "5 min", "10 min", "15+ min"]
    let coverCharges = ["None", "$5", "$10", "$15", "$20"]
    let poppinStatus = ["No", "Getting there", "Pretty close", "Yes!!"]
    
    var fetchedLogo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add cancel button to dismiss view
        let signOut = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleSignOut))
        // add settings icon button
        let settings = UIBarButtonItem(title: NSString(string: "\u{2699}\u{0000FE0E}") as String, style: .plain, target: self, action: #selector(handleSettings))
        let font = UIFont.systemFont(ofSize: 33) // adjust the size as required
        let attributes = [NSAttributedString.Key.font : font]
        settings.setTitleTextAttributes(attributes, for: .normal)
        
        navigationItem.rightBarButtonItems = [signOut, settings]
        
        // add cancel button to dismiss view
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.title = "My Org"
        navigationItem.largeTitleDisplayMode = .never
        
        waitTimeTextField.inputView = waitTimePicker
        waitTimePicker.delegate = self
        waitTimePicker.dataSource = self
        
        coverTextField.inputView = coverPicker
        coverPicker.delegate = self
        coverPicker.dataSource = self
        
        poppinTextField.inputView = poppinPicker
        poppinPicker.delegate = self
        poppinPicker.dataSource = self
        
        sloganTextField.delegate = self
        textViewDidBeginEditing(sloganTextField)
        textViewDidEndEditing(sloganTextField)
        textViewDidChange(sloganTextField)
        
        sundayTextField.delegate = self
        mondayTextField.delegate = self
        tuesdayTextField.delegate = self
        wednesdayTextField.delegate = self
        thursdayTextField.delegate = self
        fridayTextField.delegate = self
        saturdayTextField.delegate = self
        announcementsTextField.delegate = self
        
        // changes height of textbox based on user input
        textViewDidChange(sundayTextField)
        textViewDidChange(mondayTextField)
        textViewDidChange(tuesdayTextField)
        textViewDidChange(wednesdayTextField)
        textViewDidChange(thursdayTextField)
        textViewDidChange(fridayTextField)
        textViewDidChange(saturdayTextField)
        textViewDidChange(announcementsTextField)
        
        
        
        
        
        view.backgroundColor = UIColor.matteBlack
        setupUI()
        fetchUserData()
        dismissKeyboardGesture()

    }
    
    // check the fields and validate that the data is correct. If everything is correct, this method returns nil, otherwise it returns an error message as a string
    func validateFields() -> String? {
        return nil
    }
    
    // fetch org data frome Firebase
    func fetchUserData() {
        print("fetching data")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).getDocument { (snapshot, error) in
            if let data = snapshot?.data() {
                guard let org = data["org name"] as? String else { return }
                guard let school = data["school"] as? String else { return }
                guard let established = data["established"] as? String else { return }

                // download the org logo image from Firestore
                // user this code below whenever trying to download an image from firebase
                if let logo = data["logo url"] as? String {
                    let url = NSURL(string: logo)
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
                
                self.db.collection("Schools").document(school).collection("Orgs").document(org).getDocument { (snapshot, error) in
                    if let data = snapshot?.data() {
                        guard let slogan = data["slogan"] as? String else { return print("error fetching org slogan")}
                        guard let cover = data["cover"] as? String else { return }
                        guard let waitTime = data["wait time"] as? String else { return }
                        guard let capacity = data["capacity"] as? Int else { return }
                        guard let poppin = data["poppin"] as? String else { return }
                        guard let sunSpecial = data["sunSpecial"] as? String else { return }
                        guard let monSpecial = data["monSpecial"] as? String else { return }
                        guard let tuesSpecial = data["tuesSpecial"] as? String else { return }
                        guard let wedSpecial = data["wedSpecial"] as? String else { return }
                        guard let thursSpecial = data["thurSpecial"] as? String else { return }
                        guard let friSpecial = data["friSpecial"] as? String else { return }
                        guard let satSpecial = data["satSpecial"] as? String else { return }
                        guard let announcement = data["announcement"] as? String else { return }
                        guard let timeStamp = data["timestamp"] as? String else { return print("error fetching org timestamp")}
                        if slogan == "" || slogan == " "{
                            self.sloganTextField.textColor = UIColor.lightGray
                            self.sloganTextField.text = "Tap to create slogan"
                        } else {
                            self.sloganTextField.textColor = .black
                            self.sloganTextField.text = slogan
                            
                        }
                        self.coverTextField.text = cover
                        self.waitTimeTextField.text = waitTime
                        self.poppinTextField.text = poppin
                        if capacity == 1 {
                            self.capacitySwitch.isOn = true
                        } else {
                            self.capacitySwitch.isOn = false
                        }
                        self.sundayTextField.text = sunSpecial
                        self.mondayTextField.text = monSpecial
                        self.tuesdayTextField.text = tuesSpecial
                        self.wednesdayTextField.text = wedSpecial
                        self.thursdayTextField.text = thursSpecial
                        self.fridayTextField.text = friSpecial
                        self.saturdayTextField.text = satSpecial
                        self.announcementsTextField.text = announcement
                        
                        
                        self.timestampLabel.text = Utilities.timestampConversion(timeStamp: timeStamp).timeAgoDisplay()
                        
                
                    }
                }
                self.orgNameLabel.text = org
                self.establishedLabel.text = "Est. \(established)"

                
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if sloganTextField.text.isEmpty {
            sloganTextField.text = "Tap to create slogan"
            sloganTextField.textColor = UIColor.lightGray
        }
    }
    
    
    @objc func handleSignOut() {
        print("org signing out")
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
                print("org signed out")
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
    
    @objc func handleUpdateOrg(sender: UIButton) {
        print("saving org...")
        
        // add animation to the button
        Utilities.animateView(sender)
        // update changes to data in Firebase
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).getDocument { (snapshot, error) in
            if let data = snapshot?.data() {
                guard let school = data["school"] as? String else { return }
                guard let org = data["org name"] as? String else { return }
                
                let storageRef = Storage.storage().reference().child("org logos/\(uid).png")
                
                // save logo image data
                // reduces image to lowest compression to save file size
                if let uploadData = self.orgImageView.image?.jpeg(.lowest) {
                    print("getting image PNG data")
                    print("size of image being uploaded to storage = ", uploadData.count)
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
                            self.db.collection("Users").document(uid).updateData(["logo url" : urlString])
                            self.db.collection("Schools").document(school).collection("Orgs").document(org).updateData(["logo url" : urlString])
                            //self.db.collection(school).document(org).updateData(["logo url" : urlString])
                        }
                    }
                }
                // to save date in Firebase use Unic Epoch Conversation
                let timestamp = NSDate().timeIntervalSince1970
                self.db.collection("Schools").document(school).collection("Orgs").document(org).updateData(
                    ["cover" : self.coverTextField.text ?? "",
                     "wait time" : self.waitTimeTextField.text ?? "",
                     "poppin" : self.poppinTextField.text ?? "",
                     "sunSpecial" : self.sundayTextField.text ?? "",
                     "monSpecial" : self.mondayTextField.text ?? "",
                     "tuesSpecial" : self.tuesdayTextField.text ?? "",
                     "wedSpecial" : self.wednesdayTextField.text ?? "",
                     "thurSpecial" : self.thursdayTextField.text ?? "",
                     "friSpecial" : self.fridayTextField.text ?? "",
                     "satSpecial" : self.saturdayTextField.text ?? "",
                     "announcement" : self.announcementsTextField.text ?? "",
                     "timestamp" : "\(timestamp)"
                ])
                
                if self.sloganTextField.text == "Tap to create slogan" {
                    self.db.collection("Schools").document(school).collection("Orgs").document(org).updateData(["slogan" : ""])
                } else {
                    self.db.collection("Schools").document(school).collection("Orgs").document(org).updateData(["slogan" : self.sloganTextField.text ?? ""])
                }
                
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
    
    @objc func handleMyCrew(sender: UIButton) {
        print("my crew..")
        
        // add animation to the button
        Utilities.animateView(sender)
        
        let myCrewController = MyCrewController()
        navigationController?.pushViewController(myCrewController, animated: true)
        
        
    }
    
    @objc func handleSettings() {
        print("my settings..")
        
        let myOrgSettingsController = MyOrgSettingsController()
        let navController = CustomNavigationController(rootViewController: myOrgSettingsController)
        // push into new viewcontroller
        present(navController, animated: true, completion: nil)
        
        
        
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
            
            orgImageView.image = editedImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // set image if it has not been edited
            orgImageView.image = originalImage
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

    // create org name label
    let orgNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Org name"
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
        label.text = "Est. XXXXX"
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for slogan entry
    let sloganTextField: UITextView = {
        let textField = UITextView()
//        textField.attributedPlaceholder = NSAttributedString(string: "Tap to create slogan",
//                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.font = UIFont.italicSystemFont(ofSize: 16)
        textField.textAlignment = .center
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 7;
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.lightGray
        textField.text = "Tap to create slogan"
        textField.isScrollEnabled = false
        
//        textField.setLeftPaddingPoints(5)
//        textField.setRightPaddingPoints(5)

        
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let editSloganIcon: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "update_GRAY"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // alters the squashed look to make the image appear normal in the view, fixes aspect ratio
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintColor = .lightGray
        return imageView
        
    }()
    
    // create timestamp label
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.text = "last updated label"
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .lightGray
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // my crew button
    let myCrewButton: UIButton = {
        let button = UIButton()
        

        button.backgroundColor = UIColor.logoRed
        button.setTitle("My Crew", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleMyCrew(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    
    // create text field for cover entry
    let waitTimeTextField: UITextField = {
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
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
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
    
    
    
    // create drink specials label
    let drinkSpecialsLabel: UILabel = {
        let label = PaddingLabel(withInsets: 6,6,16,0) // padding up, down, left, right
        let attributedString = NSMutableAttributedString.init(string: "Drink Specials")
        // Add Underline Style Attribute.
//        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
//            NSRange.init(location: 0, length: attributedString.length));
        label.attributedText = attributedString
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = .logoRed
        //label.padding = UIEdgeInsets(top: 20, left: 32, bottom: 60, right: 80)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create sunday specials
    let sundayLabel: UILabel = {
        let label = UILabel()
        label.text = "Sunday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create sunday specials textfield
    let sundayTextField: UITextView = {
        let textField = UITextView()
        //textField.attributedPlaceholder = NSAttributedString(string: "Enter special",
                                     //attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        //textField.addLine(position: .bottom, color: .lightGray, width: 0.5)
        textField.font = .systemFont(ofSize: 16)
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.logoRed.cgColor
        textField.layer.cornerRadius = 7;
        textField.overrideUserInterfaceStyle = .light
        textField.isScrollEnabled = false
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    
    // create monday specials
    let mondayLabel: UILabel = {
        let label = UILabel()
        label.text = "Monday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create monday specials textfield
    let mondayTextField: UITextView = {
        let textField = UITextView()
        //textField.attributedPlaceholder = NSAttributedString(string: "Enter special",
                                     //attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        //textField.addLine(position: .bottom, color: .lightGray, width: 0.5)
        textField.font = .systemFont(ofSize: 16)
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.logoRed.cgColor
        textField.layer.cornerRadius = 7;
        textField.isScrollEnabled = false
        textField.overrideUserInterfaceStyle = .light
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create tueday specials
    let tuesdayLabel: UILabel = {
        let label = UILabel()
        label.text = "Tueday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create tuesday specials textfield
    let tuesdayTextField: UITextView = {
        let textField = UITextView()
//        textField.attributedPlaceholder = NSAttributedString(string: "Enter special",
//                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        //textField.addLine(position: .bottom, color: .lightGray, width: 0.5)
        textField.font = .systemFont(ofSize: 16)
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.logoRed.cgColor
        textField.layer.cornerRadius = 7;
        textField.isScrollEnabled = false
        textField.overrideUserInterfaceStyle = .light
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create wednesday specials
    let wednesdayLabel: UILabel = {
        let label = UILabel()
        label.text = "Wednesday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create wednesday specials text field
    let wednesdayTextField: UITextView = {
        let textField = UITextView()
//        textField.attributedPlaceholder = NSAttributedString(string: "Enter special",
//                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        //textField.addLine(position: .bottom, color: .lightGray, width: 0.5)
        textField.font = .systemFont(ofSize: 16)
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.logoRed.cgColor
        textField.layer.cornerRadius = 7;
        textField.isScrollEnabled = false
        textField.overrideUserInterfaceStyle = .light
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create thursday specials
    let thursdayLabel: UILabel = {
        let label = UILabel()
        label.text = "Thursday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create thursday specials textfield
    let thursdayTextField: UITextView = {
        let textField = UITextView()
//        textField.attributedPlaceholder = NSAttributedString(string: "Enter special",
//                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        //textField.addLine(position: .bottom, color: .lightGray, width: 0.5)
        textField.font = .systemFont(ofSize: 16)
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.logoRed.cgColor
        textField.layer.cornerRadius = 7;
        textField.isScrollEnabled = false
        textField.overrideUserInterfaceStyle = .light
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create friday specials
    let fridayLabel: UILabel = {
        let label = UILabel()
        label.text = "Friday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create friday specials textfield
    let fridayTextField: UITextView = {
        let textField = UITextView()
//        textField.attributedPlaceholder = NSAttributedString(string: "Enter special",
//                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        //textField.addLine(position: .bottom, color: .lightGray, width: 0.5)
        textField.font = .systemFont(ofSize: 16)
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.logoRed.cgColor
        textField.layer.cornerRadius = 7;
        textField.isScrollEnabled = false
        textField.overrideUserInterfaceStyle = .light
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create saturday specials
    let saturdayLabel: UILabel = {
        let label = UILabel()
        label.text = "Saturday"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create saturday specials textfield
    let saturdayTextField: UITextView = {
        let textField = UITextView()
//        textField.attributedPlaceholder = NSAttributedString(string: "Enter special",
//                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        //textField.addLine(position: .bottom, color: .lightGray, width: 0.5)
        textField.font = .systemFont(ofSize: 16)
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.logoRed.cgColor
        textField.layer.cornerRadius = 7;
        textField.isScrollEnabled = false
        textField.overrideUserInterfaceStyle = .light
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    

    // create announcements label
    let announcementsLabel: UILabel = {
        let label = PaddingLabel(withInsets: 6,6,16,0)
        let attributedString = NSMutableAttributedString.init(string: "Announcements")
        // Add Underline Style Attribute.
//        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
//            NSRange.init(location: 0, length: attributedString.length));
        label.attributedText = attributedString
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = .logoRed
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for announcements
    let announcementsTextField: UITextView = {
        let textField = UITextView()
        textField.font = .systemFont(ofSize: 16)
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = UIColor.logoRed.cgColor
        textField.layer.cornerRadius = 7;
        textField.backgroundColor = UIColor.white
        textField.textColor = .black
        textField.isScrollEnabled = false
        
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        //textField.keyboardType = UIKeyboardType.numberPad
        return textField
    }()
    
    // save button for save data
    let saveButton: UIButton = {
        let button = UIButton()
        

        button.backgroundColor = UIColor.logoRed
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleUpdateOrg(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    // add scroll to view controller
    let scrollView : UIScrollView = {
        let view = UIScrollView()
        //view.frame = self.view.bounds
        //view.contentInsetAdjustmentBehavior = .never
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.contentSize = contentViewSize
        view.backgroundColor = .white
        return view
    }()
    
    let containerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.frame.size = contentViewSize
        view.backgroundColor = .white
        return view
    }()
    
    let drinkSpecialsBackgroundView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        //view.layer.cornerRadius = 15
        return view
    }()

    // all code to add any layout UI elements
    private func setupUI() {
        self.view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.scrollView.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        //add image picker view
        view.addSubview(orgImageView)
        // gives padding of image from top
        orgImageView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        orgImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        orgImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        orgImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        // add and position name label
        containerView.addSubview(tapToChangeLabel)
        (tapToChangeLabel).topAnchor.constraint(equalTo: orgImageView.bottomAnchor,constant: 5).isActive = true
        // move label to the right a bit
        (tapToChangeLabel).centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //orgNameLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        //orgNameLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        // add and position name label
        containerView.addSubview(orgNameLabel)
        orgNameLabel.topAnchor.constraint(equalTo: tapToChangeLabel.bottomAnchor, constant: 10).isActive = true
        orgNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // add and position established label
        containerView.addSubview(establishedLabel)
        establishedLabel.topAnchor.constraint(equalTo: orgNameLabel.bottomAnchor).isActive = true
        establishedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // add and position slogan textfield
        view.addSubview(sloganTextField)
        sloganTextField.topAnchor.constraint(equalTo: establishedLabel.bottomAnchor, constant: 8).isActive = true
        sloganTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //sloganTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sloganTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64).isActive = true
        sloganTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64).isActive = true
        
        view.addSubview(editSloganIcon)
        editSloganIcon.heightAnchor.constraint(equalToConstant: 13).isActive = true
        editSloganIcon.centerYAnchor.constraint(equalTo: sloganTextField.centerYAnchor).isActive = true
        editSloganIcon.leftAnchor.constraint(equalTo: sloganTextField.rightAnchor, constant: 4).isActive = true
        editSloganIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(myCrewButton)
        myCrewButton.topAnchor.constraint(equalTo: sloganTextField.bottomAnchor, constant: 10).isActive = true
        myCrewButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        myCrewButton.widthAnchor.constraint(equalToConstant: 310).isActive = true
        myCrewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // add and position name label
        view.addSubview(timestampLabel)
        (timestampLabel).topAnchor.constraint(equalTo: myCrewButton.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        (timestampLabel).centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // add and position cover label
        view.addSubview(coverLabel)
        coverLabel.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 15).isActive = true
        // move label to the right a bit
        coverLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        coverLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
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
        view.addSubview(waitTimeTextField)
        //waitTimeTextField.leftAnchor.constraint(equalTo: waitTimeLabel.rightAnchor).isActive = true
        waitTimeTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        waitTimeTextField.bottomAnchor.constraint(equalTo: waitTimeLabel.bottomAnchor, constant: -4).isActive = true
        waitTimeTextField.topAnchor.constraint(equalTo: waitTimeLabel.topAnchor, constant: 4).isActive = true
        waitTimeTextField.widthAnchor.constraint(equalToConstant: 120).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
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
        
        // add and position deductible label
        view.addSubview(drinkSpecialsLabel)
        drinkSpecialsLabel.topAnchor.constraint(equalTo: atCapacityLabel.bottomAnchor, constant: 15).isActive = true
        // move label to the right a bit
        drinkSpecialsLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        //drinkSpecialsLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        drinkSpecialsLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        containerView.addSubview(drinkSpecialsBackgroundView)
        drinkSpecialsBackgroundView.topAnchor.constraint(equalTo: drinkSpecialsLabel.bottomAnchor).isActive = true
        drinkSpecialsBackgroundView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        //drinkSpecialsLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        drinkSpecialsBackgroundView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        
        // add and position deductible label
        view.addSubview(sundayLabel)
        sundayLabel.topAnchor.constraint(equalTo: drinkSpecialsLabel.bottomAnchor, constant: 10).isActive = true
        // move label to the right a bit
        sundayLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        sundayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        // add poppin switch
        view.addSubview(sundayTextField)
        [sundayTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
         sundayTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
         //mondayTextField.bottomAnchor.constraint(equalTo: mondayLabel.bottomAnchor).isActive = true
         sundayTextField.topAnchor.constraint(equalTo: sundayLabel.bottomAnchor, constant: 8)
        ].forEach{ $0.isActive = true }
        
        // add and position deductible label
        view.addSubview(mondayLabel)
        mondayLabel.topAnchor.constraint(equalTo: sundayTextField.bottomAnchor, constant: 8).isActive = true
        // move label to the right a bit
        mondayLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        mondayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        // add poppin switch
        view.addSubview(mondayTextField)
        mondayTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        mondayTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        //mondayTextField.bottomAnchor.constraint(equalTo: mondayLabel.bottomAnchor).isActive = true
        mondayTextField.topAnchor.constraint(equalTo: mondayLabel.bottomAnchor, constant: 8).isActive = true
        //mondayTextField.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        // add and position deductible label
        view.addSubview(tuesdayLabel)
        tuesdayLabel.topAnchor.constraint(equalTo: mondayTextField.bottomAnchor, constant: 8).isActive = true
        // move label to the right a bit
        tuesdayLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        tuesdayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        // add poppin switch
        view.addSubview(tuesdayTextField)
        tuesdayTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        tuesdayTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        tuesdayTextField.topAnchor.constraint(equalTo: tuesdayLabel.bottomAnchor, constant: 8).isActive = true
        
        // add and position deductible label
        view.addSubview(wednesdayLabel)
        wednesdayLabel.topAnchor.constraint(equalTo: tuesdayTextField.bottomAnchor, constant: 8).isActive = true
        // move label to the right a bit
        wednesdayLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        wednesdayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        // add poppin switch
        view.addSubview(wednesdayTextField)
        wednesdayTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        wednesdayTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        wednesdayTextField.topAnchor.constraint(equalTo: wednesdayLabel.bottomAnchor, constant: 8).isActive = true
        
        // add and position deductible label
        view.addSubview(thursdayLabel)
        thursdayLabel.topAnchor.constraint(equalTo: wednesdayTextField.bottomAnchor, constant: 8).isActive = true
        // move label to the right a bit
        thursdayLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        thursdayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        // add poppin switch
        view.addSubview(thursdayTextField)
        thursdayTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        thursdayTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        thursdayTextField.topAnchor.constraint(equalTo: thursdayLabel.bottomAnchor, constant: 8).isActive = true
        
        // add and position deductible label
        view.addSubview(fridayLabel)
        fridayLabel.topAnchor.constraint(equalTo: thursdayTextField.bottomAnchor, constant: 8).isActive = true
        // move label to the right a bit
        fridayLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        fridayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        // add poppin switch
        view.addSubview(fridayTextField)
        fridayTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        fridayTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        fridayTextField.topAnchor.constraint(equalTo: fridayLabel.bottomAnchor, constant: 8).isActive = true
        
        // add and position deductible label
        view.addSubview(saturdayLabel)
        saturdayLabel.topAnchor.constraint(equalTo: fridayTextField.bottomAnchor, constant: 8).isActive = true
        // move label to the right a bit
        saturdayLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        saturdayLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //nameLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        // add poppin switch
        view.addSubview(saturdayTextField)
        saturdayTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        saturdayTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        saturdayTextField.topAnchor.constraint(equalTo: saturdayLabel.bottomAnchor, constant: 8).isActive = true
        drinkSpecialsBackgroundView.bottomAnchor.constraint(equalTo: saturdayTextField.bottomAnchor, constant: 15).isActive = true
        
        // add and position deductible label
        view.addSubview(announcementsLabel)
        announcementsLabel.topAnchor.constraint(equalTo: saturdayTextField.bottomAnchor, constant: 15).isActive = true
        // move label to the right a bit
        announcementsLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        //announcementsLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        announcementsLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        // add poppin switch
        view.addSubview(announcementsTextField)
        announcementsTextField.topAnchor.constraint(equalTo: announcementsLabel.bottomAnchor, constant: 15).isActive = true
        // move label to the right a bit
        announcementsTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        announcementsTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        //announcementsTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(saveButton)
        announcementsTextField.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20).isActive = true
        //saveButton.topAnchor.constraint(equalTo: announcementsTextField.bottomAnchor, constant: 15).isActive = true
        //saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40).isActive = true

        //containerView.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: -16.0).isActive = true
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
