/*
 * The MIT License (MIT)
 *
 * Copyright (C) 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Original Inspiration & Author
 * Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

public class MotionAnimation {
    /// A reference to the callback that applies the MotionAnimationState.
    internal let apply: (inout MotionAnimationState) -> Void
    
    /**
     An initializer that accepts a given callback.
     - Parameter applyFunction: A given callback.
     */
    public init(applyFunction: @escaping (inout MotionAnimationState) -> Void) {
        apply = applyFunction
    }
}

extension MotionAnimation {
    /**
     Animates the view's current background color to the
     given color.
     - Parameter color: A UIColor.
     - Returns: A MotionAnimation.
     */
    public static func background(color: UIColor) -> MotionAnimation {
        return MotionAnimation {
            $0.backgroundColor = color.cgColor
        }
    }
    
    /**
     Animates the view's current border color to the
     given color.
     - Parameter color: A UIColor.
     - Returns: A MotionAnimation.
     */
    public static func border(color: UIColor) -> MotionAnimation {
        return MotionAnimation {
            $0.borderColor = color.cgColor
        }
    }
    
    /**
     Animates the view's current border width to the
     given width.
     - Parameter width: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func border(width: CGFloat) -> MotionAnimation {
        return MotionAnimation {
            $0.borderWidth = width
        }
    }
    
    /**
     Animates the view's current corner radius to the
     given radius.
     - Parameter radius: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func corner(radius: CGFloat) -> MotionAnimation {
        return MotionAnimation {
            $0.cornerRadius = radius
        }
    }
    
    /**
     Animates the view's current transform (perspective, scale, rotate)
     to the given one.
     - Parameter _ transform: A CATransform3D.
     - Returns: A MotionAnimation.
     */
    public static func transform(_ transform: CATransform3D) -> MotionAnimation {
        return MotionAnimation {
            $0.transform = transform
        }
    }
    
    /**
     Animates the view's current perspective to the gievn one through
     a CATransform3D object.
     - Parameter _ perspective: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func perspective(_ perspective: CGFloat) -> MotionAnimation {
        return MotionAnimation {
            var t = $0.transform ?? CATransform3DIdentity
            t.m34 = 1 / -perspective
            $0.transform = t
        }
    }
    
    /**
     Animates the view's current rotate to the given x, y,
     and z values.
     - Parameter x: A CGFloat.
     - Parameter y: A CGFloat.
     - Parameter z: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func rotate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> MotionAnimation {
        return MotionAnimation {
            var t = $0.transform ?? CATransform3DIdentity
            t = CATransform3DRotate(t, CGFloat(Double.pi) * x / 180, 1, 0, 0)
            t = CATransform3DRotate(t, CGFloat(Double.pi) * y / 180, 0, 1, 0)
            $0.transform = CATransform3DRotate(t, CGFloat(Double.pi) * z / 180, 0, 0, 1)
        }
    }
    
    /**
     Animates the view's current rotate to the given point.
     - Parameter _ point: A CGPoint.
     - Parameter z: A CGFloat, default is 0.
     - Returns: A MotionAnimation.
     */
    public static func rotate(_ point: CGPoint, z: CGFloat = 0) -> MotionAnimation {
        return .rotate(x: point.x, y: point.y, z: z)
    }
    
    /**
     Rotate 2d.
     - Parameter _ z: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func rotate(_ z: CGFloat) -> MotionAnimation {
        return .rotate(z: z)
    }
    
    /**
     Animates the view's current spin to the given x, y,
     and z values.
     - Parameter x: A CGFloat.
     - Parameter y: A CGFloat.
     - Parameter z: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func spin(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> MotionAnimation {
        return MotionAnimation {
            $0.spin = (x, y, z)
        }
    }
    
    /**
     Animates the view's current spin to the given point.
     - Parameter _ point: A CGPoint.
     - Parameter z: A CGFloat, default is 0.
     - Returns: A MotionAnimation.
     */
    public static func spin(_ point: CGPoint, z: CGFloat = 0) -> MotionAnimation {
        return .spin(x: point.x, y: point.y, z: z)
    }
    
    /**
     Spin 2d.
     - Parameter _ z: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func spin(_ z: CGFloat) -> MotionAnimation {
        return .spin(z: z)
    }
    
    /**
     Animates the view's current scale to the given x, y, z scale values.
     - Parameter x: A CGFloat.
     - Parameter y: A CGFloat.
     - Parameter z: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func scale(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) -> MotionAnimation {
        return MotionAnimation {
            $0.transform = CATransform3DScale($0.transform ?? CATransform3DIdentity, x, y, z)
        }
    }
    
    /**
     Animates the view's current x & y scale to the given scale value.
     - Parameter _ xy: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func scale(_ xy: CGFloat) -> MotionAnimation {
        return .scale(x: xy, y: xy)
    }
    
    /**
     Animates the view's current translation to the given
     x, y, and z values.
     - Parameter x: A CGFloat.
     - Parameter y: A CGFloat.
     - Parameter z: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func translate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> MotionAnimation {
        return MotionAnimation {
            $0.transform = CATransform3DTranslate($0.transform ?? CATransform3DIdentity, x, y, z)
        }
    }
    
    /**
     Animates the view's current translation to the given
     point value (x & y), and a z value.
     - Parameter _ point: A CGPoint.
     - Parameter z: A CGFloat, default is 0.
     - Returns: A MotionAnimation.
     */
    public static func translate(_ point: CGPoint, z: CGFloat = 0) -> MotionAnimation {
        return .translate(x: point.x, y: point.y, z: z)
    }
    
    /**
     Animates the view's current position to the given point.
     - Parameter _ point: A CGPoint.
     - Returns: A MotionAnimation.
     */
    public static func position(_ point: CGPoint) -> MotionAnimation {
        return MotionAnimation {
            $0.position = point
        }
    }
    
    /// Fades the view in during an animation.
    public static var fadeIn = MotionAnimation.fade(1)
    
    /// Fades the view out during an animation.
    public static var fadeOut = MotionAnimation.fade(0)
    
    /**
     Animates the view's current opacity to the given one.
     - Parameter _ opacity: A Double.
     - Returns: A MotionAnimation.
     */
    public static func fade(_ opacity: Double) -> MotionAnimation {
        return MotionAnimation {
            $0.opacity = opacity
        }
    }
    
    /**
     Animates the view's current zPosition to the given position.
     - Parameter _ position: An Int.
     - Returns: A MotionAnimation.
     */
    public static func zPosition(_ position: CGFloat) -> MotionAnimation {
        return MotionAnimation {
            $0.zPosition = position
        }
    }
    
    /**
     Animates the view's current size to the given one.
     - Parameter _ size: A CGSize.
     - Returns: A MotionAnimation.
     */
    public static func size(_ size: CGSize) -> MotionAnimation {
        return MotionAnimation {
            $0.size = size
        }
    }
    
    /**
     Animates the view's current shadow path to the given one.
     - Parameter path: A CGPath.
     - Returns: A MotionAnimation.
     */
    public static func shadow(path: CGPath) -> MotionAnimation {
        return MotionAnimation {
            $0.shadowPath = path
        }
    }
    
    /**
     Animates the view's current shadow color to the given one.
     - Parameter color: A UIColor.
     - Returns: A MotionAnimation.
     */
    public static func shadow(color: UIColor) -> MotionAnimation {
        return MotionAnimation {
            $0.shadowColor = color.cgColor
        }
    }
    
    /**
     Animates the view's current shadow offset to the given one.
     - Parameter offset: A CGSize.
     - Returns: A MotionAnimation.
     */
    public static func shadow(offset: CGSize) -> MotionAnimation {
        return MotionAnimation {
            $0.shadowOffset = offset
        }
    }
    
    /**
     Animates the view's current shadow opacity to the given one.
     - Parameter opacity: A Float.
     - Returns: A MotionAnimation.
     */
    public static func shadow(opacity: Float) -> MotionAnimation {
        return MotionAnimation {
            $0.shadowOpacity = opacity
        }
    }
    
    /**
     Animates the view's current shadow radius to the given one.
     - Parameter radius: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func shadow(radius: CGFloat) -> MotionAnimation {
        return MotionAnimation {
            $0.shadowRadius = radius
        }
    }
    
    /**
     Animates the views shadow offset, opacity, and radius. 
     - Parameter offset: A CGSize. 
     - Parameter opacity: A Float.
     - Parameter radius: A CGFloat.
     */
    public static func depth(offset: CGSize, opacity: Float, radius: CGFloat) -> MotionAnimation {
        return MotionAnimation {
            $0.shadowOffset = offset
            $0.shadowOpacity = opacity
            $0.shadowRadius = radius
        }
    }
    
    /**
     Animates the views shadow offset, opacity, and radius.
     - Parameter _ depth: A tuple (CGSize, FLoat, CGFloat).
     */
    public static func depth(_ depth: (CGSize, Float, CGFloat)) -> MotionAnimation {
        return .depth(offset: depth.0, opacity: depth.1, radius: depth.2)
    }
    
    /**
     Animates the view's contents rect to the given one.
     - Parameter rect: A CGRect.
     - Returns: A MotionAnimation.
     */
    public static func contents(rect: CGRect) -> MotionAnimation {
        return MotionAnimation {
            $0.contentsRect = rect
        }
    }
    
    /**
     Animates the view's contents scale to the given one.
     - Parameter scale: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func contents(scale: CGFloat) -> MotionAnimation {
        return MotionAnimation {
            $0.contentsScale = scale
        }
    }
    
    /**
     The duration of the view's animation.
     - Parameter _ duration: A TimeInterval.
     - Returns: A MotionAnimation.
     */
    public static func duration(_ duration: TimeInterval) -> MotionAnimation {
        return MotionAnimation {
            $0.duration = duration
        }
    }
    
    /**
     Sets the view's animation duration to the longest
     running animation.
     */
    public static var preferredDurationMatchesLongest = MotionAnimation.duration(.infinity)
    
    /**
     Delays the animation of a given view.
     - Parameter _ time: TimeInterval.
     - Returns: A MotionAnimation.
     */
    public static func delay(_ time: TimeInterval) -> MotionAnimation {
        return MotionAnimation {
            $0.delay = time
        }
    }
    
    /**
     Sets the view's timing function for the animation.
     - Parameter _ timingFunction: A CAMediaTimingFunction.
     - Returns: A MotionAnimation.
     */
    public static func timingFunction(_ timingFunction: CAMediaTimingFunction) -> MotionAnimation {
        return MotionAnimation {
            $0.timingFunction = timingFunction
        }
    }
    
    /**
     Available in iOS 9+, animates a view using the spring API,
     given a stiffness and damping.
     - Parameter stiffness: A CGFlloat.
     - Parameter damping: A CGFloat.
     - Returns: A MotionAnimation.
     */
    @available(iOS 9, *)
    public static func spring(stiffness: CGFloat, damping: CGFloat) -> MotionAnimation {
        return MotionAnimation {
            $0.spring = (stiffness, damping)
        }
    }
    
    /**
     Animates the natural curve of a view. A value of 1 represents
     a curve in a downward direction, and a value of -1
     represents a curve in an upward direction.
     - Parameter intensity: A CGFloat.
     - Returns: A MotionAnimation.
     */
    public static func arc(intensity: CGFloat = 1) -> MotionAnimation {
        return MotionAnimation {
            $0.arc = intensity
        }
    }
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
        let a = CABasicAnimation(keyPath: .backgroundColor)
        a.toValue = color.cgColor
        return a
    }
    
    /**
     Creates a CABasicAnimation for the barTintColor key path.
     - Parameter color: A UIColor.
     - Returns: A CABasicAnimation.
     */
    public static func barTint(color: UIColor) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .barTintColor)
        a.toValue = color.cgColor
        return a
    }
    
    /**
     Creates a CABasicAnimation for the borderColor key path.
     - Parameter color: A UIColor.
     - Returns: A CABasicAnimation.
     */
    public static func border(color: UIColor) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .borderColor)
        a.toValue = color.cgColor
        return a
    }
    
    /**
     Creates a CABasicAnimation for the borderWidth key path.
     - Parameter width: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func border(width: CGFloat) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .borderWidth)
        a.toValue = NSNumber(floatLiteral: Double(width))
        return a
    }
    
    /**
     Creates a CABasicAnimation for the cornerRadius key path.
     - Parameter radius: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func corner(radius: CGFloat) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .cornerRadius)
        a.toValue = NSNumber(floatLiteral: Double(radius))
        return a
    }
    
    /**
     Creates a CABasicAnimation for the transform key path.
     - Parameter _ t: A CATransform3D object.
     - Returns: A CABasicAnimation.
     */
    public static func transform(_ t: CATransform3D) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .transform)
        a.toValue = NSValue(caTransform3D: t)
        return a
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.x key path.
     - Parameter _ rotations: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func spinX(_ rotations: CGFloat) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .rotateX)
        a.toValue = NSNumber(value: Double(CGFloat(Double.pi) * 2 * rotations))
        return a
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.y key path.
     - Parameter _ rotations: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func spinY(_ rotations: CGFloat) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .rotateY)
        a.toValue = NSNumber(value: Double(CGFloat(Double.pi) * 2 * rotations))
        return a
    }
    
    /**
     Creates a CABasicAnimation for the transform.rotate.z key path.
     - Parameter _ rotations: An optional CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func spinZ(_ rotations: CGFloat) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .rotateZ)
        a.toValue = NSNumber(value: Double(CGFloat(Double.pi) * 2 * rotations))
        return a
    }
    
    /**
     Creates a CABasicAnimation for the position key path.
     - Parameter _ point: A CGPoint.
     - Returns: A CABasicAnimation.
     */
    public static func position(_ point: CGPoint) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .position)
        a.toValue = NSValue(cgPoint: point)
        return a
    }
    
    /**
     Creates a CABasicAnimation for the opacity key path.
     - Parameter _ opacity: A Double.
     - Returns: A CABasicAnimation.
     */
    public static func fade(_ opacity: Double) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .opacity)
        a.toValue = NSNumber(floatLiteral: opacity)
        return a
    }
    
    /**
     Creates a CABasicaAnimation for the zPosition key path.
     - Parameter _ position: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func zPosition(_ position: CGFloat) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .zPosition)
        a.toValue = NSNumber(value: Double(position))
        return a
    }
    
    /**
     Creates a CABasicaAnimation for the width key path.
     - Parameter width: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func width(_ width: CGFloat) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .width)
        a.toValue = NSNumber(floatLiteral: Double(width))
        return a
    }
    
    /**
     Creates a CABasicaAnimation for the height key path.
     - Parameter height: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func height(_ height: CGFloat) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .height)
        a.toValue = NSNumber(floatLiteral: Double(height))
        return a
    }
    
    /**
     Creates a CABasicaAnimation for the height key path.
     - Parameter size: A CGSize.
     - Returns: A CABasicAnimation.
     */
    public static func size(_ size: CGSize) -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: .size)
        a.toValue = NSValue(cgSize: size)
        return a
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
     - Parameter offset: A CGSize.
     - Returns: A CABasicAnimation.
     */
    public static func shadow(offset: CGSize) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .shadowOffset)
        animation.toValue = NSValue(cgSize: offset)
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the shadowOpacity key path.
     - Parameter opacity: A Float.
     - Returns: A CABasicAnimation.
     */
    public static func shadow(opacity: Float) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .shadowOpacity)
        animation.toValue = NSNumber(floatLiteral: Double(opacity))
        return animation
    }
    
    /**
     Creates a CABasicAnimation for the shadowRadius key path.
     - Parameter radius: A CGFloat.
     - Returns: A CABasicAnimation.
     */
    public static func shadow(radius: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: .shadowRadius)
        animation.toValue = NSNumber(floatLiteral: Double(radius))
        return animation
    }
}
