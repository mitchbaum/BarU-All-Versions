//
//  QuickUpdateOrgDataController+PickerView.swift
//  BarU
//
//  Created by Mitch Baumgartner on 7/7/21.
//

import UIKit
import Firebase


extension QuickUpdateOrgDataController {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == waitTimePicker {
            return waitTimes.count
        } else if pickerView == poppinPicker {
            return poppinStatus.count
        }

        return coverCharges.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == waitTimePicker {
            return waitTimes[row]
        } else if pickerView == poppinPicker {
            return poppinStatus[row]
        }
        
        return coverCharges[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == waitTimePicker {
            waitTimeTextfield.text = waitTimes[row]
            waitTimeTextfield.resignFirstResponder()
        } else if pickerView == poppinPicker {
            poppinTextField.text = poppinStatus[row]
            poppinTextField.resignFirstResponder()
        } else {
            coverTextField.text = coverCharges[row]
            coverTextField.resignFirstResponder()
        }
    }
}

