//
//  HXCollectionViewController.swift
//  Wild-Fire
//
//  Created by Kenny Leung on 5/16/18.
//  Copyright © 2018 PepperDog Enterprises. All rights reserved.
//
// https://forums.swift.org/t/declaring-a-property-with-closure-argument-typed-to-self/12727

import Foundation
import UIKit

open class HXCollectionViewController : UICollectionViewController,UIViewControllerExtensionData,HXRepresentation,HXErrorHandler {
        
    // MARK: - UICollectionViewDataSource/Delegate
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataCache?.dataArray?.count ?? 0
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let representedObject = self.dataCache?.dataArray?[indexPath.row]
        let cellIdentifier = self.cellIdentifier ?? "HXCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:cellIdentifier, for:indexPath)
        if let hxcell = cell as? HXCollectionViewCell {
            hxcell.representedObject = representedObject
            self.configureCell(hxcell, forRowAt:indexPath)
        }
        return cell
    }
    
    // MARK: - Subclasses should override
    open func configureCell(_ cell:HXCollectionViewCell, forRowAt:IndexPath) {}
    
    // MARK: - UIViewControllerExtensionData Conformance
    public var identifier:String?
    public var dataCache:HXCachingWrapper? {
        willSet {
            if newValue !== dataCache {
                //self._stopObserving()
            }
        }
        didSet {
            if ( oldValue !== dataCache ) {
                //self._setUpForCachedData()
            }
        }
    }
    public var cellIdentifier:String?
    public var selectedItem:AnyObject?

    public var callback: ((UIViewController) -> Void)?
    public var successCallback: ((UIViewController) -> Void)?
    public var failureCallback: ((UIViewController) -> Void)?
    public var cancelCallback: ((UIViewController) -> Void)?
    
    // MARK: - HXRepresentation
    public var representedObject:AnyObject?

    // MARK: - HXErrorHandler Conformance
    public var error: Error?

}
