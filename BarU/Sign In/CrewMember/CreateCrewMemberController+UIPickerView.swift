//
//  CreateCrewMemberController+UIPickerView.swift
//  BarU
//
//  Created by Mitch Baumgartner on 8/10/21.
//

import UIKit

extension CreateCrewMemberController {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return schoolsTestEnvironment.count
        if pickerView == schoolPicker {
            return schools.count
        } else {
            return orgs.count
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return schoolsTestEnvironment[row]
        if pickerView == schoolPicker {
            return schools[row].name
        } else {
            return orgs[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        schoolSelectorTextField.text = schoolsTestEnvironment[row]
//        schoolSelectorTextField.resignFirstResponder()
        if pickerView == schoolPicker {
            if schools[row].name == "" {
                showError(title: "Error", message: "Please select a school.")
            } else {
                schoolSelectorTextField.text = schools[row].name
                schoolSelectorTextField.resignFirstResponder()
                orgs = []
                fetchOrgData()
            }
        } else {
            if orgs.count != 1 {
                orgSelectorTextField.text = orgs[row].name
                orgSelectorTextField.resignFirstResponder()
            } else {
                showError(title: "Error", message: "Please select a school.")
            }
        }
        
        

    }
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
}


