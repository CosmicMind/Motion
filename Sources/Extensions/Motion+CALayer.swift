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

@available(iOS 10, *)
extension CALayer: CAAnimationDelegate {}

internal extension CALayer {
    /// Retrieves all currently running animations for the layer.
    var animations: [(String, CAAnimation)] {
        guard let keys = animationKeys() else {
            return []
        }
        
        return keys.map {
            return ($0, self.animation(forKey: $0)!.copy() as! CAAnimation)
        }
    }
}

public extension CALayer {
    /**
     A function that accepts CAAnimation objects and executes them on the
     view's backing layer.
     - Parameter animation: A CAAnimation instance.
     */
    func animate(_ animations: CAAnimation...) {
        animate(animations)
    }
    
    /**
     A function that accepts CAAnimation objects and executes them on the
     view's backing layer.
     - Parameter animation: A CAAnimation instance.
     */
    func animate(_ animations: [CAAnimation]) {
        for animation in animations {
            if nil == animation.delegate {
                animation.delegate = self
            }
            
            if let a = animation as? CABasicAnimation {
                a.fromValue = (presentation() ?? self).value(forKeyPath: a.keyPath!)
            }
            
            if let a = animation as? CAPropertyAnimation {
                add(a, forKey: a.keyPath!)
            } else if let a = animation as? CAAnimationGroup {
                add(a, forKey: nil)
            } else if let a = animation as? CATransition {
                add(a, forKey: kCATransition)
            }
        }
    }
    
    /**
     Executed when an animation has started. 
     - Parameter _ anim: A CAAnimation.
     */
    func animationDidStart(_ anim: CAAnimation) {}
    
    /**
     A delegation function that is executed when the backing layer stops
     running an animation.
     - Parameter animation: The CAAnimation instance that stopped running.
     - Parameter flag: A boolean that indicates if the animation stopped
     because it was completed or interrupted. True if completed, false
     if interrupted.
     */
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let a = anim as? CAPropertyAnimation else {
            if let a = (anim as? CAAnimationGroup)?.animations {
                for x in a {
                    animationDidStop(x, finished: true)
                }
            }
            return
        }
        
        guard let b = a as? CABasicAnimation else {
            return
        }
        
        guard let v = b.toValue else {
            return
        }
        
        guard let k = b.keyPath else {
            return
        }
        
        setValue(v, forKeyPath: k)
        removeAnimation(forKey: k)
    }
    
    /**
     A function that accepts a list of MotionAnimation values and executes them.
     - Parameter animations: A list of MotionAnimation values.
     */
    func animate(_ animations: MotionAnimation...) {
        animate(animations)
    }
    
    /**
     A function that accepts an Array of MotionAnimation values and executes them.
     - Parameter animations: An Array of MotionAnimation values.
     - Parameter completion: An optional completion block.
     */
    func animate(_ animations: [MotionAnimation], completion: (() -> Void)? = nil) {
        animate(delay: 0, duration: 0.35, timingFunction: .easeInOut, animations: animations, completion: completion)
    }
}

fileprivate extension CALayer {
    /**
     A function that executes an Array of MotionAnimation values.
     - Parameter delay: The animation delay TimeInterval.
     - Parameter duration: The animation duration TimeInterval.
     - Parameter timingFunction: The animation CAMediaTimingFunctionType.
     - Parameter animations: An Array of MotionAnimations.
     - Parameter completion: An optional completion block.
     */
    func animate(delay: TimeInterval, duration: TimeInterval, timingFunction: CAMediaTimingFunctionType, animations: [MotionAnimation], completion: (() -> Void)? = nil) {
        let targetState = MotionAnimationState(animations: animations)
        
        Motion.delay(targetState.delay) { [weak self] in
            guard let s = self else {
                return
            }

            var anims = [CABasicAnimation]()
            
            let tf: CAMediaTimingFunction = targetState.timingFunction ?? CAMediaTimingFunction.from(mediaTimingFunctionType: timingFunction)
            let d: TimeInterval = targetState.duration ?? duration

            if let v = targetState.backgroundColor {
                let a = MotionBasicAnimation.background(color: UIColor(cgColor: v))
                a.fromValue = s.backgroundColor
                anims.append(a)
            }
            
            if let v = targetState.borderColor {
                let a = MotionBasicAnimation.border(color: UIColor(cgColor: v))
                a.fromValue = s.borderColor
                anims.append(a)
            }
            
            if let v = targetState.borderWidth {
                let a = MotionBasicAnimation.border(width: v)
                a.fromValue = NSNumber(floatLiteral: Double(s.borderWidth))
                anims.append(a)
            }
            
            if let v = targetState.cornerRadius {
                let a = MotionBasicAnimation.corner(radius: v)
                a.fromValue = NSNumber(floatLiteral: Double(s.cornerRadius))
                anims.append(a)
            }
            
            if let v = targetState.transform {
                let a = MotionBasicAnimation.transform(v)
                a.fromValue = NSValue(caTransform3D: s.transform)
                anims.append(a)
            }
            
            if let v = targetState.spin {
                var a = MotionBasicAnimation.spinX(v.0)
                a.fromValue = NSNumber(floatLiteral: 0)
                anims.append(a)
                
                a = MotionBasicAnimation.spinY(v.1)
                a.fromValue = NSNumber(floatLiteral: 0)
                anims.append(a)
                
                a = MotionBasicAnimation.spinZ(v.2)
                a.fromValue = NSNumber(floatLiteral: 0)
                anims.append(a)
            }
            
            if let v = targetState.position {
                let a = MotionBasicAnimation.position(v)
                a.fromValue = NSValue(cgPoint: s.position)
                anims.append(a)
            }
            
            if let v = targetState.opacity {
                let a = MotionBasicAnimation.fade(v)
                a.fromValue = s.value(forKeyPath: MotionAnimationKeyPath.opacity.rawValue) ?? NSNumber(floatLiteral: 1)
                anims.append(a)
            }
            
            if let v = targetState.zPosition {
                let a = MotionBasicAnimation.zPosition(v)
                a.fromValue = s.value(forKeyPath: MotionAnimationKeyPath.zPosition.rawValue) ?? NSNumber(floatLiteral: 0)
                anims.append(a)
            }
            
            if let v = targetState.size {
                let a = MotionBasicAnimation.size(v)
                a.fromValue = NSValue(cgSize: s.bounds.size)
                anims.append(a)
            }

            if let v = targetState.shadowPath {
                let a = MotionBasicAnimation.shadow(path: v)
                a.fromValue = s.shadowPath
                anims.append(a)
            }
            
            if let v = targetState.shadowColor {
                let a = MotionBasicAnimation.shadow(color: UIColor(cgColor: v))
                a.fromValue = s.shadowColor
                anims.append(a)
            }
            
            if let v = targetState.shadowOffset {
                let a = MotionBasicAnimation.shadow(offset: v)
                a.fromValue = NSValue(cgSize: s.shadowOffset)
                anims.append(a)
            }

            if let v = targetState.shadowOpacity {
                let a = MotionBasicAnimation.shadow(opacity: v)
                a.fromValue = NSNumber(floatLiteral: Double(s.shadowOpacity))
                anims.append(a)
            }
            
            if let v = targetState.shadowRadius {
                let a = MotionBasicAnimation.shadow(radius: v)
                a.fromValue = NSNumber(floatLiteral: Double(s.shadowRadius))
                anims.append(a)
            }

            let g = Motion.animate(group: anims, duration: d)
            g.fillMode = MotionAnimationFillModeToValue(mode: .forwards)
            g.isRemovedOnCompletion = false
            g.timingFunction = tf
            
            s.animate(g)
            
            guard let execute = completion else {
                return
            }
            
            Motion.delay(d, execute: execute)
        }
    }
}
