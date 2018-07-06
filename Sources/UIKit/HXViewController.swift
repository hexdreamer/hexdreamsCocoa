// hexdreamsCocoa
// HXViewController.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import UIKit

public class HXViewController : UIViewController, UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate Methods
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.actions(forTarget: self, forControlEvent:.editingDidEnd) != nil {
            textField.sendActions(for:.editingDidEnd)
        }
        return true;
    }

}

