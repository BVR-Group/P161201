//
//  BarView.swift
//  P161201
//
//  Created by Dylan Wreggelsworth on 12/9/16.
//  Copyright © 2016 Dylan Wreggelsworth. All rights reserved.
//
import Foundation
import UIKit

@IBDesignable
public class BarView: UIView {
    @IBInspectable public var valueColor: UIColor = .blue

    @IBInspectable public var percent: Double = 0.0 {
        didSet {
            if oldValue != percent {
                animate(shapeLayer: percentLayer, with: percent)
            }
        }
    }

    var percentPath = UIBezierPath()
    var percentLayer = CAShapeLayer()


    func draw(path: UIBezierPath, on caShapeLayer: CAShapeLayer, with uiColor: UIColor, `for` percent: Double) {
        path.move(to: CGPoint(x: frame.midX, y: frame.maxY))
        path.addLine(to: CGPoint(x: frame.midX, y: frame.maxY - (frame.maxY * CGFloat(percent))))

        caShapeLayer.frame = bounds
        caShapeLayer.path = path.cgPath
        caShapeLayer.strokeColor = uiColor.cgColor
        caShapeLayer.fillColor = nil
        caShapeLayer.lineWidth = layer.contentsScale * layer.bounds.width
        caShapeLayer.lineJoin = kCALineJoinBevel

        layer.addSublayer(caShapeLayer)
    }

    func animate(shapeLayer: CAShapeLayer, with percent: Double) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.125
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.midX, y: frame.maxY))
        path.addLine(to: CGPoint(x: frame.midX, y: frame.maxY - (frame.maxY * CGFloat(percent))))

        animation.toValue = path.cgPath
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false

        shapeLayer.add(animation, forKey: "path")
    }

    func commonInit() {
        if UIScreen.main.scale == 2.0 {
            layer.contentsScale = 2.0
        }
        layer.masksToBounds = true
        draw(path: percentPath, on: percentLayer, with: valueColor, for: percent)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
