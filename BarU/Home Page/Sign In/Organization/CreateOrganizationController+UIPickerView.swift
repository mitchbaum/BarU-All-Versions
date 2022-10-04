//
//  CreateOrganizationController+UIPickerView.swift
//  BarU
//
//  Created by Mitch Baumgartner on 8/10/21.
//

import UIKit

extension CreateOrganizationController {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return schoolsTestEnvironment.count
        return schools.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return schoolsTestEnvironment[row]
        return schools[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        schoolSelectorTextField.text = schoolsTestEnvironment[row]
//        schoolSelectorTextField.resignFirstResponder()
        
        schoolSelectorTextField.text = schools[row].name
        schoolSelectorTextField.resignFirstResponder()
    }
}

