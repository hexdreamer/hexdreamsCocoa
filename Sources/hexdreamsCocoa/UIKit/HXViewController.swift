// hexdreamsCocoa
// HXViewController.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

#if os(iOS)
import UIKit

open class HXViewController : UIViewController,UIViewControllerExtensionData,HXRepresentation,HXErrorHandler,UITextFieldDelegate {

    // MARK: - UIViewControllerExtensionData Conformance
    public var identifier: String?
    public var dataCache: HXCachingWrapper?
    public var cellIdentifier: String?
    public var selectedItem: AnyObject?
    public var callback: ((UIViewController) -> Void)?
    public var successCallback: ((UIViewController) -> Void)?
    public var failureCallback: ((UIViewController) -> Void)?
    public var cancelCallback: ((UIViewController) -> Void)?

    // MARK: - HXRepresentation
    public var representedObject: AnyObject?

    // MARK: - HXErrorHandler Conformance
    public var error:Error?

    // MARK: - UITextFieldDelegate Methods
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.actions(forTarget: self, forControlEvent:.editingDidEnd) != nil {
            textField.sendActions(for:.editingDidEnd)
        }
        return true;
    }
}

#endif
