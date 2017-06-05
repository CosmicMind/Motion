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

public extension UIView {
  private struct AssociatedKeys {
    static var motionID    = "motionID"
    static var motionModifiers = "motionModifers"
    static var motionStoredAlpha = "motionStoredAlpha"
    static var motionEnabled = "motionEnabled"
  }

  /**
   **motionID** is the identifier for the view. When doing a transition between two view controllers,
   Motion will search through all the subviews for both view controllers and matches views with the same **motionID**.

   Whenever a pair is discovered,
   Motion will automatically transit the views from source state to the destination state.
   */
  @IBInspectable public var motionID: String? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.motionID) as? String }
    set { objc_setAssociatedObject(self, &AssociatedKeys.motionID, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   **isMotionEnabled** allows to specify whether a view and its subviews should be consider for animations.
   If true, Motion will search through all the subviews for motionIds and modifiers. Defaults to true
   */
  @IBInspectable public var isMotionEnabled: Bool {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.motionEnabled) as? Bool ?? true }
    set { objc_setAssociatedObject(self, &AssociatedKeys.motionEnabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   Use **motionModifiers** to specify animations alongside the main transition. Checkout `MotionTransition.swift` for available modifiers.
   */
  public var motionModifiers: [MotionTransition]? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.motionModifiers) as? [MotionTransition] }
    set { objc_setAssociatedObject(self, &AssociatedKeys.motionModifiers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   **motionModifierString** provides another way to set **motionModifiers**. It can be assigned through storyboard.
   */
  @IBInspectable public var motionModifierString: String? {
    get { fatalError("Reverse lookup is not supported") }
    set { motionModifiers = newValue?.parse() }
  }

  internal func slowSnapshotView() -> UIView {
    UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
    layer.render(in: UIGraphicsGetCurrentContext()!)

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    let imageView = UIImageView(image: image)
    imageView.frame = bounds
    let snapshotView = UIView(frame:bounds)
    snapshotView.addSubview(imageView)
    return snapshotView
  }

  internal var flattenedViewHierarchy: [UIView] {
    guard isMotionEnabled else { return [] }
    if #available(iOS 9.0, *) {
      return isHidden && (superview is UICollectionView || superview is UIStackView || self is UITableViewCell) ? [] : ([self] + subviews.flatMap { $0.flattenedViewHierarchy })
    }
    return isHidden && (superview is UICollectionView || self is UITableViewCell) ? [] : ([self] + subviews.flatMap { $0.flattenedViewHierarchy })
  }

  /// Used for .overFullScreen presentation
  internal var motionStoredAlpha: CGFloat? {
    get {
      if let doubleValue = (objc_getAssociatedObject(self, &AssociatedKeys.motionStoredAlpha) as? NSNumber)?.doubleValue {
        return CGFloat(doubleValue)
      }
      return nil
    }
    set {
      if let newValue = newValue {
        objc_setAssociatedObject(self, &AssociatedKeys.motionStoredAlpha, NSNumber(value:newValue.native), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      } else {
        objc_setAssociatedObject(self, &AssociatedKeys.motionStoredAlpha, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
}

fileprivate var MotionInstanceKey: UInt8 = 0

fileprivate struct MotionInstance {
    /// An optional reference to the motion animations.
    fileprivate var animations: [MotionAnimation]?
}

extension UIView {
    /// MotionInstance reference.
    fileprivate var motionInstance: MotionInstance {
        get {
            return AssociatedObject.get(base: self, key: &MotionInstanceKey) {
                return MotionInstance(animations: nil)
            }
        }
        set(value) {
            AssociatedObject.set(base: self, key: &MotionInstanceKey, value: value)
        }
    }
    
    /// The animations to run.
    open var motionAnimations: [MotionAnimation]? {
        get {
            return motionInstance.animations
        }
        set(value) {
            motionInstance.animations = value
        }
    }
}

extension UIView {
    /// Computes the rotation of the view.
    open var motionRotationAngle: CGFloat {
        get {
            return CGFloat(atan2f(Float(transform.b), Float(transform.a))) * 180 / CGFloat(Double.pi)
        }
        set(value) {
            transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) * value / 180)
        }
    }
    
    /// The global position of a view.
    open var motionPosition: CGPoint {
        return superview?.convert(layer.position, to: nil) ?? layer.position
    }
    
    /// The layer.transform of a view.
    open var motionTransform: CATransform3D {
        get {
            return layer.transform
        }
        set(value) {
            layer.transform = value
        }
    }
    
    /// Computes the scale X axis value of the view.
    open var motionScaleX: CGFloat {
        return transform.a
    }
    
    /// Computes the scale Y axis value of the view.
    open var motionScaleY: CGFloat {
        return transform.b
    }
    
    /**
     A function that accepts CAAnimation objects and executes them on the
     view's backing layer.
     - Parameter animations: A list of CAAnimations.
     */
    open func animate(_ animations: CAAnimation...) {
        layer.animate(animations)
    }
    
    /**
     A function that accepts an Array of CAAnimation objects and executes
     them on the view's backing layer.
     - Parameter animations: An Array of CAAnimations.
     */
    open func animate(_ animations: [CAAnimation]) {
        layer.animate(animations)
    }
    
    /**
     A function that accepts a list of MotionAnimation values and executes
     them on the view's backing layer.
     - Parameter animations: A list of MotionAnimation values.
     */
    open func motion(_ animations: MotionAnimation...) {
        layer.motion(animations)
    }
    
    /**
     A function that accepts an Array of MotionAnimation values and executes
     them on the view's backing layer.
     - Parameter animations: An Array of MotionAnimation values.
     - Parameter completion: An optional completion block.
     */
    open func motion(_ animations: [MotionAnimation], completion: (() -> Void)? = nil) {
        layer.motion(animations, completion: completion)
    }
}
