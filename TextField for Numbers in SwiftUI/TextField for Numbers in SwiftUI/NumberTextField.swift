//
//  NumberTextField.swift
//  TextField for Numbers in SwiftUI
//
//  Created by Can Balkaya on 1/5/21.
//  Modified by Andrew Kingdom to allow decimals -- needs more testing

import SwiftUI

struct NumberTextField<V>: UIViewRepresentable where V: Numeric & LosslessStringConvertible {
    
    typealias UIViewType = UITextField
    
    // MARK: - Properties
    @Binding var value: V
    
    // MARK: - Functions
    func updateUIView(_ editField: UITextField, context: UIViewRepresentableContext<NumberTextField>) {
        editField.text = String(value)
    }
    
    func makeUIView(context: UIViewRepresentableContext<NumberTextField>) -> UITextField {
        let editField = UITextField()
        editField.delegate = context.coordinator
        editField.keyboardType = .decimalPad

        return editField
    }
    
    func makeCoordinator() -> NumberTextField.Coordinator {
        Coordinator(value: $value)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {

        // MARK: - Properties
        var value: Binding<V>
        var isEditing = false
        var newValue: String? = ""
        
        // MARK: - Life Cycle
        init(value: Binding<V>) {
            self.value = value
        }

        // MARK: - Functions
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let text = textField.text as NSString?
            self.newValue = text?.replacingCharacters(in: range, with: string)
            let formatter: NumberFormatter = NumberFormatter()
            formatter.locale = NSLocale(localeIdentifier: "EN") as Locale?
            let final = formatter.number(from: (newValue ?? "" ) as String)
            if newValue!.isEmpty {
                return true
            }
            else if final != nil {
                return true
            } else if nil == newValue || newValue!.isEmpty {
                self.value.wrappedValue = 0  // default
            }
            return false
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            isEditing = true
        }

        // Needed??
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            if (self.newValue ?? "").isEmpty {
                self.value.wrappedValue = 0  // default
            }
            return true
        }
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            if reason == .committed {
                textField.resignFirstResponder()
                isEditing = false
                if (self.newValue ?? "").isEmpty {
                    self.value.wrappedValue = 0  // default
                }
            }
        }
    }
}
