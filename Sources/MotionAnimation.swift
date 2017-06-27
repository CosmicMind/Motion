/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

public enum MotionAnimation {
    case delay(TimeInterval)
    case timingFunction(CAMediaTimingFunctionType)
    case duration(TimeInterval)
    case custom(CABasicAnimation)
    case backgroundColor(UIColor)
    case barTintColor(UIColor)
    case borderColor(UIColor)
    case borderWidth(CGFloat)
    case cornerRadius(CGFloat)
    case transform(CATransform3D)
    case rotate(CGFloat)
    case rotateX(CGFloat)
    case rotateY(CGFloat)
    case rotateZ(CGFloat)
    case spin(CGFloat)
    case spinX(CGFloat)
    case spinY(CGFloat)
    case spinZ(CGFloat)
    case scale(CGFloat)
    case scaleX(CGFloat)
    case scaleY(CGFloat)
    case scaleZ(CGFloat)
    case translate(x: CGFloat, y: CGFloat)
    case translateX(CGFloat)
    case translateY(CGFloat)
    case translateZ(CGFloat)
    case x(CGFloat)
    case y(CGFloat)
    case point(x: CGFloat, y: CGFloat)
    case position(x: CGFloat, y: CGFloat)
    case fade(Double)
    case zPosition(CGFloat)
    case width(CGFloat)
    case height(CGFloat)
    case size(width: CGFloat, height: CGFloat)
    case shadowPath(CGPath)
    case shadowColor(UIColor)
    case shadowOffset(CGSize)
    case shadowOpacity(Float)
    case shadowRadius(CGFloat)
    case depth(shadowOffset: CGSize, shadowOpacity: Float, shadowRadius: CGFloat)
}

public enum MotionAnimationKeyPath: String {
    case backgroundColor
    case barTintColor
    case borderColor
    case borderWidth
    case cornerRadius
    case transform
    case rotate  = "transform.rotation"
    case rotateX = "transform.rotation.x"
    case rotateY = "transform.rotation.y"
    case rotateZ = "transform.rotation.z"
    case scale  = "transform.scale"
    case scaleX = "transform.scale.x"
    case scaleY = "transform.scale.y"
    case scaleZ = "transform.scale.z"
    case translation  = "transform.translation"
    case translationX = "transform.translation.x"
    case translationY = "transform.translation.y"
    case translationZ = "transform.translation.z"
    case position
    case opacity
    case zPosition
    case width = "bounds.size.width"
    case height = "bounds.size.height"
    case size = "bounds.size"
    case shadowPath
    case shadowColor
    case shadowOffset
    case shadowOpacity
    case shadowRadius
}

extension CABasicAnimation {
    /**
     A convenience initializer that takes a given MotionAnimationKeyPath.
     - Parameter keyPath: An MotionAnimationKeyPath.
     */
    public convenience init(keyPath: MotionAnimationKeyPath) {
        self.init(keyPath: keyPath.rawValue)
    }
}

public struct MotionBasicAnimation {
    /**
     Creates a CABasicAnimation for the backgroundColor key path.
     - Parameter color: A UIColor.
     - Returns: A CABasicAnimation.
     */
    public static func background(color: UIColor) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .backgroundColor)
        animation.toValue = color.cgColor
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the barTintColor key path.
     - Parameter color: A UIColor.
     - Returns: A CABasicAnimation.
     */
    public static func barTint(color: UIColor) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .barTintColor)
        animation.toValue = color.cgColor
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the borderColor key path.
     - Parameter color: A UIColor.
     - Returns: A CABasicAnimation.
     */
    public static func border(color: UIColor) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .borderColor)
        animation.toValue = color.cgColor
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the borderWidth key path.
     - Parameter width: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func border(width: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .borderWidth)
        animation.toValue = width
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the cornerRadius key path.
     - Parameter radius: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func corner(radius: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .cornerRadius)
        animation.toValue = radius
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform key path.
     - Parameter transform: A CATransform3D object.
     - Returns: A CABasicAnimation.
     */
    public static func transform(transform: CATransform3D) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .transform)
        animation.toValue = NSValue(caTransform3D: transform)
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate key path.
     - Parameter angle: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func rotate(angle: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .rotate)
        animation.toValue = NSNumber(value: Double(CGFloat(Double.pi) * angle / 180))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.x key path.
     - Parameter angle: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func rotateX(angle: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .rotateX)
        animation.toValue = NSNumber(value: Double(CGFloat(Double.pi) * angle / 180))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.y key path.
     - Parameter angle: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func rotateY(angle: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .rotateY)
        animation.toValue = NSNumber(value: Double(CGFloat(Double.pi) * angle / 180))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.z key path.
     - Parameter angle: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func rotateZ(angle: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .rotateZ)
        animation.toValue = NSNumber(value: Double(CGFloat(Double.pi) * angle / 180))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate key path.
     - Parameter rotates: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func spin(rotates: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .rotate)
        animation.toValue = NSNumber(value: Double(CGFloat(Double.pi) * 2 * rotates))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.x key path.
     - Parameter rotates: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func spinX(rotates: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .rotateX)
        animation.toValue = NSNumber(value: Double(CGFloat(Double.pi) * 2 * rotates))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.y key path.
     - Parameter rotates: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func spinY(rotates: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .rotateY)
        animation.toValue = NSNumber(value: Double(CGFloat(Double.pi) * 2 * rotates))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.z key path.
     - Parameter rotates: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func spinZ(rotates: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .rotateZ)
        animation.toValue = NSNumber(value: Double(CGFloat(Double.pi) * 2 * rotates))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.scale key path.
     - Parameter to scale: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func scale(to scale: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .scale)
        animation.toValue = NSNumber(value: Double(scale))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.scale.x key path.
     - Parameter to scale: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func scaleX(to scale: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .scaleX)
        animation.toValue = NSNumber(value: Double(scale))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.scale.y key path.
     - Parameter to scale: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func scaleY(to scale: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .scaleY)
        animation.toValue = NSNumber(value: Double(scale))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.scale.z key path.
     - Parameter to scale: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func scaleZ(to scale: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .scaleZ)
        animation.toValue = NSNumber(value: Double(scale))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.translation key path.
     - Parameter point: A CGPoint.
     - Returns: A CABasicAnimation.
     */
    public static func translate(to point: CGPoint) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .translation)
        animation.toValue = NSValue(cgPoint: point)
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.translation.x key path.
     - Parameter to translation: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func translateX(to translation: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .translationX)
        animation.toValue = NSNumber(value: Double(translation))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.translation.y key path.
     - Parameter to translation: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func translateY(to translation: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .translationY)
        animation.toValue = NSNumber(value: Double(translation))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the transform.translation.z key path.
     - Parameter to translation: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func translateZ(to translation: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .translationZ)
        animation.toValue = NSNumber(value: Double(translation))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the position key path.
     - Parameter x: A CGFloat.
     - Parameter y: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func position(x: CGFloat, y: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .position)
        animation.toValue = NSValue(cgPoint: CGPoint(x: x, y: y))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the position key path.
     - Parameter to point: A CGPoint.
     - Returns: A CABasicAnimation.
     */
    public static func position(to point: CGPoint) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .position)
        animation.toValue = NSValue(cgPoint: point)
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the opacity key path.
     - Parameter to opacity: A Double.
     - Returns: A CABasicAnimation.
     */
    public static func fade(to opacity: Double) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .opacity)
        animation.toValue = NSNumber(floatLiteral: opacity)
        return animation
    }
    
    /**
     Creates a CABasicaAnimation for the zPosition key path.
     - Parameter _ position: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func zPosition(_ position: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .zPosition)
        animation.toValue = NSNumber(value: Double(position))
        return animation
    }
    
    /**
     Creates a CABasicaAnimation for the width key path.
     - Parameter width: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func width(_ width: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .width)
        animation.toValue = NSNumber(floatLiteral: Double(width))
        return animation
    }
    
    /**
     Creates a CABasicaAnimation for the height key path.
     - Parameter height: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func height(_ height: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .height)
        animation.toValue = NSNumber(floatLiteral: Double(height))
        return animation
    }
    
    /**
     Creates a CABasicaAnimation for the height key path.
     - Parameter size: A CGSize.
     - Returns: A CABasicAnimation.
     */
    public static func size(_ size: CGSize) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .size)
        animation.toValue = NSValue(cgSize: size)
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the shadowPath key path.
     - Parameter path: A CGPath.
     - Returns: A CABasicAnimation.
     */
    public static func shadow(path: CGPath) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .shadowPath)
        animation.toValue = path
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the shadowColor key path.
     - Parameter color: A UIColor.
     - Returns: A CABasicAnimation.
     */
    public static func shadow(color: UIColor) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .shadowColor)
        animation.toValue = color.cgColor
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the shadowOffset key path.
     - Parameter offset: CGSize.
     - Returns: A CABasicAnimation.
     */
    public static func shadow(offset: CGSize) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .shadowOffset)
        animation.toValue = NSValue(cgSize: offset)
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the shadowOpacity key path.
     - Parameter opacity: Float.
     - Returns: A CABasicAnimation.
     */
    public static func shadow(opacity: Float) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .shadowOpacity)
        animation.toValue = NSNumber(floatLiteral: Double(opacity))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the shadowRadius key path.
     - Parameter radius: CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func shadow(radius: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .shadowRadius)
        animation.toValue = NSNumber(floatLiteral: Double(radius))
        return animation
    }
}
