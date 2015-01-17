//
//  UITextField+LTBouncyPlaceholder.swift
//  LTBouncyPlaceholderDemo
//
//  Created by Lex on 6/9/14.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

var kAbbreviatedPlaceholderPointer: Void?
var kPlaceholderLabelPointer: Void?
var kRightPlaceholderLabelPointer: Void?

let kLTAnimationDuration: CFTimeInterval = 0.6

public class LTBouncyTextField: UITextField {
    
    // MARK: - Override properties
    
    override public var text: String! {
        get {
            return super.text ?? ""
        }
        set {
            if !newValue.isEmpty {
                _movePlaceholder(toRight: true)
            }
            super.text = newValue
        }
    }
    
    // MARK: - Update layout after resizing
    
    override public var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            if !text.isEmpty {
                _movePlaceholder(toRight: true)
            }
        }
    }
    
    override public var bounds: CGRect {
        get {
            return super.bounds
        }
        set {
            super.bounds = newValue
            if !text.isEmpty {
                _movePlaceholder(toRight: true)
            }
        }
    }
    
    // MARK: - Abbreviated Placeholder property

    public var abbreviatedPlaceholder: String? {
    get {
        var _abbreviatedPlaceholderObject: AnyObject? = objc_getAssociatedObject(self, &kAbbreviatedPlaceholderPointer)
        if let _abbreviatedPlaceholder: AnyObject = _abbreviatedPlaceholderObject {
            return _abbreviatedPlaceholder as? String
        }
        return .None
    }
    set {
        lt_rightPlaceholderLabel.text = newValue
        objc_setAssociatedObject(self,
            &kAbbreviatedPlaceholderPointer,
            newValue,
            objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }
    }
    
    private var _widthOfAbbr: Float {
        get {
            let rightPlaceholder: String? = !abbreviatedPlaceholder!.isEmpty ? abbreviatedPlaceholder : placeholder
            
            if let _rightPlaceholder = rightPlaceholder {
                let attributes = [NSFontAttributeName: lt_rightPlaceholderLabel.font]
                var abbrSize = _rightPlaceholder.sizeWithAttributes(attributes)
                return Float(abbrSize.width)
            }
            return 0
        }
    }
    
    // MARK: - UILabels for placeholders

    private var lt_placeholderLabel: UILabel {
    get {
        var _placeholderLabelObject: AnyObject? = objc_getAssociatedObject(self, &kPlaceholderLabelPointer)
        if let _placeholderLabel: AnyObject = _placeholderLabelObject {
            return _placeholderLabel as UILabel
        }
        var _placeholderLabel = UILabel(frame: placeholderRectForBounds(bounds))
        _placeholderLabel.font = font
        _placeholderLabel.text = placeholder
        _placeholderLabel.textColor = UIColor(white: 0.5, alpha: 0.5)
        addSubview(_placeholderLabel)
        objc_setAssociatedObject(self,
            &kPlaceholderLabelPointer,
            _placeholderLabel,
            objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        return _placeholderLabel
    }
    }

    private var lt_rightPlaceholderLabel: UILabel {
    get {
        var _rightPlaceholderLabelObject: AnyObject? = objc_getAssociatedObject(self, &kRightPlaceholderLabelPointer)
        if let _rightPlaceholderLabel: AnyObject = _rightPlaceholderLabelObject {
            return _rightPlaceholderLabel as UILabel
        }
        var _rightPlaceholderLabel = UILabel(frame: placeholderRectForBounds(bounds))
        _rightPlaceholderLabel.font = font
        _rightPlaceholderLabel.textColor = UIColor(white: 0.5, alpha: 0.5)
        _rightPlaceholderLabel.layer.opacity = 0.0
        addSubview(_rightPlaceholderLabel)
        objc_setAssociatedObject(self,
            &kRightPlaceholderLabelPointer,
            _rightPlaceholderLabel,
            objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        return _rightPlaceholderLabel
    }
    }
    
    // MARK: - Omit default drawing function

    override public func drawPlaceholderInRect(rect: CGRect) { }

    override public func willMoveToSuperview(newSuperview: UIView!) {
        if nil != newSuperview {
            
            lt_placeholderLabel.setNeedsDisplay()
            
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: Selector("_didChange:"),
                name: UITextFieldTextDidChangeNotification,
                object: nil)
        } else {
            NSNotificationCenter.defaultCenter().removeObserver(self,
                name: UITextFieldTextDidChangeNotification,
                object: nil)
        }
    }
    
    // MARK: - Text change notification

    func _didChange (notification: NSNotification) {
        if notification.object === self {
            if text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                _animatePlaceholder(toRight: true)
            } else {
                _animatePlaceholder(toRight: false)
            }
        }
    }
    
    // MARK: - Animations

    private func _bounceKeyframes(#toRight: Bool) -> NSArray {
        let steps = 100
        var values = [Double]()
        var value: Double
        let e = 3.5
        let distance = Float(placeholderRectForBounds(bounds).size.width) - _widthOfAbbr
        for t in 0 ..< steps {
            value = Double(distance)
                * (toRight ? -1 : 1)
                * Double(pow(e, -0.055 * Double(t)))
                * Double(cos(0.12 * Double(t)))
                + (toRight ? Double(distance) : 0)
            values.append(value)
        }
        return values
    }
    
    private func _movePlaceholder (#toRight: Bool) {
        if toRight {
            lt_rightPlaceholderLabel.layer.opacity = 1
            lt_rightPlaceholderLabel.layer.position.x = placeholderRectForBounds(bounds).size.width - CGFloat(_widthOfAbbr)
            lt_placeholderLabel.layer.opacity = 0
            lt_placeholderLabel.layer.position.x = placeholderRectForBounds(bounds).size.width - CGFloat(_widthOfAbbr)
        } else {
            lt_rightPlaceholderLabel.layer.opacity = 0
            lt_rightPlaceholderLabel.layer.position.x = 0
            lt_placeholderLabel.layer.opacity = 1
            lt_placeholderLabel.layer.position.x = 0
        }
    }

    private func _animatePlaceholder (#toRight: Bool) {
        if let abbrPlaceholder = abbreviatedPlaceholder {
            if (toRight) {
                if lt_rightPlaceholderLabel.layer.presentationLayer().opacity > 0 {
                    return
                }
                
                lt_placeholderLabel.layer.removeAllAnimations()
                lt_rightPlaceholderLabel.layer.removeAllAnimations()
                
                let bounceToRight = CAKeyframeAnimation(keyPath: "position.x")
                bounceToRight.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                bounceToRight.duration = kLTAnimationDuration
                bounceToRight.values = _bounceKeyframes(toRight: true)
                bounceToRight.fillMode = kCAFillModeForwards
                bounceToRight.additive = true
                bounceToRight.removedOnCompletion = false
                
                let fadeOut = CABasicAnimation(keyPath: "opacity")
                fadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                fadeOut.fromValue = 1
                fadeOut.toValue = 0
                fadeOut.duration = kLTAnimationDuration / 3
                fadeOut.fillMode = kCAFillModeBoth
                fadeOut.removedOnCompletion = false
                lt_placeholderLabel.layer.addAnimation(bounceToRight, forKey: "bounceToRight")
                lt_placeholderLabel.layer.addAnimation(fadeOut, forKey: "fadeOut")
                
                let fadeIn = CABasicAnimation(keyPath: "opacity")
                fadeIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                fadeIn.fromValue = 0
                fadeIn.toValue = 1
                fadeIn.duration = kLTAnimationDuration / 3
                fadeIn.fillMode = kCAFillModeForwards
                fadeIn.removedOnCompletion = false
                
                lt_rightPlaceholderLabel.layer.addAnimation(bounceToRight, forKey: "bounceToRight")
                lt_rightPlaceholderLabel.layer.addAnimation(fadeIn, forKey: "fadeIn")
            } else {
                lt_placeholderLabel.layer.removeAllAnimations()
                lt_rightPlaceholderLabel.layer.removeAllAnimations()
                
                let bounceToLeft = CAKeyframeAnimation(keyPath: "position.x")
                bounceToLeft.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                bounceToLeft.duration = kLTAnimationDuration
                bounceToLeft.values = _bounceKeyframes(toRight: false)
                bounceToLeft.fillMode = kCAFillModeForwards
                bounceToLeft.additive = true
                bounceToLeft.removedOnCompletion = false
                
                let fadeIn = CABasicAnimation(keyPath: "opacity")
                fadeIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                fadeIn.duration = kLTAnimationDuration / 3
                fadeIn.fillMode = kCAFillModeForwards
                fadeIn.fromValue = 0
                fadeIn.toValue = 1
                fadeIn.removedOnCompletion = false
                lt_placeholderLabel.layer.addAnimation(fadeIn, forKey: "fadeIn")
                lt_placeholderLabel.layer.addAnimation(bounceToLeft, forKey: "bounceToLeft")
                
                let fadeOut = CABasicAnimation(keyPath: "opacity")
                fadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                fadeOut.duration = kLTAnimationDuration / 3
                fadeOut.fillMode = kCAFillModeForwards
                fadeOut.fromValue = 1
                fadeOut.toValue = 0
                fadeOut.removedOnCompletion = false
                lt_rightPlaceholderLabel.layer.addAnimation(fadeOut, forKey: "fadeOut")
                lt_rightPlaceholderLabel.layer.addAnimation(bounceToLeft, forKey: "bounceToLeft")
            }
        } else {
            lt_placeholderLabel.layer.removeAllAnimations()
            if toRight {
                let bounceToRight = CAKeyframeAnimation(keyPath: "position.x")
                bounceToRight.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                bounceToRight.duration = kLTAnimationDuration
                bounceToRight.values = _bounceKeyframes(toRight: true)
                bounceToRight.fillMode = kCAFillModeForwards
                bounceToRight.additive = true
                bounceToRight.removedOnCompletion = false
                lt_placeholderLabel.layer.addAnimation(bounceToRight, forKey: "bounceToRight")
            } else {
                let bounceToLeft = CAKeyframeAnimation(keyPath: "position.x")
                bounceToLeft.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                bounceToLeft.duration = kLTAnimationDuration
                bounceToLeft.values = _bounceKeyframes(toRight: false)
                bounceToLeft.fillMode = kCAFillModeForwards
                bounceToLeft.additive = true
                bounceToLeft.removedOnCompletion = false
                lt_placeholderLabel.layer.addAnimation(bounceToLeft, forKey: "bounceToLeft")
            }
        }
        
    }
}