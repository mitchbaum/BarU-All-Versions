//
//  MyCrewController.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/10/21.
//

import UIKit
import FirebaseAuth
import Firebase

class MyCrewController: UITableViewController {
    
    var crew = [Crew]()
    var myOrgCollectionRef: CollectionReference!
    
    //create variable to reference the firebase data so we can read, wirte and update it
    let db = Firestore.firestore()
    
    var creww = ["Jack Black", "Nik Wurth", "Madi Holm", "Heath Gibbs", "Ethan Brader", "Sara Carr"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "My Crew"
        
        view.backgroundColor = UIColor.matteBlack
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
        tableView.register(CrewCell.self, forCellReuseIdentifier: CrewCell.identifier)
        fetchCrewData() 

    }
    
    // this function will fetch all crew data in database for the specific org
    private func fetchCrewData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).getDocument { (snapshot, error) in
            if let data = snapshot?.data() {
                guard let org = data["org name"] as? String else { return }
                guard let school = data["school"] as? String else { return }
                self.myOrgCollectionRef = Firestore.firestore().collection("Schools").document(school).collection("Orgs").document(org).collection("Crew")
                self.myOrgCollectionRef.getDocuments { (snapshot, error) in
                    if let err = error {
                        debugPrint("Error fetching docs: \(err)")
                    } else {
                        guard let snap = snapshot else { return }
                        for document in snap.documents {
                            let data = document.data()
                            let profilePic = data["profile pic url"] as? String ?? ""
                            let firstName = data["first name"] as? String ?? ""
                            let lastName = data["last name"] as? String ?? ""
                            let uid = data["uid"] as? String ?? ""
                            let org = data["org name"] as? String ?? ""
                            let school = data["school"] as? String ?? ""
                            
                            
                            
                            let newCrew = Crew(profilePic: profilePic, firstName: firstName, lastName: lastName, uid: uid, school: school, org: org)
                            self.crew.append(newCrew)
                            
                        }
                        self.crew.sort(by: {$0.lastName! < $1.lastName!})
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

