// hexdreamsCocoa
// HXViewController.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

import UIKit

public class HXViewController : UIViewController, UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate Methods
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.actionsForTarget(self, forControlEvent: .EditingDidEnd) != nil {
            textField.sendActionsForControlEvents(.EditingDidEnd)
        }
        return true;
    }

}

