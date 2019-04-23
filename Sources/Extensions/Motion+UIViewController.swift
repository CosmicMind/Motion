/*
 * The MIT License (MIT)
 *
 * Copyright (C) 2019, CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
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

fileprivate var AssociatedInstanceKey: UInt8 = 0

fileprivate struct AssociatedInstance {
  /// A reference to the modal animation.
  var modalTransitionType: MotionTransitionAnimationType
  
  /// A reference to the navigation animation.
  var navigationTransitionType: MotionTransitionAnimationType
  
  /// A reference to the tabBar animation.
  var tabBarTransitionType: MotionTransitionAnimationType
  
  /// A reference to the stored snapshot.
  var storedSnapshot: UIView?
  
  /**
   A reference to the previous navigation controller delegate
   before Motion was enabled.
   */
  weak var previousNavigationDelegate: UINavigationControllerDelegate?
  
  /**
   A reference to the previous tab bar controller delegate
   before Motion was enabled.
   */
  weak var previousTabBarDelegate: UITabBarControllerDelegate?
}

extension UIViewController {
  /// AssociatedInstance reference.
  fileprivate var associatedInstance: AssociatedInstance {
    get {
      return AssociatedObject.get(base: self, key: &AssociatedInstanceKey) {
        return AssociatedInstance(modalTransitionType: .auto,
                                  navigationTransitionType: .auto,
                                  tabBarTransitionType: .auto,
                                  storedSnapshot: nil,
                                  previousNavigationDelegate: nil,
                                  previousTabBarDelegate: nil)
      }
    }
    set(value) {
      AssociatedObject.set(base: self, key: &AssociatedInstanceKey, value: value)
    }
  }
  
  /// Default motion animation type for presenting & dismissing modally.
  public var motionTransitionType: MotionTransitionAnimationType {
    get {
      return associatedInstance.modalTransitionType
    }
    set(value) {
      associatedInstance.modalTransitionType = value
    }
  }
  
  /// Used for .overFullScreen presentation.
  internal var motionStoredSnapshot: UIView? {
    get {
      return associatedInstance.storedSnapshot
    }
    set(value) {
      associatedInstance.storedSnapshot = value
    }
  }
  
  /**
   A reference to the previous navigation controller delegate
   before Motion was enabled.
   */
  internal var previousNavigationDelegate: UINavigationControllerDelegate? {
    get {
      return associatedInstance.previousNavigationDelegate
    }
    set(value) {
      associatedInstance.previousNavigationDelegate = value
    }
  }
  
  /**
   A reference to the previous tab bar controller delegate
   before Motion was enabled.
   */
  internal var previousTabBarDelegate: UITabBarControllerDelegate? {
    get {
      return associatedInstance.previousTabBarDelegate
    }
    set(value) {
      associatedInstance.previousTabBarDelegate = value
    }
  }
  
  ///A boolean that indicates whether Motion is enabled or disabled.
  @IBInspectable
  public var isMotionEnabled: Bool {
    get {
      return transitioningDelegate is MotionTransition
    }
    set(value) {
      guard value != isMotionEnabled else {
        return
      }
      
      if value {
        transitioningDelegate = MotionTransition.shared
        
        if let v = self as? UINavigationController {
          previousNavigationDelegate = v.delegate
          v.delegate = MotionTransition.shared
        }
        
        if let v = self as? UITabBarController {
          previousTabBarDelegate = v.delegate
          v.delegate = MotionTransition.shared
        }
        
      } else {
        transitioningDelegate = nil
        
        if let v = self as? UINavigationController, v.delegate is MotionTransition {
          v.delegate = previousNavigationDelegate
        }
        
        if let v = self as? UITabBarController, v.delegate is MotionTransition {
          v.delegate = previousTabBarDelegate
        }
      }
    }
  }
}

extension UINavigationController {
  /// Default motion animation type for push and pop within the navigation controller.
  public var motionNavigationTransitionType: MotionTransitionAnimationType {
    get {
      return associatedInstance.navigationTransitionType
    }
    set(value) {
      associatedInstance.navigationTransitionType = value
    }
  }
}

extension UITabBarController {
  /// Default motion animation type for switching tabs within the tab bar controller.
  public var motionTabBarTransitionType: MotionTransitionAnimationType {
    get {
      return associatedInstance.tabBarTransitionType
    }
    set(value) {
      associatedInstance.tabBarTransitionType = value
    }
  }
}

extension UIViewController {
  /**
   Dismiss the current view controller with animation. Will perform a
   navigationController.popViewController if the current view controller
   is contained inside a navigationController
   */
  @IBAction
  public func motionDismissViewController() {
    if let v = navigationController, self != v.viewControllers.first {
      v.popViewController(animated: true)
    } else {
      dismiss(animated: true)
    }
  }
  
  /// Unwind to the root view controller using Motion.
  @IBAction
  public func motionUnwindToRootViewController() {
    motionUnwindToViewController {
      nil == $0.presentingViewController
    }
  }
  
  /// Unwind to a specific view controller using Motion.
  public func motionUnwindToViewController(_ toViewController: UIViewController) {
    motionUnwindToViewController {
      $0 == toViewController
    }
  }
  
  /// Unwind to a view controller that responds to the given selector using Motion.
  public func motionUnwindToViewController(withSelector: Selector) {
    motionUnwindToViewController {
      $0.responds(to: withSelector)
    }
  }
  
  /// Unwind to a view controller with given class using Motion
  public func motionUnwindToViewController(withClass: AnyClass) {
    motionUnwindToViewController {
      $0.isKind(of: withClass)
    }
  }
  
  /// Unwind to a view controller that the matchBlock returns true on.
  public func motionUnwindToViewController(withMatchBlock: (UIViewController) -> Bool) {
    var target: UIViewController? = nil
    var current: UIViewController? = self
    
    while nil == target && nil != current {
      if let childViewControllers = (current as? UINavigationController)?.children ?? current!.navigationController?.children {
        
        for vc in childViewControllers.reversed() {
          if self != vc, withMatchBlock(vc) {
            target = vc
            break
          }
        }
      }
      
      if nil == target {
        current = current!.presentingViewController
        
        if let vc = current, true == withMatchBlock(vc) {
          target = vc
        }
      }
    }
    
    guard let t = target else {
      return
    }
    
    guard nil != t.presentedViewController else {
      _ = t.navigationController?.popToViewController(t, animated: true)
      return
    }
    
    _ = t.navigationController?.popToViewController(t, animated: false)
    
    let fvc = navigationController ?? self
    let tvc = t.navigationController ?? t
    
    if t.presentedViewController != fvc {
      // UIKit's UIViewController.dismiss will jump to target.presentedViewController then perform the dismiss.
      // We overcome this behavior by inserting a snapshot into target.presentedViewController
      // And also force Hero to use the current VC as the fromViewController
      MotionTransition.shared.fromViewController = fvc
      
      let snapshotView = fvc.view.snapshotView(afterScreenUpdates: true)!
      let targetSuperview = tvc.presentedViewController!.view!
      
      if let visualEffectView = targetSuperview as? UIVisualEffectView {
        visualEffectView.contentView.addSubview(snapshotView)
      } else {
        targetSuperview.addSubview(snapshotView)
      }
    }
    
    tvc.dismiss(animated: true, completion: nil)
  }
  
  /**
   Replace the current view controller with another view controller within the
   navigation/modal stack.
   - Parameter with next: A UIViewController.
   */
  public func motionReplaceViewController(with next: UIViewController) {
    let motion = next.transitioningDelegate as? MotionTransition ?? MotionTransition.shared
    
    guard !motion.isTransitioning else {
      print("motionReplaceViewController cancelled because Motion was doing a transition. Use Motion.shared.cancel(animated: false) or Motion.shared.end(animated: false) to stop the transition first before calling motionReplaceViewController.")
      return
    }
    
    if let nc = navigationController {
      var v = nc.children
      
      if !v.isEmpty {
        v.removeLast()
        v.append(next)
      }
      
      if nc.isMotionEnabled {
        motion.forceNonInteractive = true
      }
      
      nc.setViewControllers(v, animated: true)
    } else if let container = view.superview {
      let presentingVC = presentingViewController
      
      motion.transition(from: self, to: next, in: container) { [weak self] (isFinishing) in
        guard isFinishing else {
          return
        }
        
        next.view.window?.addSubview(next.view)
        
        guard let pvc = presentingVC else {
          Application.shared.keyWindow?.rootViewController = next
          return
        }
        
        self?.dismiss(animated: false) {
          pvc.present(next, animated: false)
        }
      }
    }
  }
}
