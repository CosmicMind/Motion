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

fileprivate var MotionInstanceControllerKey: UInt8 = 0

fileprivate struct MotionInstanceController {
    /// A boolean indicating whether Motion is enabled.
    fileprivate var isEnabled: Bool
    
    /// An optional reference to the current snapshot.
    fileprivate var snapshot: UIView?
    
    /// An optional reference to the previous UINavigationControllerDelegate.
    fileprivate var previousNavigationDelegate: UINavigationControllerDelegate?
    
    /// An optional reference to the previous UITabBarControllerDelegate.
    fileprivate var previousTabBarDelegate: UITabBarControllerDelegate?
}

extension UIViewController {
    /// MotionInstanceController reference.
    fileprivate var motionControllerInstance: MotionInstanceController {
        get {
            return AssociatedObject.get(base: self, key: &MotionInstanceControllerKey) {
                return MotionInstanceController(isEnabled: false, snapshot: nil, previousNavigationDelegate: nil, previousTabBarDelegate: nil)
            }
        }
        set(value) {
            AssociatedObject.set(base: self, key: &MotionInstanceControllerKey, value: value)
        }
    }
    
    /// A boolean that indicates whether motion is enabled.
    @IBInspectable
    public var isMotionEnabled: Bool {
        get {
            return transitioningDelegate is Motion
        }
        set {
            guard newValue != isMotionEnabled else {
                return
            }
            
            if newValue {
                transitioningDelegate = Motion.shared
                if let v = self as? UINavigationController {
                    motionPreviousNavigationDelegate = v.delegate
                    v.delegate = Motion.shared
                }
                
                if let v = self as? UITabBarController {
                    motionPreviousTabBarDelegate = v.delegate
                    v.delegate = Motion.shared
                }
            } else {
                transitioningDelegate = nil
                
                if let v = self as? UINavigationController, v.delegate is Motion {
                    v.delegate = motionPreviousNavigationDelegate
                }
                
                if let v = self as? UITabBarController, v.delegate is Motion {
                    v.delegate = motionPreviousTabBarDelegate
                }
            }
        }
    }
    
    /// An optional reference to the current snapshot.
    internal var motionSnapshot: UIView? {
        get {
            return motionControllerInstance.snapshot
        }
        set(value) {
            motionControllerInstance.snapshot = value
        }
    }
    
    /// An optional reference to the previous UINavigationControllerDelegate.
    internal var motionPreviousNavigationDelegate: UINavigationControllerDelegate? {
        get {
            return motionControllerInstance.previousNavigationDelegate
        }
        set(value) {
            motionControllerInstance.previousNavigationDelegate = value
        }
    }
    
    /// An optional reference to the previous UITabBarControllerDelegate.
    internal var motionPreviousTabBarDelegate: UITabBarControllerDelegate? {
        get {
            return motionControllerInstance.previousTabBarDelegate
        }
        set(value) {
            motionControllerInstance.previousTabBarDelegate = value
        }
    }
}
