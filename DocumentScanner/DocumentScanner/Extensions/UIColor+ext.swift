//
//  UIColor+ext.swift
//  DocumentScanner
//
//  Created by Nail Galiev on 04.03.2023.
//

import Foundation
import UIKit

extension UIColor {
    static var tabBarItemAccent: UIColor {
        #colorLiteral(red: 0.05519210547, green: 0.09119886905, blue: 0.1371837854, alpha: 1)
    }
    
    static var backgroundColor: UIColor {
        #colorLiteral(red: 0.03907632828, green: 0.05942071229, blue: 0.1180300489, alpha: 1)
    }
    
    static var buttonColor: UIColor {
        #colorLiteral(red: 0.1651721895, green: 0.592692554, blue: 0.9984150529, alpha: 1)
    }
    
    static var textColor: UIColor {
        #colorLiteral(red: 0.8461729288, green: 0.8511452079, blue: 0.8596647382, alpha: 1)
    }
    
    public convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xff0000) >> 16) / 255
        let g = CGFloat((hex & 0x00ff00) >> 8) / 255
        let b = CGFloat((hex & 0x0000ff)) / 255

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
