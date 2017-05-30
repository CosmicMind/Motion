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

@objc(MotionAnimationFillMode)
public enum MotionAnimationFillMode: Int {
    case forwards
    case backwards
    case both
    case removed
}

/**
 Converts the MotionAnimationFillMode enum value to a corresponding String.
 - Parameter mode: An MotionAnimationFillMode enum value.
 */
public func MotionAnimationFillModeToValue(mode: MotionAnimationFillMode) -> String {
    switch mode {
    case .forwards:
        return kCAFillModeForwards
    case .backwards:
        return kCAFillModeBackwards
    case .both:
        return kCAFillModeBoth
    case .removed:
        return kCAFillModeRemoved
    }
}

@objc(MotionAnimationTimingFunction)
public enum MotionAnimationTimingFunction: Int {
    case `default`
    case linear
    case easeIn
    case easeOut
    case easeInEaseOut
}

/**
 Converts the MotionAnimationTimingFunction enum value to a corresponding CAMediaTimingFunction.
 - Parameter function: An MotionAnimationTimingFunction enum value.
 - Returns: A CAMediaTimingFunction.
 */
public func MotionAnimationTimingFunctionToValue(timingFunction: MotionAnimationTimingFunction) -> CAMediaTimingFunction {
    switch timingFunction {
    case .default:
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
    case .linear:
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    case .easeIn:
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    case .easeOut:
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    case .easeInEaseOut:
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    }
}

public typealias MotionDelayCancelBlock = (Bool) -> Void

fileprivate var MotionInstanceKey: UInt8 = 0
fileprivate var MotionInstanceControllerKey: UInt8 = 0

fileprivate struct MotionInstance {
    /// An optional reference to the motion identifier.
    fileprivate var identifier: String?
    
    /// An optional reference to the motion animations.
    fileprivate var animations: [MotionAnimation]?
}

fileprivate struct MotionInstanceController {
    /// A boolean indicating whether Motion is enabled.
    fileprivate var isMotionEnabled: Bool
}

extension UIViewController {
    /// MotionInstanceController reference.
    fileprivate var motionControllerInstance: MotionInstanceController {
        get {
            return AssociatedObject.get(base: self, key: &MotionInstanceControllerKey) {
                return MotionInstanceController(isMotionEnabled: false)
            }
        }
        set(value) {
            AssociatedObject.set(base: self, key: &MotionInstanceControllerKey, value: value)
        }
    }
    
    /// A boolean that indicates whether motion is enabled.
    open var isMotionEnabled: Bool {
        get {
            return motionControllerInstance.isMotionEnabled
        }
        set(value) {
            motionControllerInstance.isMotionEnabled = value
        }
    }
}

extension UIView {
    /// MotionInstance reference.
    fileprivate var motionInstance: MotionInstance {
        get {
            return AssociatedObject.get(base: self, key: &MotionInstanceKey) {
                return MotionInstance(identifier: nil, animations: nil)
            }
        }
        set(value) {
            AssociatedObject.set(base: self, key: &MotionInstanceKey, value: value)
        }
    }
    
    /// An identifier value used to connect views across UIViewControllers.
    open var motionIdentifier: String? {
        get {
            return motionInstance.identifier
        }
        set(value) {
            motionInstance.identifier = value
        }
    }
    
    /// The animations to run while in transition.
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
    /**
     Snapshots the view instance for animations during transitions.
     - Parameter afterUpdates: A boolean indicating whether to snapshot the view
     after a render update, or as is.
     - Parameter shouldHide: A boolean indicating whether the view should be hidden
     after the snapshot is taken.
     - Returns: A UIView instance that is a snapshot of the given UIView.
     */
    open func transitionSnapshot(afterUpdates: Bool, shouldHide: Bool = true) -> UIView {
        isHidden = false
        
        let oldCornerRadius = layer.cornerRadius
        layer.cornerRadius = 0
        
        var oldBackgroundColor: UIColor?
        
        if shouldHide {
            oldBackgroundColor = backgroundColor
            backgroundColor = .clear
        }
        
        let oldTransform = motionTransform
        motionTransform = CATransform3DIdentity
        
        let v = snapshotView(afterScreenUpdates: afterUpdates)!
        layer.cornerRadius = oldCornerRadius
        
        if shouldHide {
            backgroundColor = oldBackgroundColor
        }
        
        motionTransform = oldTransform
        
        let contentView = v.subviews.first!
        contentView.layer.cornerRadius = layer.cornerRadius
        contentView.layer.masksToBounds = true
        
        v.motionIdentifier = motionIdentifier
        v.layer.position = motionPosition
        v.bounds = bounds
        v.layer.cornerRadius = layer.cornerRadius
        v.layer.zPosition = layer.zPosition
        v.layer.opacity = layer.opacity
        v.isOpaque = isOpaque
        v.layer.anchorPoint = layer.anchorPoint
        v.layer.masksToBounds = layer.masksToBounds
        v.layer.borderColor = layer.borderColor
        v.layer.borderWidth = layer.borderWidth
        v.layer.shadowRadius = layer.shadowRadius
        v.layer.shadowOpacity = layer.shadowOpacity
        v.layer.shadowColor = layer.shadowColor
        v.layer.shadowOffset = layer.shadowOffset
        v.contentMode = contentMode
        v.motionTransform = motionTransform
        v.backgroundColor = backgroundColor
        
        isHidden = shouldHide
        
        return v
    }
}

open class Motion {
    /**
     Executes a block of code after a time delay.
     - Parameter duration: An animation duration time.
     - Parameter animations: An animation block.
     - Parameter execute block: A completion block that is executed once
     the animations have completed.
     */
    @discardableResult
    open class func delay(_ time: TimeInterval, execute block: @escaping () -> Void) -> MotionDelayCancelBlock? {
        func asyncAfter(completion: @escaping () -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: completion)
        }
        
        var cancelable: MotionDelayCancelBlock?
        
        let delayed: MotionDelayCancelBlock = {
            if !$0 {
                DispatchQueue.main.async(execute: block)
            }
            cancelable = nil
        }
        
        cancelable = delayed
        
        asyncAfter {
            cancelable?(false)
        }
        
        return cancelable
    }
    
    /**
     Cancels the delayed MotionDelayCancelBlock.
     - Parameter delayed completion: An MotionDelayCancelBlock.
     */
    open class func cancel(delayed completion: MotionDelayCancelBlock) {
        completion(true)
    }
    
    /**
     Disables the default animations set on CALayers.
     - Parameter animations: A callback that wraps the animations to disable.
     */
    open class func disable(_ animations: (() -> Void)) {
        animate(duration: 0, animations: animations)
    }
    
    /**
     Runs an animation with a specified duration.
     - Parameter duration: An animation duration time.
     - Parameter animations: An animation block.
     - Parameter timingFunction: An MotionAnimationTimingFunction value.
     - Parameter completion: A completion block that is executed once
     the animations have completed.
     */
    open class func animate(duration: CFTimeInterval, timingFunction: MotionAnimationTimingFunction = .easeInEaseOut, animations: (() -> Void), completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setCompletionBlock(completion)
        CATransaction.setAnimationTimingFunction(MotionAnimationTimingFunctionToValue(timingFunction: timingFunction))
        animations()
        CATransaction.commit()
    }
    
    /**
     Creates a CAAnimationGroup.
     - Parameter animations: An Array of CAAnimation objects.
     - Parameter timingFunction: An MotionAnimationTimingFunction value.
     - Parameter duration: An animation duration time for the group.
     - Returns: A CAAnimationGroup.
     */
    open class func animate(group animations: [CAAnimation], timingFunction: MotionAnimationTimingFunction = .easeInEaseOut, duration: CFTimeInterval = 0.5) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.fillMode = MotionAnimationFillModeToValue(mode: .forwards)
        group.isRemovedOnCompletion = false
        group.animations = animations
        group.duration = duration
        group.timingFunction = MotionAnimationTimingFunctionToValue(timingFunction: timingFunction)
        return group
    }
}
