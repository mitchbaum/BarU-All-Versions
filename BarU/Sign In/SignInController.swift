//
//  OrganizationSignInController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/2/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD


class SignInController: UIViewController {
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create title for this view controller
        navigationItem.title = "Sign In"
        
        
        
        view.backgroundColor = UIColor.matteBlack
        
        setupUI()
        dismissKeyboardGesture() 
    }
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    

    
    @objc func handleSignIn(sender: UIButton) {
        print("User logging in")
        
        // add animation to the button this is taken from the Utilities.swift file in Helpers folder
        Utilities.animateView(sender)
        // style hud
        hud.textLabel.text = "Signing In"
        hud.show(in: view, animated: true)
        // validate the textfields
        let error = validatefields()
        if error != nil {
            // dismiss loading hud if there's an error
            self.hud.dismiss(animated: true)
            return showError(title: "Invalid Entry", message: error!)
        }
        // create cleaned versions of textfields
        let email = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        // signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                // dismiss loading hud if there's an error
                self.hud.dismiss(animated: true)
                // couldnt sign in
                self.showError(title: "Unable to sign in", message: error!.localizedDescription)
            } else {
                // dismiss loading hud if there's no error
                self.hud.dismiss(animated: true)
                self.transitionToHome()
            }
        }
        
        
        
    }
    
    func transitionToHome() {
        let homeController = HomeController()
        navigationController?.pushViewController(homeController, animated: true)
    }
    
    func validatefields() -> String? {
        // validate the textfields
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        return nil
    }
    
    
    @objc func handleCreateUser(sender: UIButton) {
        print("Creating new user")
        
        // add animation to the button
        Utilities.animateView(sender)
        

        let createCrewMemberController = CreateCrewMemberController()
        // push into new viewcontroller
        navigationController?.pushViewController(createCrewMemberController, animated: true)


        
    }
    
    @objc func handleCreateOrg(sender: UIButton) {
        print("Creating new organization")
        
        // add animation to the button
        Utilities.animateView(sender)
        
        let createOrganizationController = CreateOrganizationController()
        // push into new viewcontroller
        navigationController?.pushViewController(createOrganizationController, animated: true)
        
//        let orgVerificationController = OrgVerificationController()
//        let navController = CustomNavigationController(rootViewController: orgVerificationController)
        // push into new viewcontroller
        // this delegate gives access to this view controller's functions to other view controllers.
        //orgVerificationController.delegate = self
        //present(navController, animated: true, completion: nil)
    }
    
    @objc func handleForgotPassword(sender: UIButton) {
        print("Forgot password button pressed")
        
        // add animation to the button
        Utilities.animateView(sender)
        
        let forgotPasswordController = ForgotPasswordController()
        let navController = CustomNavigationController(rootViewController: forgotPasswordController)
        // push into new viewcontroller
        present(navController, animated: true, completion: nil)
    }
    
    @objc func handleSegmentChange() {
        switch userTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            setUpButtonLabel()
            //print("OPEN rowsToDisplay: ", rowsToDisplay.count)
        case 1:
            setUpButtonLabel()
            //print("CLOSED rowsToDisplay: ", rowsToDisplay.count)
        default:
            setUpButtonLabel()
        }
    }
    
    
    // sign in logo
//    let signInImageView: UIImageView = {
//        let imageView = UIImageView(image: #imageLiteral(resourceName: "bar_logo"))
//        imageView.contentMode = .scaleAspectFill
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.backgroundColor = .white
//        // circular picture
//        imageView.layer.cornerRadius = 10
//        imageView.clipsToBounds = true
//        imageView.layer.borderColor = UIColor.yellow.cgColor
//        imageView.layer.borderWidth = 2
//        return imageView
//    }()
    
    // check type segmented viewing filter
    let userTypeSegmentedControl: UISegmentedControl = {

        let types = ["Crew Member","Organization"]
        let sc = UISegmentedControl(items: types)
        // default as first item
        sc.selectedSegmentIndex = 0
        //sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        // highlighted filter color
        //sc.selectedSegmentTintColor = UIColor.lightRed
        // Scope: Normal text color
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        // Scope: Selected text color
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        return sc
    }()
    
    
    // create text field for username
    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Email",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
//        textField.layer.borderWidth = 2
//        textField.layer.borderColor = UIColor.yellow.cgColor
//        textField.layer.cornerRadius = 10
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        //textField.setLeftPaddingPoints(10)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create text field for password
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Password",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
//        textField.layer.borderWidth = 2
//        textField.layer.borderColor = UIColor.yellow.cgColor
//        textField.layer.cornerRadius = 10
        textField.addLine(position: .bottom, color: .beerOrange, width: 0.8)
        textField.isSecureTextEntry.toggle()
        //textField.setLeftPaddingPoints(10)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create button for forgot password
    let forgotPasswordButton: UIButton = {
        let button = UIButton()
        

        //button.backgroundColor = UIColor.green
        button.setTitle("Forgot Password", for: .normal)
        button.setTitleColor(.beerOrange, for: .normal)
        //button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleForgotPassword(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    

    
    // create button for log in
    let signinButton: UIButton = {
        let button = UIButton()
        

        button.backgroundColor = UIColor.beerOrange
//        button.layer.borderColor = UIColor.beerOrange.cgColor
//        button.layer.borderWidth = 2
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleSignIn(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // create button for creating a new organization
    let createOrgButton: UIButton = {
        let button = UIButton()
        

        //button.backgroundColor = UIColor.logoRed
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.setTitle("Create Organization", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleCreateOrg(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // create button for creating a new organization
    let createUserButton: UIButton = {
        let button = UIButton()
        

        //button.backgroundColor = UIColor.logoRed
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.setTitle("Create Crew Member", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleCreateUser(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()




    
    private func setupUI() {
        
        // placement of the image in cell
//        view.addSubview(signInImageView)
//        signInImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
//        signInImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
//        signInImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        signInImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -115).isActive = true
//
        //add username textfield
        view.addSubview(usernameTextField)
        //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
        usernameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30).isActive = true
        usernameTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        usernameTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        
        //add password textfield
        view.addSubview(passwordTextField)
        //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 95).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 10).isActive = true
        
        //add log in button
        view.addSubview(forgotPasswordButton)
        //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
//        forgotPasswordButton.heightAnchor.constraint(equalToConstant: 10).isActive = true
//        forgotPasswordButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        //forgotPasswordButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        forgotPasswordButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        
        //add log in button
        view.addSubview(signinButton)
        //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
        signinButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
//        signinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        signinButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 185).isActive = true
//        signinButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        signinButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 64).isActive = true
        signinButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -64).isActive = true
        signinButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 40).isActive = true
        
//        // segmented control
//        view.addSubview(userTypeSegmentedControl)
//        userTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        userTypeSegmentedControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 64).isActive = true
//        userTypeSegmentedControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -64).isActive = true
//        userTypeSegmentedControl.topAnchor.constraint(equalTo: signinButton.bottomAnchor, constant: 20).isActive = true
        
        //add ceate org button
        view.addSubview(createUserButton)
        //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
        createUserButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
//            createUserButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//            createUserButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 245).isActive = true
//            createUserButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        createUserButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 64).isActive = true
        createUserButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -64).isActive = true
        createUserButton.topAnchor.constraint(equalTo: signinButton.bottomAnchor, constant: 15).isActive = true
        
        //add ceate org button
        view.addSubview(createOrgButton)
        //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
        createOrgButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        createOrgButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 64).isActive = true
        createOrgButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -64).isActive = true
        createOrgButton.topAnchor.constraint(equalTo: createUserButton.bottomAnchor, constant: 15).isActive = true
        
        //setUpButtonLabel()
    }
    
    // this function is called when the user switches the segmented control between "Crew Member" and "Organization"
    private func setUpButtonLabel() {
        if userTypeSegmentedControl.selectedSegmentIndex == 0 {
            //add ceate org button
            view.addSubview(createUserButton)
            //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
            createUserButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
//            createUserButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//            createUserButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 245).isActive = true
//            createUserButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            createUserButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 64).isActive = true
            createUserButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -64).isActive = true
            createUserButton.topAnchor.constraint(equalTo: userTypeSegmentedControl.bottomAnchor, constant: 10).isActive = true

        } else {
            //add ceate org button
            view.addSubview(createOrgButton)
            //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
            createOrgButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
//            createOrgButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//            createOrgButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 245).isActive = true
//            createOrgButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            createOrgButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 64).isActive = true
            createOrgButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -64).isActive = true
            createOrgButton.topAnchor.constraint(equalTo: userTypeSegmentedControl.bottomAnchor, constant: 10).isActive = true
        }
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
