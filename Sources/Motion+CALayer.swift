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

@available(iOS 10, *)
extension CALayer: CAAnimationDelegate {}

extension CALayer {
    /**
     A function that accepts CAAnimation objects and executes them on the
     view's backing layer.
     - Parameter animation: A CAAnimation instance.
     */
    public func animate(_ animations: CAAnimation...) {
        animate(animations)
    }
    
    /**
     A function that accepts CAAnimation objects and executes them on the
     view's backing layer.
     - Parameter animation: A CAAnimation instance.
     */
    public func animate(_ animations: [CAAnimation]) {
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
    
    public func animationDidStart(_ anim: CAAnimation) {}
    
    /**
     A delegation function that is executed when the backing layer stops
     running an animation.
     - Parameter animation: The CAAnimation instance that stopped running.
     - Parameter flag: A boolean that indicates if the animation stopped
     because it was completed or interrupted. True if completed, false
     if interrupted.
     */
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
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
    public func motion(_ animations: MotionAnimation...) {
        motion(animations)
    }
    
    /**
     A function that accepts an Array of MotionAnimation values and executes them.
     - Parameter animations: An Array of MotionAnimation values.
     - Parameter completion: An optional completion block.
     */
    public func motion(_ animations: [MotionAnimation], completion: (() -> Void)? = nil) {
        motion(delay: 0, duration: 0.35, timingFunction: .easeInEaseOut, animations: animations, completion: completion)
    }
    
    /**
     A function that executes an Array of MotionAnimation values.
     - Parameter delay: The animation delay TimeInterval.
     - Parameter duration: The animation duration TimeInterval.
     - Parameter timingFunction: The animation MotionAnimationTimingFunction.
     - Parameter animations: An Array of MotionAnimations.
     - Parameter completion: An optional completion block.
     */
    fileprivate func motion(delay: TimeInterval, duration: TimeInterval, timingFunction: MotionAnimationTimingFunction, animations: [MotionAnimation], completion: (() -> Void)? = nil) {
        var t = delay
        
        for v in animations {
            switch v {
            case let .delay(time):
                t = time
            
            default:break
            }
        }
        
        Motion.delay(t) { [weak self] in
            guard let s = self else {
                return
            }
            
            var a = [CABasicAnimation]()
            var tf = timingFunction
            var d = duration
            
            var w: CGFloat = s.bounds.width
            var h: CGFloat = s.bounds.height
            
            for v in animations {
                switch v {
                case let .width(width):
                    w = width
                
                case let .height(height):
                    h = height
                
                case let .size(width, height):
                    w = width
                    h = height
                
                default:break
                }
            }
            
            var px: CGFloat = s.position.x
            var py: CGFloat = s.position.y
            
            for v in animations {
                switch v {
                case let .x(x):
                    px = x + w / 2
                
                case let .y(y):
                    py = y + h / 2
                
                case let .point(x, y):
                    px = x + w / 2
                    py = y + h / 2
                
                default:break
                }
            }
            
            for v in animations {
                switch v {
                case let .timingFunction(timingFunction):
                    tf = timingFunction
                
                case let .duration(duration):
                    d = duration
                
                case let .custom(animation):
                    a.append(animation)
                
                case let .backgroundColor(color):
                    a.append(MotionBasicAnimation.background(color: color))
                
                case let .barTintColor(color):
                    a.append(MotionBasicAnimation.barTint(color: color))
                
                case let .borderColor(color):
                    a.append(MotionBasicAnimation.border(color: color))
                
                case let .borderWidth(width):
                    a.append(MotionBasicAnimation.border(width: width))
                
                case let .cornerRadius(radius):
                    a.append(MotionBasicAnimation.corner(radius: radius))
                
                case let .transform(transform):
                    a.append(MotionBasicAnimation.transform(transform: transform))
                
                case let .rotationAngle(angle):
                    let rotate = MotionBasicAnimation.rotation(angle: angle)
                    a.append(rotate)
                
                case let .rotationAngleX(angle):
                    a.append(MotionBasicAnimation.rotationX(angle: angle))
                
                case let .rotationAngleY(angle):
                    a.append(MotionBasicAnimation.rotationY(angle: angle))
                
                case let .rotationAngleZ(angle):
                    a.append(MotionBasicAnimation.rotationZ(angle: angle))
                
                case let .spin(rotations):
                    a.append(MotionBasicAnimation.spin(rotations: rotations))
                
                case let .spinX(rotations):
                    a.append(MotionBasicAnimation.spinX(rotations: rotations))
                
                case let .spinY(rotations):
                    a.append(MotionBasicAnimation.spinY(rotations: rotations))
                
                case let .spinZ(rotations):
                    a.append(MotionBasicAnimation.spinZ(rotations: rotations))
                
                case let .scale(to):
                    a.append(MotionBasicAnimation.scale(to: to))
                
                case let .scaleX(to):
                    a.append(MotionBasicAnimation.scaleX(to: to))
                
                case let .scaleY(to):
                    a.append(MotionBasicAnimation.scaleY(to: to))
                
                case let .scaleZ(to):
                    a.append(MotionBasicAnimation.scaleZ(to: to))
                
                case let .translate(x, y):
                    a.append(MotionBasicAnimation.translate(to: CGPoint(x: x, y: y)))
                
                case let .translateX(to):
                    a.append(MotionBasicAnimation.translateX(to: to))
                
                case let .translateY(to):
                    a.append(MotionBasicAnimation.translateY(to: to))
                
                case let .translateZ(to):
                    a.append(MotionBasicAnimation.translateZ(to: to))
                
                case .x(_), .y(_), .point(_, _):
                    let position = MotionBasicAnimation.position(to: CGPoint(x: px, y: py))
                    a.append(position)
                
                case let .position(x, y):
                    a.append(MotionBasicAnimation.position(to: CGPoint(x: x, y: y)))
                
                case let .fade(opacity):
                    let fade = MotionBasicAnimation.fade(opacity: opacity)
                    fade.fromValue = s.value(forKey: MotionAnimationKeyPath.opacity.rawValue) ?? NSNumber(floatLiteral: 1)
                    a.append(fade)
                
                case let .zPosition(index):
                    let zPosition = MotionBasicAnimation.zPosition(index: index)
                    zPosition.fromValue = s.value(forKey: MotionAnimationKeyPath.zPosition.rawValue) ?? NSNumber(integerLiteral: 0)
                    a.append(zPosition)
                
                case .width(_), .height(_), .size(_, _):
                    a.append(MotionBasicAnimation.size(CGSize(width: w, height: h)))
                
                case let .shadowPath(path):
                    let shadowPath = MotionBasicAnimation.shadow(path: path)
                    shadowPath.fromValue = s.shadowPath
                    a.append(shadowPath)
                
                case let .shadowOffset(offset):
                    let shadowOffset = MotionBasicAnimation.shadow(offset: offset)
                    shadowOffset.fromValue = s.shadowOffset
                    a.append(shadowOffset)
                
                case let .shadowOpacity(opacity):
                    let shadowOpacity = MotionBasicAnimation.shadow(opacity: opacity)
                    shadowOpacity.fromValue = s.shadowOpacity
                    a.append(shadowOpacity)
                
                case let .shadowRadius(radius):
                    let shadowRadius = MotionBasicAnimation.shadow(radius: radius)
                    shadowRadius.fromValue = s.shadowRadius
                    a.append(shadowRadius)
                
                case let .depth(offset, opacity, radius):
                    if let path = s.shadowPath {
                        let shadowPath = MotionBasicAnimation.shadow(path: path)
                        shadowPath.fromValue = s.shadowPath
                        a.append(shadowPath)
                    }
                    
                    let shadowOffset = MotionBasicAnimation.shadow(offset: offset)
                    shadowOffset.fromValue = s.shadowOffset
                    a.append(shadowOffset)
                    
                    let shadowOpacity = MotionBasicAnimation.shadow(opacity: opacity)
                    shadowOpacity.fromValue = s.shadowOpacity
                    a.append(shadowOpacity)
                    
                    let shadowRadius = MotionBasicAnimation.shadow(radius: radius)
                    shadowRadius.fromValue = s.shadowRadius
                    a.append(shadowRadius)
                    
                default:break
                }
            }
            
            let g = Motion.animate(group: a, duration: d)
            g.fillMode = MotionAnimationFillModeToValue(mode: .forwards)
            g.isRemovedOnCompletion = false
            g.timingFunction = MotionAnimationTimingFunctionToValue(timingFunction: tf)
            
            s.animate(g)
            
            guard let execute = completion else {
                return
            }
            
            Motion.delay(d, execute: execute)
        }
    }
}
