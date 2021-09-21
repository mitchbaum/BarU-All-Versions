//
//  ViewController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/1/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import SwiftUI
import LBTATools


class HomeController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    //create variable to reference the firebase data so we can read, wirte and update it
    let db = Firestore.firestore()
    
    var orgs = [Org]()
    var orgCollectionReference: CollectionReference!
    
    // create dataset for schools
    var schools = [School]()
    // create dataset for user search for schools
    var schoolSearch = [School]()
    var schoolCollectionReference: CollectionReference!
    
    // this variable will change depending on what type of user is signed in
    var barButtonItemWidth = 106.66 as CGFloat
    
    
    
    
    var schoolsTest = ["University of Iowa",
                   "University of Minnesota",
                   "University of Wisconsin - Superior",
                   "Iowa State University",
                   "University of Wisconsin - Madison",
                   "University of Wisconsin - Eau Claire",
                   "University of Minnesota - Duluth",
                   "University of California - Los Angeles"]
    

    var uIowaBars = ["Brothers", "El Rays", "Sports Column", "Deadwood", "Mickeys", "Fieldhouse", "Dublin Underground", "The Summit"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

        // creates title of files
        navigationItem.title = UserDefaults.standard.string(forKey: "selectedSchool") ?? "Search for a school..."
        
        // when user selects a new school, the navbar back button is hidden
        navigationItem.setHidesBackButton(true, animated: true)
        // if user is in dark mode, tableView cell will remain in light mode when user selects
        tableView.overrideUserInterfaceStyle = .light
        

        
        

        
        
        

        

//        let attributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 7)!]
//        UINavigationBar.appearance().titleTextAttributes = attributes
        
//        // refresh button in left bar
//        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.handleRefresh))
//        navigationItem.leftBarButtonItems = [refresh]
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign In", style: .plain, target: self, action: #selector(handleSignIn))

        // changes color of list to dark blue
        tableView.backgroundColor = UIColor.matteBlack
        
        // change color of seperator lines
        tableView.separatorColor = .gray
        
        // removes lines below cells
        tableView.tableFooterView = UIView() // blank UIView
        
        // this sets up the tableView so that rows are actually visible
        tableView.dataSource = self
        tableView.delegate = self
        
        // register fileCell wiht cellId
        tableView.register(OrgCell.self, forCellReuseIdentifier: OrgCell.identifier)
        tableView.register(SchoolCell.self, forCellReuseIdentifier: SchoolCell.identifier)
        
        let selectedSchool = UserDefaults.standard.string(forKey: "selectedSchool") ?? "Search for a school..."

        orgCollectionReference = Firestore.firestore().collection("Schools").document(selectedSchool).collection("Orgs")
        schoolCollectionReference = Firestore.firestore().collection("Schools")
        //schoolSearch = schools
        initSearchController()
        fetchOrgData()
        print("reloaded files")

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Org data loaded")
        isUserSignedIn()
        tableView.reloadData()
    }

    let logoImageView : UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "logo-label-RED-WHITE"))
        imageView.contentMode = .scaleAspectFit
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageView.backgroundColor = .green
        return imageView
    }()


    fileprivate func setUpNavBar() {
        // takes the width minus the width of the label minus the 8 padding on either side of the view in the navBar and the buttons
        // width of one bar button item is 53.33
        let navWidth = (navigationController?.navigationBar.frame.width)! - 90 - 16
        let finalWidthWithNavItems = navWidth - barButtonItemWidth
        print("barButtonItemWidth = ", barButtonItemWidth)
        
        // this changes the titleView frame within the navBar
        let titleView = UIView()
        //titleView.backgroundColor = .yellow
        titleView.frame = .init(x: 0, y: 0, width: finalWidthWithNavItems, height: 50)
        titleView.hstack(logoImageView.withWidth(90), UIView().withWidth(finalWidthWithNavItems))
        navigationItem.titleView = titleView
        
    }

    
    
    func isUserSignedIn() {
        print("checking if user is signed in")
        if Auth.auth().currentUser != nil {
            checkUserType()
        }  else {
             //user is not logged in
            // sign in button in right bar
            //let customSI = UIBarButtonItem(customView: signinButton)
            self.barButtonItemWidth = 106.33
            self.setUpNavBar()
            
            let signIn = UIBarButtonItem(image: UIImage(named: "sign_in"), style: .plain, target: self, action: #selector(handleSignIn))
            signIn.tintColor = .white
            
            let refresh = UIBarButtonItem(image: UIImage(named: "refresh"), style: .plain, target: self, action: #selector(self.handleRefresh))
            self.navigationItem.rightBarButtonItems = [signIn, refresh]
            
                
            }
    }
    
    // this will check if the user logging in is an organization (admin) or a crew member
    func checkUserType() {
        print("checking user type")
        let refresh = UIBarButtonItem(image: UIImage(named: "refresh"), style: .plain, target: self, action: #selector(self.handleRefresh))
        let handleQuickUpdate = UIBarButtonItem(image: UIImage(named: "update"), style: .plain, target: self, action: #selector(self.handleUpdateData))
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).getDocument { (snapshot, error) in
            if let data = snapshot?.data() {
                guard let isAdmin = data["isAdmin"] as? Bool else { return }
                guard let email = data["email"] as? String else { return }
                // SuperAdmin access
                if email == "mitch.baumgartner@yahoo.com" {
                    print("is super admin.")
                    self.setUpNavBar()
                    let signOut = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(self.handleSignOut))
                    let addSchool = UIBarButtonItem(title: "Add School", style: .plain, target: self, action: #selector(self.handleCreateSchool))
                    self.navigationItem.rightBarButtonItems = [addSchool, signOut]
                } else if isAdmin == true {
                    // organization owner access
                    print("\(uid): is an admin")
                    self.barButtonItemWidth = 160
                    self.setUpNavBar()
                    let myOrg = UIBarButtonItem(image: UIImage(named: "my_org"), style: .plain, target: self, action: #selector(self.handleMyOrg))
                    self.navigationItem.rightBarButtonItems = [myOrg, handleQuickUpdate, refresh]
                } else {
                    // regular crew member access
                    print("\(uid): is NOT an admin")
                    self.barButtonItemWidth = 160
                    self.setUpNavBar()
                    let myAccount = UIBarButtonItem(image: UIImage(named: "my_account"), style: .plain, target: self, action: #selector(self.handleMyAccount)) // size of image is 48 x 48 px , 
                    myAccount.tintColor = .white
                    self.navigationItem.rightBarButtonItems = [myAccount, handleQuickUpdate, refresh]
                }
            } else {
                // user has been terminated by organization
                self.setUpNavBar()
                let myAccountTermed = UIBarButtonItem(image: UIImage(named: "my_account"), style: .plain, target: self, action: #selector(self.handleMyDeletedAccount))
                self.navigationItem.rightBarButtonItems = [myAccountTermed, refresh]
            }
        }
    }
    
    @objc func handleSignOut() {
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true) {
                    let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.handleRefresh))
                    self.navigationItem.leftBarButtonItems = [refresh]
                    let signIn = UIBarButtonItem(title: "Sign In", style: .plain, target: self, action: #selector(self.handleSignIn))
                    self.navigationItem.rightBarButtonItems = [signIn]
                }
                print("user signed out")
            } catch let err {
                print("Failed to sign out with error ", err)
                
            }
        }
        // alert
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(signOutAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
    
    
    // this function will fetch all data in database. Do not activate until GUI is finished.
    func fetchOrgData() {
        orgCollectionReference.getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            } else {
                guard let snap = snapshot else { return }
                for document in snap.documents {
                    let data = document.data()
                    let logo = data["logo url"] as? String ?? ""
                    let name = data["org name"] as? String ?? "No name found"
                    let waitTime = data["wait time"] as? String ?? ""
                    let cover = data["cover"] as? String ?? ""
                    let poppin = data["poppin"] as? String ?? ""
                    let timeStamp = data["timestamp"] as? String ?? ""
 
                    
                    let newOrg = Org(logo: logo, name: name, waitTime: waitTime, cover: cover, poppin: poppin, timeStamp: timeStamp)
                    self.orgs.append(newOrg)
                    
                }
                self.orgs.sort(by: {$0.name! < $1.name!})
                self.tableView.reloadData()
            }
        }
    }
    
    // this function will fetch all school data in database. Do not activate until GUI is finished.
    func fetchSchoolData() {
        schoolCollectionReference.getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            } else {
                guard let snap = snapshot else { return }
                for document in snap.documents {
                    let data = document.data()

                    let name = data["name"] as? String ?? "No school found"
                    let city = data["city"] as? String ?? ""
                    let state = data["state"] as? String ?? ""
                    // uncomment this when you add another university.
                    // START
                    //let logo = data["logo"] as? String ?? ""
                    //END
 
                    
                    let newSchool = School(name: name, city: city, state: state) //logo: logo
                    self.schools.append(newSchool)
                    
                }
                self.tableView.reloadData()
            }
        }
    }
    
    // this function will fetch all data in database minus the org icon. this should reduce the Firebase storage bandwith.
    func fetchOrgDataMinusIcon() {
        orgCollectionReference.getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            } else {
                guard let snap = snapshot else { return }
                for document in snap.documents {
                    let data = document.data()
                    let name = data["org name"] as? String ?? "No name found"
                    let waitTime = data["wait time"] as? String ?? ""
                    let cover = data["cover"] as? String ?? ""
                    let poppin = data["poppin"] as? String ?? ""
                    let timeStamp = data["timestamp"] as? String ?? ""
 
                    
                    let newOrg = Org(name: name, waitTime: waitTime, cover: cover, poppin: poppin, timeStamp: timeStamp)
                    self.orgs.append(newOrg)
                    
                }
                self.orgs.sort(by: {$0.name! < $1.name!})
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    
    @objc private func handleSignIn() {
        print("Sign in")
        let signInController = SignInController()
        // push into new viewcontroller
        navigationController?.pushViewController(signInController, animated: true)
    }
    
    @objc private func handleMyOrg() {
        print("My org button pressed")
        let myOrgController = MyOrgController()
        let navController = CustomNavigationController(rootViewController: myOrgController)
        navController.modalPresentationStyle = .fullScreen
        // push into new viewcontroller
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func handleMyAccount() {
        print("My account button pressed")
        let myAccountController = MyAccountController()
        let navController = CustomNavigationController(rootViewController: myAccountController)
        navController.modalPresentationStyle = .fullScreen
        // push into new viewcontroller
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func handleMyDeletedAccount() {
        print("My account button pressed, this account is deleted")
        let accountDeletedController = AccountDeletedController()
        let navController = CustomNavigationController(rootViewController: accountDeletedController)
        navController.modalPresentationStyle = .fullScreen
        // push into new viewcontroller
        present(navController, animated: true, completion: nil)
    }
    
    
    @objc func handleRefresh() {
        print("Refresh")
        orgs = []
        fetchOrgDataMinusIcon()
    }
    
    
    @objc private func handleUpdateData() {
        print("Updating bar data")
        let updateOrgDataController = QuickUpdateOrgDataController()
        let navController = CustomNavigationController(rootViewController: updateOrgDataController)
        present(navController, animated: true, completion: nil)
        
    }
    
    @objc private func handleCreateSchool() {
        print("Creating a school")
        let createSchoolController = CreateSchoolController()
        let navController = CustomNavigationController(rootViewController: createSchoolController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
        
    }
    
    
    let searchController = UISearchController()
    func initSearchController() {
        fetchSchoolData()
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = true
        //searchController.searchBar.placeholder = "Search for files"
        // change color and text of placeholder
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString.init(string: "Search for a school", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        // makes text in search bar white
        searchController.searchBar.barStyle = .black
        // makes color of "Cancel" and cursor blinking white
        searchController.searchBar.tintColor = .white
        // Text field in search bar.
        let textField = searchController.searchBar.value(forKey: "searchField") as! UITextField
        let glassIconView = textField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        glassIconView.tintColor = UIColor.white
        searchController.searchBar.returnKeyType = UIReturnKeyType.search
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        //navigationItem.hidesSearchBarWhenScrolling = false
        //searchController.searchBar.showsScopeBar = true
        searchController.searchBar.delegate = self
        searchController.searchBar.becomeFirstResponder()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text!
        filterForSearch(searchText: searchText)

    }
    func filterForSearch(searchText: String, scopeButton : String = "All") {
        
        // this will give the school in the schools variable
        schoolSearch = schools.filter {
            school in
            let noMatch = scopeButton == "All"
            if (searchController.searchBar.text != "") {
                let searchMatch = school.name!.uppercased().contains(searchText.uppercased())
                return searchMatch
            } else {
                return noMatch
            }
        }
        schools.sort(by: {$0.name! < $1.name!})
        tableView.reloadData()
    }
    



}

