//
//  CrewVerificationController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/27/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import JGProgressHUD

// custom delegation
// this protocol allows this view controller to access the functions of CreateOrganizationController so long as the functions are specified below
protocol CrewVerificationControllerDelegate {
    func buildCrewMember()
}

class CrewVerificationController: UIViewController {
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    var delegate: CrewVerificationControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.title = "Verification Code"
        
        view.backgroundColor = UIColor.matteBlack
        navigationItem.largeTitleDisplayMode = .never
        
        // add cancel button to dismiss view
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        
        // set delegates for all the textfields
        self.oneTextField.delegate = self
        self.twoTextField.delegate = self
        self.threeTextField.delegate = self
        self.fourTextField.delegate = self
        self.fiveTextField.delegate = self
        self.sixTextField.delegate = self
        
        self.oneTextField.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        self.twoTextField.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        self.threeTextField.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        self.fourTextField.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        self.fiveTextField.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        self.sixTextField.addTarget(self, action: #selector(self.changeCharacter), for: .editingChanged)
        setupUI()
    }
    
    @objc func changeCharacter(textField : UITextField) {
        if textField.text?.utf8.count == 1 {
            switch textField {
            case oneTextField:
                twoTextField.becomeFirstResponder()
            case twoTextField:
                threeTextField.becomeFirstResponder()
            case threeTextField:
                fourTextField.becomeFirstResponder()
            case fourTextField:
                fiveTextField.becomeFirstResponder()
            case fiveTextField:
                sixTextField.becomeFirstResponder()
            default:
                break
            }
        } else if textField.text!.isEmpty {
            switch textField {
            case sixTextField:
                fiveTextField.becomeFirstResponder()
            case fiveTextField:
                fourTextField.becomeFirstResponder()
            case fourTextField:
                threeTextField.becomeFirstResponder()
            case threeTextField:
                twoTextField.becomeFirstResponder()
            case twoTextField:
                oneTextField.becomeFirstResponder()
            default:
                break
            }
        }
    }
    
    // when user taps "validate" button
    @objc func handleValidate(sender: UIButton) {
        print("New crew member is being created")
        
        // add animation to the button
        Utilities.animateView(sender)
        hud.textLabel.text = "Verifying..."
        hud.show(in: view, animated: true)
        
        let code = "\(oneTextField.text!)\(twoTextField.text!)\(threeTextField.text!)\(fourTextField.text!)\(fiveTextField.text!)\(sixTextField.text!)"
        if code.count < 6 {
            self.hud.dismiss(animated: true)
            return showError(title: "Error", message: "Please enter a 6 digit code.")
        } else {
            let db = Firestore.firestore()
            let school = UserDefaults.standard.string(forKey: "school")
            let org = UserDefaults.standard.string(forKey: "org")
            db.collection("Schools").document(school!).collection("Orgs").document(org!).getDocument { (snapshot, error) in
                if let data = snapshot?.data() {
                    guard let verifCode = data["code"] as? String else { return }
                    
                    if code == verifCode {
                        self.hud.dismiss(animated: true)
                        self.dismiss(animated: true) {
                            //CreateOrganizationController.printHello
                            
                            self.delegate?.buildCrewMember()
                            
                            
                        }
                    } else {
                        self.hud.dismiss(animated: true)
                        return self.showError(title: "Error", message: "Invalid verfication code.")
                    }

                    
                }
            }
        }
    }
    
    // image for lock icon
    // lazy var enables self to be something other than nil, so that handleSelectPhoto actually works
    lazy var lockImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "lock"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // alters the squashed look to make the image appear normal in the view, fixes aspect ratio
        imageView.contentMode = .scaleAspectFit
        //imageView.layer.cornerRadius = imageView.frame.width / 3
        return imageView
        
    }()
    
    // create instructions label
    let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = "My organization's 6 digit verification code is"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = .white
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for first code number entry
    let oneTextField: UITextField = {
        let textField = UITextField()
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        textField.attributedPlaceholder = NSAttributedString(string: "0",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                                          .paragraphStyle: centeredParagraphStyle])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        textField.textAlignment = .center
        textField.tintColor = UIColor.clear
        textField.keyboardType = UIKeyboardType.decimalPad
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    // create text field for second code number entry
    let twoTextField: UITextField = {
        let textField = UITextField()
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        textField.attributedPlaceholder = NSAttributedString(string: "0",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                                          .paragraphStyle: centeredParagraphStyle])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        textField.textAlignment = .center
        textField.tintColor = UIColor.clear
        textField.keyboardType = UIKeyboardType.decimalPad
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create text field for third code number entry
    let threeTextField: UITextField = {
        let textField = UITextField()
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        textField.attributedPlaceholder = NSAttributedString(string: "0",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                                          .paragraphStyle: centeredParagraphStyle])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        textField.textAlignment = .center
        textField.tintColor = UIColor.clear
        textField.keyboardType = UIKeyboardType.decimalPad
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create text field for fourth code number entry
    let fourTextField: UITextField = {
        let textField = UITextField()
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        textField.attributedPlaceholder = NSAttributedString(string: "0",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                                          .paragraphStyle: centeredParagraphStyle])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        textField.textAlignment = .center
        textField.tintColor = UIColor.clear
        textField.keyboardType = UIKeyboardType.decimalPad
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create text field for fifth code number entry
    let fiveTextField: UITextField = {
        let textField = UITextField()
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        textField.attributedPlaceholder = NSAttributedString(string: "0",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                                          .paragraphStyle: centeredParagraphStyle])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        textField.textAlignment = .center
        textField.tintColor = UIColor.clear
        textField.keyboardType = UIKeyboardType.decimalPad
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create text field for sixth code number entry
    let sixTextField: UITextField = {
        let textField = UITextField()
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        textField.attributedPlaceholder = NSAttributedString(string: "0",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                                          .paragraphStyle: centeredParagraphStyle])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        textField.textAlignment = .center
        textField.tintColor = UIColor.clear
        textField.keyboardType = UIKeyboardType.decimalPad
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create button for validation account
    let validateButton: UIButton = {
        let button = UIButton()
        

        button.backgroundColor = UIColor.beerOrange
        button.setTitle("Validate", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleValidate(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    // all code to add any layout UI elements
    private func setupUI() {
        //add image picker view
        view.addSubview(lockImageView)
        // gives padding of image from top
        lockImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        lockImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        lockImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lockImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        // add and position name label
        view.addSubview(instructionsLabel)
        instructionsLabel.topAnchor.constraint(equalTo: lockImageView.bottomAnchor, constant: 20).isActive = true
        // move label to the right a bit
        instructionsLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        instructionsLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        //instructionsLabel.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(oneTextField)
        oneTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100).isActive = true
        oneTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        oneTextField.widthAnchor.constraint(equalToConstant: 25).isActive = true
        oneTextField.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 40).isActive = true
        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(twoTextField)
        twoTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60).isActive = true
        twoTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        twoTextField.widthAnchor.constraint(equalToConstant: 25).isActive = true
        twoTextField.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 40).isActive = true
        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(threeTextField)
        threeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -20).isActive = true
        threeTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        threeTextField.widthAnchor.constraint(equalToConstant: 25).isActive = true
        threeTextField.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 40).isActive = true
        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(fourTextField)
        fourTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 20).isActive = true
        fourTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        fourTextField.widthAnchor.constraint(equalToConstant: 25).isActive = true
        fourTextField.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 40).isActive = true
        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(fiveTextField)
        fiveTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60).isActive = true
        fiveTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        fiveTextField.widthAnchor.constraint(equalToConstant: 25).isActive = true
        fiveTextField.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 40).isActive = true
        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(sixTextField)
        sixTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100).isActive = true
        sixTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sixTextField.widthAnchor.constraint(equalToConstant: 25).isActive = true
        sixTextField.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 40).isActive = true
        
        view.addSubview(validateButton)
        validateButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        validateButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 64).isActive = true
        validateButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -64).isActive = true
        validateButton.topAnchor.constraint(equalTo: sixTextField.bottomAnchor, constant: 60).isActive = true
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
    
        

}

extension CrewVerificationController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.utf16.count == 1 && !string.isEmpty {
            return false
        } else {
            return true
        }
    }
}


