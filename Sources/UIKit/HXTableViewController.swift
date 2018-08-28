//
//  HXTableViewController.swift
//  Wild-Fire
//
//  Created by Kenny Leung on 5/12/18.
//  Copyright © 2018 PepperDog Enterprises. All rights reserved.
//

import Foundation
import UIKit

open class HXTableViewController : UITableViewController,UIViewControllerExtensionData,HXRepresentation,HXErrorHandler {
    
    // MARK: - Properties
    var usesStaticCells:Bool = false
    
    // MARK: - Overridden Methods
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let refreshControl = self.refreshControl, refreshControl.isRefreshing {
            if self.tableView.tableHeaderView != nil && self.tableView.contentOffset.y == 0 {
                self.tableView.setContentOffset(CGPoint(x: 0, y: -60), animated:false)
            }
        }
        self.updateUI()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? HXRepresentation {
            let obj = cell.representedObject
            self.selectedItem = obj
            if var destVC = segue.destination as? HXRepresentation, destVC.representedObject == nil {
                destVC.representedObject = self.selectedItem
            }
        }
    }
    
    // MARK: - New Methods
    func updateUI() {
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource/Delegate
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.usesStaticCells {
            return super.tableView(tableView, numberOfRowsInSection:section)
        }
        
        guard let rawData = self.dataCache?.data else {
            return 0
        }
        
        if let dataArray = rawData as? [AnyObject] {
            print("Array Data: \(type(of:rawData)) [\(dataArray.count)]")
            return dataArray.count
        } else {
            return 0
        }
        
        //return self.dataCache?.dataArray?.count ?? 0;
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.usesStaticCells {
            return super.tableView(tableView, cellForRowAt:indexPath)
        }
        
        let representedObject = self.dataCache?.dataArray?[indexPath.row]
        let cellIdentifier = self.cellIdentifier ?? "HXTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier, for:indexPath)
        if let hxcell = cell as? HXTableViewCell {
            hxcell.representedObject = representedObject;
            if let modelObject = representedObject as? HXModelObject {
                hxcell.textLabel?.text = modelObject.text
                hxcell.detailTextLabel?.text = modelObject.detailText
            }
            self.configureCell(hxcell, forRowAt:indexPath)
        }
        return cell;
    }
    
    // MARK: - Action Methods
    @IBAction func success(_ sender:AnyObject) {
        self.success()
    }
    
    @IBAction func cancel(_ sender:AnyObject) {
        self.cancel()
    }
    
    // MARK: - Subclasses should override
    func configureCell(_ cell:HXTableViewCell, forRowAt:IndexPath) {}
    
    // MARK: - SSSCache integration. Subclasses may override
    func loadRunning() {}
    func loadSuspended() {}
    func loadCanceling() {}
    func loadCompleted() {}

    func refreshRunning() {
        if let refresh = self.refreshControl {
            refresh.attributedTitle = NSAttributedString(string:"Refreshing")
            refresh.beginRefreshing()
        }
    }
    func refreshSuspended() {}
    func refreshCanceling() {}
    func refreshCompleted() {
        guard let refresh = self.refreshControl else {
            return
        }
        refresh.endRefreshing()
        refresh.attributedTitle = NSAttributedString(string:"Refresh Completed")
        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.25) { [weak self] in
            if let this = self, let refresh = this.refreshControl {
                refresh.attributedTitle = NSAttributedString(string:"Pull to Refresh")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func _setUpForCachedData() {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action:#selector(HXTableViewController._refresh), for:.valueChanged)
            self.refreshControl?.attributedTitle = NSAttributedString(string:"Pull to Refresh")
        }
    }
    
    @objc private func _refresh(sender:AnyObject) {
        self.dataCache?.refresh()
    }
    
    private func _startObserving(dataCache target:HXCachingWrapper) {
        HXObserverCenter.shared.observe(target:target, keyPath:\HXCachingWrapper.data, notify:self) { [weak self] (anyobj, anykp) in
            self?.tableView.reloadData()
        }
        
        HXObserverCenter.shared.observe(target:target, keyPath:\HXCachingWrapper.loadState, notify:self) { [weak self] (anyobj, anykp) in
            guard let this = self,
                let cache = anyobj as? HXCachingWrapper else {
                    return // block
            }
            switch cache.loadState {
            case .running:
                this.loadRunning()
            case .suspended:
                this.loadSuspended()
            case .canceling:
                this.loadCanceling()
            case .completed:
                this.loadCompleted()
            }
        }
        HXObserverCenter.shared.observe(target:target, keyPath:\HXCachingWrapper.refreshState, notify:self) { [weak self] (anyobj, anykp) in
            guard let this = self,
                let cache = anyobj as? HXCachingWrapper else {
                    return // block
            }
            switch cache.refreshState {
            case .running:
                this.refreshRunning()
            case .suspended:
                this.refreshSuspended()
            case .canceling:
                this.refreshCanceling()
            case .completed:
                this.refreshCompleted()
            }
        }
    }
    
    // MARK: - UIViewControllerExtensionData Conformance
    public var identifier:String?
    public var dataCache:HXCachingWrapper? {
        willSet {
            if let oldCache = dataCache, newValue !== dataCache {
                HXObserverCenter.shared.removeObserver(self, target:oldCache)
            }
        }
        didSet {
            if let newCache = dataCache, oldValue !== dataCache {
                self._startObserving(dataCache:newCache)
            }
        }
    }
    public var cellIdentifier:String?
    public var selectedItem:AnyObject?

    public var callback: ((UIViewController) -> Void)?
    public var successCallback: ((UIViewController) -> Void)?
    public var failureCallback: ((UIViewController) -> Void)?
    public var cancelCallback: ((UIViewController) -> Void)?
    
    // MARK: - HXRepresentation Conformance
    public var representedObject:AnyObject?
    
    // MARK: - HXErrorHandler Conformance
    public var error: Error?
}
