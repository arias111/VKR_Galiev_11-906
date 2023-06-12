//
//  UIView+ext.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 08.03.2023.
//

import Foundation
import UIKit

extension UIView {
    func addSubviews(views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
}

extension UIStackView {
    func addArrangedSubviews(_ subviews: UIView...) {
        addArrangedSubviews(subviews)
    }
    
    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach(addArrangedSubview)
    }
}

public extension NSObject {
    
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
    
}

extension UITableView {
    
    func register<T: UITableViewCell>(forType type: T.Type) {
        register(T.self, forCellReuseIdentifier: T.className)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.className, for: indexPath) as! T
    }
}
