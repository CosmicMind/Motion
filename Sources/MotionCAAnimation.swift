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

public enum MotionAnimationKeyPath: String {
    case backgroundColor
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

public struct MotionCAAnimation {}

fileprivate extension MotionCAAnimation {
    /**
     Creates a CABasicAnimation.
     - Parameter keyPath: A MotionAnimationKeyPath.
     - Parameter toValue: An Any value that is the end state of the animation.
     */
    static func createAnimation(keyPath: MotionAnimationKeyPath, toValue: Any) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: keyPath)
        a.toValue = toValue
        return a
    }
}

@available(iOS 9.0, *)
internal extension MotionCAAnimation {
    /**
     Converts a CABasicAnimation to a CASpringAnimation.
     - Parameter animation: A CABasicAnimation.
     - Parameter stiffness: A CGFloat.
     - Parameter damping: A CGFloat.
     */
    static func convert(animation: CABasicAnimation, stiffness: CGFloat, damping: CGFloat) -> CASpringAnimation {
        let a = CASpringAnimation(keyPath: animation.keyPath)
        a.fromValue = animation.fromValue
        a.toValue = animation.toValue
        a.stiffness = stiffness
        a.damping = damping
        return a
    }
}

public extension MotionCAAnimation {
    /**
     Creates a CABasicAnimation for the backgroundColor key path.
     - Parameter color: A UIColor.
     - Returns: A CABasicAnimation.
     */
    static func background(color: UIColor) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .backgroundColor, toValue: color.cgColor)
    }
    
    /**
     Creates a CABasicAnimation for the borderColor key path.
     - Parameter color: A UIColor.
     - Returns: A CABasicAnimation.
     */
    static func border(color: UIColor) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .borderColor, toValue: color.cgColor)
    }
    
    /**
     Creates a CABasicAnimation for the borderWidth key path.
     - Parameter width: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    static func border(width: CGFloat) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .borderWidth, toValue: NSNumber(floatLiteral: Double(width)))
    }
    
    /**
     Creates a CABasicAnimation for the cornerRadius key path.
     - Parameter radius: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    static func corner(radius: CGFloat) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .cornerRadius, toValue: NSNumber(floatLiteral: Double(radius)))
    }
    
    /**
     Creates a CABasicAnimation for the transform key path.
     - Parameter _ t: A CATransform3D object.
     - Returns: A CABasicAnimation.
     */
    static func transform(_ t: CATransform3D) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .transform, toValue: NSValue(caTransform3D: t))
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.x key path.
     - Parameter _ rotations: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    static func spinX(_ rotations: CGFloat) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .rotateX, toValue: NSNumber(value: Double(CGFloat(Double.pi) * 2 * rotations)))
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.y key path.
     - Parameter _ rotations: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    static func spinY(_ rotations: CGFloat) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .rotateY, toValue: NSNumber(value: Double(CGFloat(Double.pi) * 2 * rotations)))
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.z key path.
     - Parameter _ rotations: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    static func spinZ(_ rotations: CGFloat) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .rotateZ, toValue: NSNumber(value: Double(CGFloat(Double.pi) * 2 * rotations)))
    }
    
    /**
     Creates a CABasicAnimation for the position key path.
     - Parameter _ point: A CGPoint.
     - Returns: A CABasicAnimation.
     */
    static func position(_ point: CGPoint) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .position, toValue: NSValue(cgPoint: point))
    }
    
    /**
     Creates a CABasicAnimation for the opacity key path.
     - Parameter _ opacity: A Double.
     - Returns: A CABasicAnimation.
     */
    static func fade(_ opacity: Double) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .opacity, toValue: NSNumber(floatLiteral: opacity))
    }
    
    /**
     Creates a CABasicaAnimation for the zPosition key path.
     - Parameter _ position: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    static func zPosition(_ position: CGFloat) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .zPosition, toValue: NSNumber(value: Double(position)))
    }
    
    /**
     Creates a CABasicaAnimation for the width key path.
     - Parameter width: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    static func width(_ width: CGFloat) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .width, toValue: NSNumber(floatLiteral: Double(width)))
    }
    
    /**
     Creates a CABasicaAnimation for the height key path.
     - Parameter height: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    static func height(_ height: CGFloat) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .height, toValue: NSNumber(floatLiteral: Double(height)))
    }
    
    /**
     Creates a CABasicaAnimation for the height key path.
     - Parameter size: A CGSize.
     - Returns: A CABasicAnimation.
     */
    static func size(_ size: CGSize) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .size, toValue: NSValue(cgSize: size))
    }
    
    /**
     Creates a CABasicAnimation for the shadowPath key path.
     - Parameter path: A CGPath.
     - Returns: A CABasicAnimation.
     */
    static func shadow(path: CGPath) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .shadowPath, toValue: path)
    }
    
    /**
     Creates a CABasicAnimation for the shadowColor key path.
     - Parameter color: A UIColor.
     - Returns: A CABasicAnimation.
     */
    static func shadow(color: UIColor) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .shadowColor, toValue: color.cgColor)
    }
    
    /**
     Creates a CABasicAnimation for the shadowOffset key path.
     - Parameter offset: A CGSize.
     - Returns: A CABasicAnimation.
     */
    static func shadow(offset: CGSize) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .shadowOffset, toValue: NSValue(cgSize: offset))
    }
    
    /**
     Creates a CABasicAnimation for the shadowOpacity key path.
     - Parameter opacity: A Float.
     - Returns: A CABasicAnimation.
     */
    static func shadow(opacity: Float) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .shadowOpacity, toValue: NSNumber(floatLiteral: Double(opacity)))
    }
    
    /**
     Creates a CABasicAnimation for the shadowRadius key path.
     - Parameter radius: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    static func shadow(radius: CGFloat) -> CABasicAnimation {
        return MotionCAAnimation.createAnimation(keyPath: .shadowRadius, toValue: NSNumber(floatLiteral: Double(radius)))
    }
}
