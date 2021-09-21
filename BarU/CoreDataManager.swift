//
//  CoreDataManager.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/7/21.
//

import Foundation

import CoreData

struct CoreDataManager {
    // shared is a variable of the instance of this class
    static let shared = CoreDataManager() // will live forever as long as this application is still alive. Its properties will too.
    // loading TrainingModels into the persistent store of the container
    let persistentContainer: NSPersistentContainer = {
        // initalization of our core data stack
        let container = NSPersistentContainer(name: "BarU")
        container.loadPersistentStores { (storeDescription, err) in
            if let err = err {
                fatalError("loading of store failed: \(err)")
            }
        }
        return container
    }()
    
    func fetchUserData() -> [UserData] {
        // context is shared singleton shared persistent container, holds all our data from CoreDataManager.swift file
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<UserData>(entityName: "UserData")
        do {
            let userData = try context.fetch(fetchRequest)
            
            
            
            return userData
            
        } catch let fetchErr {
            print("Failed to fetch userData:", fetchErr)
            // return empty array if actually errors
            return []
        }
    }
    
    
    // tuple for all items in a file (checks, cash jobs, line items due to HO, RCV to do, check amount, check number, check date)
    func createUserData(selectedSchool: String?) -> (UserData?, Error?) {
        let context = persistentContainer.viewContext
        // create an employee in coredata
        let localData = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: context) as! UserData
        
        // when creating a piece of local data, attach it to a specific school
        localData.selectedSchool = selectedSchool
        
        // need to set value for key of selectedSchool inside of entity attribute UserData
        localData.setValue(selectedSchool, forKey: "selectedSchool")
        
        do {
            try context.save()
            // if save success, get employee(employee.setValue(employeeName, forKey: "name")) and return that employee, and return nil for the error
            return (localData, nil)
        } catch let err {
            print("Failed to create item", err)
            return (nil, err)
        }
    }
    
}
