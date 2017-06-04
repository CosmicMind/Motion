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

internal class MotionViewControllerConfig: NSObject {
  var modalAnimation: MotionDefaultAnimationType = .auto
  var navigationAnimation: MotionDefaultAnimationType = .auto
  var tabBarAnimation: MotionDefaultAnimationType = .auto

  var storedSnapshot: UIView?
  var previousNavigationDelegate: UINavigationControllerDelegate?
  var previousTabBarDelegate: UITabBarControllerDelegate?
}

public extension UIViewController {
  private struct AssociatedKeys {
    static var motionConfig = "motionConfig"
  }

  internal var motionConfig: MotionViewControllerConfig {
    get {
      if let config = objc_getAssociatedObject(self, &AssociatedKeys.motionConfig) as? MotionViewControllerConfig {
        return config
      }
      let config = MotionViewControllerConfig()
      self.motionConfig = config
      return config
    }
    set { objc_setAssociatedObject(self, &AssociatedKeys.motionConfig, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  internal var previousNavigationDelegate: UINavigationControllerDelegate? {
    get { return motionConfig.previousNavigationDelegate }
    set { motionConfig.previousNavigationDelegate = newValue }
  }

  internal var previousTabBarDelegate: UITabBarControllerDelegate? {
    get { return motionConfig.previousTabBarDelegate }
    set { motionConfig.previousTabBarDelegate = newValue }
  }

  /// used for .overFullScreen presentation
  internal var motionStoredSnapshot: UIView? {
    get { return motionConfig.storedSnapshot }
    set { motionConfig.storedSnapshot = newValue }
  }

  /// default motion animation type for presenting & dismissing modally
  public var motionModalAnimationType: MotionDefaultAnimationType {
    get { return motionConfig.modalAnimation }
    set { motionConfig.modalAnimation = newValue }
  }

  @IBInspectable public var motionModalAnimationTypeString: String? {
    get { return motionConfig.modalAnimation.label }
    set { motionConfig.modalAnimation = newValue?.parseOne() ?? .auto }
  }

  @IBInspectable public var isMotionEnabled: Bool {
    get {
      return transitioningDelegate is Motion
    }

    set {
      guard newValue != isMotionEnabled else { return }
      if newValue {
        transitioningDelegate = Motion.shared
        if let navi = self as? UINavigationController {
          previousNavigationDelegate = navi.delegate
          navi.delegate = Motion.shared
        }
        if let tab = self as? UITabBarController {
          previousTabBarDelegate = tab.delegate
          tab.delegate = Motion.shared
        }
      } else {
        transitioningDelegate = nil
        if let navi = self as? UINavigationController, navi.delegate is Motion {
          navi.delegate = previousNavigationDelegate
        }
        if let tab = self as? UITabBarController, tab.delegate is Motion {
          tab.delegate = previousTabBarDelegate
        }
      }
    }
  }
}

extension UINavigationController {
  /// default motion animation type for push and pop within the navigation controller
  public var motionNavigationAnimationType: MotionDefaultAnimationType {
    get { return motionConfig.navigationAnimation }
    set { motionConfig.navigationAnimation = newValue }
  }

  @IBInspectable public var motionNavigationAnimationTypeString: String? {
    get { return motionConfig.navigationAnimation.label }
    set { motionConfig.navigationAnimation = newValue?.parseOne() ?? .auto }
  }
}

extension UITabBarController {
  /// default motion animation type for switching tabs within the tab bar controller
  public var motionTabBarAnimationType: MotionDefaultAnimationType {
    get { return motionConfig.tabBarAnimation }
    set { motionConfig.tabBarAnimation = newValue }
  }

  @IBInspectable public var motionTabBarAnimationTypeString: String? {
    get { return motionConfig.tabBarAnimation.label }
    set { motionConfig.tabBarAnimation = newValue?.parseOne() ?? .auto }
  }
}

extension UIViewController {
  @available(*, deprecated: 0.1.4, message: "use motion_dismissViewController instead")
  @IBAction public func ht_dismiss(_ sender: UIView) {
    motion_dismissViewController()
  }

  @available(*, deprecated: 0.1.4, message: "use motion_replaceViewController(with:) instead")
  public func motionReplaceViewController(with next: UIViewController) {
    motion_replaceViewController(with: next)
  }

  /**
   Dismiss the current view controller with animation. Will perform a navigationController.popViewController
   if the current view controller is contained inside a navigationController
   */
  @IBAction public func motion_dismissViewController() {
    if let navigationController = navigationController, navigationController.viewControllers.first != self {
      navigationController.popViewController(animated: true)
    } else {
      dismiss(animated: true, completion: nil)
    }
  }

  /**
   Unwind to the root view controller using Motion
   */
  @IBAction public func motion_unwindToRootViewController() {
    motion_unwindToViewController { $0.presentingViewController == nil }
  }

  /**
   Unwind to a specific view controller using Motion
   */
  public func motion_unwindToViewController(_ toViewController: UIViewController) {
    motion_unwindToViewController { $0 == toViewController }
  }

  /**
   Unwind to a view controller that responds to the given selector using Motion
   */
  public func motion_unwindToViewController(withSelector: Selector) {
    motion_unwindToViewController { $0.responds(to: withSelector) }
  }

  /**
   Unwind to a view controller with given class using Motion
   */
  public func motion_unwindToViewController(withClass: AnyClass) {
    motion_unwindToViewController { $0.isKind(of: withClass) }
  }

  /**
   Unwind to a view controller that the matchBlock returns true on.
   */
  public func motion_unwindToViewController(withMatchBlock: (UIViewController) -> Bool) {
    var target: UIViewController? = nil
    var current: UIViewController? = self

    while target == nil && current != nil {
      if let childViewControllers = (current as? UINavigationController)?.childViewControllers ?? current!.navigationController?.childViewControllers {
        for vc in childViewControllers.reversed() {
          if vc != self, withMatchBlock(vc) {
            target = vc
            break
          }
        }
      }
      if target == nil {
        current = current!.presentingViewController
        if let vc = current, withMatchBlock(vc) == true {
          target = vc
        }
      }
    }

    if let target = target {
      if target.presentedViewController != nil {
        _ = target.navigationController?.popToViewController(target, animated: false)

        let fromVC = self.navigationController ?? self
        let toVC = target.navigationController ?? target

        if target.presentedViewController != fromVC {
          // UIKit's UIViewController.dismiss will jump to target.presentedViewController then perform the dismiss.
          // We overcome this behavior by inserting a snapshot into target.presentedViewController
          // And also force Motion to use the current VC as the fromViewController
          Motion.shared.fromViewController = fromVC
          let snapshotView = fromVC.view.snapshotView(afterScreenUpdates: true)!
          toVC.presentedViewController!.view.addSubview(snapshotView)
        }

        toVC.dismiss(animated: true, completion: nil)
      } else {
        _ = target.navigationController?.popToViewController(target, animated: true)
      }
    } else {
      // unwind target not found
    }
  }

  /**
   Replace the current view controller with another VC on the navigation/modal stack.
   */
  public func motion_replaceViewController(with next: UIViewController) {
    if Motion.shared.transitioning {
      print("motion_replaceViewController cancelled because Motion was doing a transition. Use Motion.shared.cancel(animated:false) or Motion.shared.end(animated:false) to stop the transition first before calling motion_replaceViewController.")
      return
    }
    if let navigationController = navigationController {
      var vcs = navigationController.childViewControllers
      if !vcs.isEmpty {
        vcs.removeLast()
        vcs.append(next)
      }
      if navigationController.isMotionEnabled {
        Motion.shared.forceNotInteractive = true
      }
      navigationController.setViewControllers(vcs, animated: true)
    } else if let container = view.superview {
      let parentVC = presentingViewController
      Motion.shared.transition(from: self, to: next, in: container) { finished in
        if finished {
          UIApplication.shared.keyWindow?.addSubview(next.view)

          if let parentVC = parentVC {
            self.dismiss(animated: false) {
              parentVC.present(next, animated: false, completion:nil)
            }
          } else {
            UIApplication.shared.keyWindow?.rootViewController = next
          }
        }
      }
    }
  }
}
