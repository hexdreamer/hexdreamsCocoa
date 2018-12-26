// hexdreamsCocoa
// UIViewExtensions.swift
// Copyright © 2018 Kenny Leung
// This code is PUBLIC DOMAIN

import UIKit

public extension UIView {
    
    // https://stackoverflow.com/questions/47053727/how-to-find-your-own-constraint/47053965
    public var hxAllConstraints:[NSLayoutConstraint] {
        // array will contain self and all superviews
        var views = [self]
        
        // get all superviews
        var view = self
        while let superview = view.superview {
            views.append(superview)
            view = superview
        }
        
        // transform views to constraints and filter only those
        // constraints that include the view itself
        return views.flatMap({ $0.constraints }).filter { constraint in
            return constraint.firstItem as? UIView == self ||
                constraint.secondItem as? UIView == self
        }
    }
}

