//
//  HomeController+UITableView.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/2/21.
//

import UIKit
import Firebase


extension HomeController {
    
    // when user taps on row bring them into another view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // whenever user taps on a bar cell, push over the information to the employee view controller
        // persist the change in defaults

        // save the selection on users local device so when they return to the app the school they selected will stay as default
        //let org: Org
        if searchController.isActive {
            let school = schoolSearch[indexPath.row]
            let defaults = UserDefaults.standard
            defaults.set(school.name!, forKey: "selectedSchool")
            let homeController = HomeController()
            // push into new viewcontroller
            self.navigationController?.pushViewController(homeController, animated: true)

           
        } else {
            let selectedOrg = orgs[indexPath.row]
            //let GUITexting = uIowaBars[indexPath.row]
            print("bar selected: \(selectedOrg)")
            let orgDetailsController = OrgDetailsController()
            orgDetailsController.orgNameLabel.text = selectedOrg.name
            orgDetailsController.updateLabel.text = Utilities.timestampConversion(timeStamp: selectedOrg.timeStamp!).timeAgoDisplay()
            // download the org logo image from Firestore
            // user this code below whenever trying to download an image from firebase
            if let logo = selectedOrg.logo {
                let url = NSURL(string: logo)
                URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                    if error != nil {
                        print(error ?? "")
                        return
                    }
                    // run image setter on main queue
                    DispatchQueue.main.async {
                        orgDetailsController.orgImageView.image = UIImage(data: data!)
                    }
                }).resume()
            } 
            guard let school = UserDefaults.standard.string(forKey: "selectedSchool") else { return print("error fetching selected org school")}
            guard let org = selectedOrg.name else { return print("error fetching selected org org name")}
            
            db.collection("Schools").document(school).collection("Orgs").document(org).getDocument { (snapshot, error) in
                if let data = snapshot?.data() {
                    print("org cell data loaded")
                    guard let established = data["established"] as? String else { return print("error fetching org est")}
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

                    
                    orgDetailsController.establishedLabel.text = "Est. \(established)"
                    if slogan == "" {
                        orgDetailsController.sloganLabel.text = " "
                    } else {
                        orgDetailsController.sloganLabel.text = "\"\(slogan)\""
                    }
                    orgDetailsController.coverMessage.text = cover
                    orgDetailsController.waitTimeMessage.text = waitTime
                    orgDetailsController.poppinMessage.text = poppin
                    if capacity == 1 {
                        orgDetailsController.atCapacityMessage.text = "Yes"
                        orgDetailsController.atCapacityMessage.textColor = .logoRed
                    } else {
                        orgDetailsController.atCapacityMessage.text = "No"
                    }
                    if sunSpecial == "" {
                        orgDetailsController.sundayMessage.text = " "
                    } else {
                        orgDetailsController.sundayMessage.text = sunSpecial
                    }
                    if monSpecial == "" {
                        orgDetailsController.mondayMessage.text = " "
                    } else {
                        orgDetailsController.mondayMessage.text = monSpecial
                    }
                    if tuesSpecial == "" {
                        orgDetailsController.tuesdayMessage.text = " "
                    } else {
                        orgDetailsController.tuesdayMessage.text = tuesSpecial
                    }
                    if wedSpecial == "" {
                        orgDetailsController.wednesdayMessage.text = " "
                    } else {
                        orgDetailsController.wednesdayMessage.text = wedSpecial
                    }
                    if thursSpecial == "" {
                        orgDetailsController.thursdayMessage.text = " "
                    } else {
                        orgDetailsController.thursdayMessage.text = thursSpecial
                    }
                    if friSpecial == "" {
                        orgDetailsController.fridayMessage.text = " "
                    } else {
                        orgDetailsController.fridayMessage.text = friSpecial
                    }
                    if satSpecial == "" {
                        orgDetailsController.saturdayMessage.text = " "
                    } else {
                        orgDetailsController.saturdayMessage.text = satSpecial
                    }
                    orgDetailsController.announcementsMessage.text = announcement
                    
                }
            }
            // push into new viewcontroller
            self.navigationController?.pushViewController(orgDetailsController, animated: true)
        }
        
    }
    

    
    // create footer that displays when there are no files in the table
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No bars found. Pull to search."
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }
    // create footer that is hidden when no rows are present
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if searchController.isActive {
            return schoolSearch.count == 0 ? 150 : 0
        } else {
            return orgs.count == 0 ? 150 : 0
            
            //return uIowaBars.count == 0 ? 150 : 0
        }
        
    }
    
    
    // create some cells for the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // this will return a UITableViewCell
        //when you call the file on the cell, you trigger the didSet property in fileCell.swift file for var file: file?
//        let file: File
        if (searchController.isActive) {
            tableView.separatorColor = .beerOrange
            let cell = tableView.dequeueReusableCell(withIdentifier: SchoolCell.identifier, for: indexPath) as! SchoolCell
            let school = schoolSearch[indexPath.row]
            cell.nameLabel.text = school.name
            cell.cityStateLabel.text = "\(school.city ?? ""), \(school.state ?? "")"
            // when you add another university uncomment this code out below to fetch the school's logo from Firebase storage.
            // START
//            db.collection("Schools").document(school.name!).getDocument { (snapshot, error) in
//                if let data = snapshot?.data() {
//                    // fetch school logo
//                    if let profilePic = data["logo url"] as? String {
//                        print("profilePic = ", profilePic)
//                        let url = NSURL(string: profilePic)
//                        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
//                            if error != nil {
//                                print("profilePic has no URL string, the string is empty.", error ?? "")
//                                return
//                            }
//                            // run image setter on main queue
//                            DispatchQueue.main.async {
//                                cell.schoolLogo.image = UIImage(data: data!)
//                            }
//                        }).resume()
//                    }
//                }
//            }
            // END
            return cell
        } else {
            tableView.separatorColor = .lightGray
            let cell = tableView.dequeueReusableCell(withIdentifier: OrgCell.identifier, for: indexPath) as! OrgCell
            let bar = orgs[indexPath.row]
            //let GUITesting = uIowaBars[indexPath.row]
            
            // download the org logo image from Firestore
            // user this code below whenever trying to download an image from firebase
            if let logo = bar.logo {
                let url = NSURL(string: logo)
                URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                    if error != nil {
                        print(error ?? "")
                        return
                    }
                    // run image setter on main queue
                    DispatchQueue.main.async {
                        cell.orgImageView.image = UIImage(data: data!)
                    }
                }).resume()
            }
                
            cell.nameLabel.text = bar.name
            cell.waitTimeMessage.text = bar.waitTime
            cell.coverMessage.text = bar.cover
            cell.poppinMessage.text = bar.poppin
            cell.updateLabel.text = Utilities.timestampConversion(timeStamp: bar.timeStamp!).timeAgoDisplay()
            //cell.nameLabel.text = GUITesting
            return cell
            
        }
        
        
//        cell.file = file
        
        
        // change cell background color

        // the cell takes a color with variable from UIColor+theme.swift file, in this case the function UIColor with the variable "someColor" found in that file
        //cell.backgroundColor = UIColor.tealColor
        // add some text to each cell and text color
        // access file for each row by using files model
        // make date show up pretty in cell by unwrapping name and founded property


//        cell.textLabel?.textColor = .black
//        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
//        cell.textLabel?.text = bar
    
}
    // height of each cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchController.isActive {
            return 60
        }
        return 105
    }
    // add some rows to the tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController.isActive) {
            return schoolSearch.count
        }
        
        // returns number of rows as number of files
        //return uIowaBars.count
        return orgs.count
    }

    
}


