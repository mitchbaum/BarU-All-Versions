//
//  MyCrewController+UITableView.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/10/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage


extension MyCrewController {
    
    
    // delete crew member from tableView and firebase
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            // get the crew member you are swiping on to get delete action
            
            let crewMember = self.crew[indexPath.row]
            // remove the crew member from the tableView
            print("crew member being deleted is: ", crewMember)
            self.crew.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            let uid = crewMember.uid!
            
            self.db.collection("Users").document(uid).delete()
            //self.db.collection(crewMember.school!).document(crewMember.org!).collection("Crew").document(uid).delete()
            self.db.collection("Schools").document(crewMember.school!).collection("Orgs").document(crewMember.org!).collection("Crew").document(uid).delete()
            Storage.storage().reference().child("crew images/\(uid).png").delete(completion: nil)
            
        
            
        }
        // change color of delete button
        deleteAction.backgroundColor = UIColor.lightRed

        
        // this puts the action buttons in the row the user swipes so user can actually see the buttons to delete or edit
        return [deleteAction]
    }

    
    // create footer that displays when there are no files in the table
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No crew members added."
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }
    // create footer that is hidden when no rows are present
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return crew.count == 0 ? 150 : 0
        
    }
    
    
    // create some cells for the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // this will return a UITableViewCell
        //when you call the file on the cell, you trigger the didSet property in fileCell.swift file for var file: file?

        let cell = tableView.dequeueReusableCell(withIdentifier: CrewCell.identifier, for: indexPath) as! CrewCell
        let crewMember = crew[indexPath.row]
        cell.selectionStyle = .none
        // the cell takes a color with variable from UIColor+theme.swift file, in this case the function UIColor with the variable "someColor" found in that file
        //cell.backgroundColor = UIColor.tealColor
        // add some text to each cell and text color
        // access file for each row by using files model
        // make date show up pretty in cell by unwrapping name and founded property
        
        // download the org logo image from Firestore
        // user this code below whenever trying to download an image from firebase
        if let profilePic = crewMember.profilePic {
            let url = NSURL(string: profilePic)
            URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error ?? "")
                    return
                }
                // run image setter on main queue
                DispatchQueue.main.async {
                    cell.profilePicImageView.image = UIImage(data: data!)
                }
            }).resume()
        }
        cell.nameLabel.text = "\(crewMember.firstName ?? "") \(crewMember.lastName ?? "")"
        
        return cell
    
}
    // height of each cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    // add some rows to the tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // returns number of rows as number of files
        return crew.count
        //return uIowaOrgs.count
    }
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    
}


