//
//  Shape.swift
//  P161201
//
//  Created by Dylan Wreggelsworth on 12/9/16.
//  Copyright © 2016 Dylan Wreggelsworth. All rights reserved.
//

import Foundation
import UIKit

final class Shape: UIView {
    var thickness: CGFloat = 8.0

    init(frame: CGRect, thickness: CGFloat) {
        self.thickness = thickness
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        drawShape(thickness: thickness)
    }

    func drawShape(thickness: CGFloat = 115) {
        //// Color Declarations
        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 1.000)

        //// Variable Declarations
        let size = self.bounds.size
        let rect = CGRect(x: 2 + thickness / 2.0, y: 2 + thickness / 2.0, width: size.width - thickness - 4, height: size.height - thickness - 4)

        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: rect)
        color.setStroke()
        ovalPath.lineWidth = thickness
        ovalPath.stroke()
    }


}
