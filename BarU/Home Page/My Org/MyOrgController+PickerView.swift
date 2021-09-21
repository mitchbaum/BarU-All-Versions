//
//  MyOrgController+PickerView.swift
//  BarU
//
//  Created by Mitch Baumgartner on 8/6/21.
//

import UIKit

extension MyOrgController {
    
    
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
            waitTimeTextField.text = waitTimes[row]
            waitTimeTextField.resignFirstResponder()
        } else if pickerView == poppinPicker {
            poppinTextField.text = poppinStatus[row]
            poppinTextField.resignFirstResponder()
        } else {
            coverTextField.text = coverCharges[row]
            coverTextField.resignFirstResponder()
        }
    }
}


