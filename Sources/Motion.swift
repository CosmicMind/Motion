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

/**
 ### The singleton class/object for controlling interactive transitions.

 ```swift
 Motion.shared
 ```

 #### Use the following methods for controlling the interactive transition:

 ```swift
 func update(progress:Double)
 func end()
 func cancel()
 func apply(modifiers:[MotionTransition], to view:UIView)
 ```
 */
public class Motion: MotionController {
  // MARK: Shared Access

  /// Shared singleton object for controlling the transition
  public static let shared = Motion()

  // MARK: Properties

  /// destination view controller
  public internal(set) var toViewController: UIViewController?
  /// source view controller
  public internal(set) var fromViewController: UIViewController?
  /// whether or not we are presenting the destination view controller
  public internal(set) var presenting = true

  /// progress of the current transition. 0 if no transition is happening
  public override var progress: Double {
    didSet {
      if isTransitioning {
        transitionContext?.updateInteractiveTransition(CGFloat(progress))
      }
    }
  }

  public var isAnimating: Bool = false
  /// a UIViewControllerContextTransitioning object provided by UIKit,
  /// might be nil when isTransitioning. This happens when calling motionReplaceViewController
  internal weak var transitionContext: UIViewControllerContextTransitioning?

  internal var fullScreenSnapshot: UIView!

  internal var defaultAnimation: MotionDefaultAnimationType = .auto
  internal var containerColor: UIColor?

  // By default, Motion will always appear to be interactive to UIKit. This forces it to appear non-interactive.
  // Used when doing a motion_replaceViewController within a UINavigationController, to fix a bug with
  // UINavigationController.setViewControllers not able to handle interactive transition
  internal var forceNotInteractive = false

  internal var insertToViewFirst = false

  internal var inNavigationController = false
  internal var inTabBarController = false
  internal var inContainerController: Bool {
    return inNavigationController || inTabBarController
  }
  internal var toOverFullScreen: Bool {
    return !inContainerController && (toViewController!.modalPresentationStyle == .overFullScreen || toViewController!.modalPresentationStyle == .overCurrentContext)
  }
  internal var fromOverFullScreen: Bool {
    return !inContainerController && (fromViewController!.modalPresentationStyle == .overFullScreen || fromViewController!.modalPresentationStyle == .overCurrentContext)
  }

  internal var toView: UIView { return toViewController!.view }
  internal var fromView: UIView { return fromViewController!.view }

  internal override init() { super.init() }
}

public extension Motion {

  /// Turn off built-in animation for next transition
  func disableDefaultAnimationForNextTransition() {
    defaultAnimation = .none
  }

  /// Set the default animation for next transition
  /// This usually overrides rootView's motionTransitions during the transition
  ///
  /// - Parameter animation: animation type
  func setDefaultAnimationForNextTransition(_ animation: MotionDefaultAnimationType) {
    defaultAnimation = animation
  }

  /// Set the container color for next transition
  ///
  /// - Parameter color: container color
  func setContainerColorForNextTransition(_ color: UIColor?) {
    containerColor = color
  }
}

// internal methods for transition
internal extension Motion {
  func start() {
    guard isTransitioning else { return }
    if let fvc = fromViewController, let tvc = toViewController {
      closureProcessForMotionDelegate(vc: fvc) {
        $0.motionWillStartTransition?()
        $0.motionWillStartAnimatingTo?(viewController: tvc)
      }

      closureProcessForMotionDelegate(vc: tvc) {
        $0.motionWillStartTransition?()
        $0.motionWillStartAnimatingFrom?(viewController: fvc)
      }
    }

    // take a snapshot to hide all the flashing that might happen
    fullScreenSnapshot = transitionContainer.window?.snapshotView(afterScreenUpdates: true) ?? fromView.snapshotView(afterScreenUpdates: true)
    (transitionContainer.window ?? transitionContainer)?.addSubview(fullScreenSnapshot)

    if let oldSnapshot = fromViewController?.motionStoredSnapshot {
      oldSnapshot.removeFromSuperview()
      fromViewController?.motionStoredSnapshot = nil
    }
    if let oldSnapshot = toViewController?.motionStoredSnapshot {
      oldSnapshot.removeFromSuperview()
      toViewController?.motionStoredSnapshot = nil
    }

    prepareForTransition()
    insert(preprocessor: DefaultAnimationPreprocessor(motion: self), before: DurationPreprocessor.self)

    context.loadViewAlpha(rootView: toView)
    context.loadViewAlpha(rootView: fromView)
    container.addSubview(toView)
    container.addSubview(fromView)

    toView.frame = fromView.frame
    toView.updateConstraints()
    toView.setNeedsLayout()
    toView.layoutIfNeeded()

    context.set(fromViews: fromView.flattenedViewHierarchy, toViews: toView.flattenedViewHierarchy)

    processContext()
    prepareForAnimation()

    context.hide(view: toView)

    #if os(tvOS)
      animate()
    #else
      if inNavigationController {
        // When animating within navigationController, we have to dispatch later into the main queue.
        // otherwise snapshots will be pure white. Possibly a bug with UIKit
        DispatchQueue.main.async {
          self.animate()
        }
      } else {
        animate()
      }
    #endif
  }

  override func animate() {
    context.unhide(view: toView)

    if let containerColor = containerColor {
      container.backgroundColor = containerColor
    } else if !toOverFullScreen && !fromOverFullScreen {
      container.backgroundColor = toView.backgroundColor
    }

    if fromOverFullScreen {
      insertToViewFirst = true
    }
    for animator in animators {
      if let animator = animator as? MotionHasInsertOrder {
        animator.insertToViewFirst = insertToViewFirst
      }
    }

    super.animate()

    fullScreenSnapshot!.removeFromSuperview()
  }

  override func complete(finished: Bool) {
    guard isTransitioning else { return }

    context.clean()
    if finished && presenting && toOverFullScreen {
      // finished presenting a overFullScreen VC
      context.unhide(rootView: toView)
      context.removeSnapshots(rootView: toView)
      context.storeViewAlpha(rootView: fromView)
      fromViewController!.motionStoredSnapshot = container
      fromView.removeFromSuperview()
      fromView.addSubview(container)
    } else if !finished && !presenting && fromOverFullScreen {
      // cancelled dismissing a overFullScreen VC
      context.unhide(rootView: fromView)
      context.removeSnapshots(rootView: fromView)
      context.storeViewAlpha(rootView: toView)
      toViewController!.motionStoredSnapshot = container
      toView.removeFromSuperview()
      toView.addSubview(container)
    } else {
      context.unhideAll()
      context.removeAllSnapshots()
      container.removeFromSuperview()
    }

    // move fromView & toView back from our container back to the one supplied by UIKit
    if (toOverFullScreen && finished) || (fromOverFullScreen && !finished) {
      transitionContainer.addSubview(finished ? fromView : toView)
    }
    transitionContainer.addSubview(finished ? toView : fromView)

    if presenting != finished, !inContainerController {
      // only happens when present a .overFullScreen VC
      // bug: http://openradar.appspot.com/radar?id=5320103646199808
      UIApplication.shared.keyWindow!.addSubview(presenting ? fromView : toView)
    }

    // use temp variables to remember these values
    // because we have to reset everything before calling
    // any delegate or completion block
    let tContext = transitionContext
    let fvc = fromViewController
    let tvc = toViewController

    transitionContext = nil
    fromViewController = nil
    toViewController = nil
    containerColor = nil
    inNavigationController = false
    inTabBarController = false
    forceNotInteractive = false
    insertToViewFirst = false
    defaultAnimation = .auto

    super.complete(finished: finished)

    if finished {
      if let fvc = fvc, let tvc = tvc {
        closureProcessForMotionDelegate(vc: fvc) {
          $0.motionDidEndAnimatingTo?(viewController: tvc)
          $0.motionDidEndTransition?()
        }

        closureProcessForMotionDelegate(vc: tvc) {
          $0.motionDidEndAnimatingFrom?(viewController: fvc)
          $0.motionDidEndTransition?()
        }
      }
      tContext?.finishInteractiveTransition()
    } else {
      if let fvc = fvc, let tvc = tvc {
        closureProcessForMotionDelegate(vc: fvc) {
          $0.motionDidCancelAnimatingTo?(viewController: tvc)
          $0.motionDidCancelTransition?()
        }

        closureProcessForMotionDelegate(vc: tvc) {
          $0.motionDidCancelAnimatingFrom?(viewController: fvc)
          $0.motionDidCancelTransition?()
        }
      }
      tContext?.cancelInteractiveTransition()
    }
    tContext?.completeTransition(finished)
  }
}

// custom transition helper, used in motion_replaceViewController
internal extension Motion {
  func transition(from: UIViewController, to: UIViewController, in view: UIView, completion: ((Bool) -> Void)? = nil) {
    guard !isTransitioning else { return }
    presenting = true
    transitionContainer = view
    fromViewController = from
    toViewController = to
    completionCallback = completion
    start()
  }
}

// delegate helper
internal extension Motion {
  func closureProcessForMotionDelegate<T: UIViewController>(vc: T, closure: (MotionViewControllerDelegate) -> Void) {
    if let delegate = vc as? MotionViewControllerDelegate {
      closure(delegate)
    }

    if let navigationController = vc as? UINavigationController,
      let delegate = navigationController.topViewController as? MotionViewControllerDelegate {
      closure(delegate)
    }

    if let tabBarController = vc as? UITabBarController,
      let delegate = tabBarController.viewControllers?[tabBarController.selectedIndex] as? MotionViewControllerDelegate {
      closure(delegate)
    }
  }
}

// MARK: UIKit Protocol Conformance

/*****************************
 * UIKit protocol extensions *
 *****************************/

extension Motion: UIViewControllerAnimatedTransitioning {
  public func animateTransition(using context: UIViewControllerContextTransitioning) {
    guard !isTransitioning else { return }
    transitionContext = context
    fromViewController = fromViewController ?? context.viewController(forKey: .from)
    toViewController = toViewController ?? context.viewController(forKey: .to)
    transitionContainer = context.containerView
    start()
  }
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.375 // doesn't matter, real duration will be calculated later
  }

  public func animationEnded(_ transitionCompleted: Bool) {
    isAnimating = !transitionCompleted
  }
}

extension Motion:UIViewControllerTransitioningDelegate {
  var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
    return forceNotInteractive ? nil : self
  }

  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = true
    self.fromViewController = fromViewController ?? presenting
    self.toViewController = toViewController ?? presented
    return self
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = false
    self.fromViewController = fromViewController ?? dismissed
    return self
  }

  public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }

  public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }
}

extension Motion: UIViewControllerInteractiveTransitioning {
  public var wantsInteractiveStart: Bool {
    return true
  }
  public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    animateTransition(using: transitionContext)
  }
}

extension Motion: UINavigationControllerDelegate {
  public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = operation == .push
    self.fromViewController = fromViewController ?? fromVC
    self.toViewController = toViewController ?? toVC
    self.inNavigationController = true
    return self
  }

  public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }
}

extension Motion: UITabBarControllerDelegate {
  public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    return !isAnimating
  }

  public func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }

  public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    isAnimating = true
    let fromVCIndex = tabBarController.childViewControllers.index(of: fromVC)!
    let toVCIndex = tabBarController.childViewControllers.index(of: toVC)!
    self.presenting = toVCIndex > fromVCIndex
    self.fromViewController = fromViewController ?? fromVC
    self.toViewController = toViewController ?? toVC
    self.inTabBarController = true
    return self
  }
}

public typealias MotionDelayCancelBlock = (Bool) -> Void

extension Motion {
    /**
     Executes a block of code after a time delay.
     - Parameter duration: An animation duration time.
     - Parameter animations: An animation block.
     - Parameter execute block: A completion block that is executed once
     the animations have completed.
     */
    @discardableResult
    public class func delay(_ time: TimeInterval, execute block: @escaping () -> Void) -> MotionDelayCancelBlock? {
        var cancelable: MotionDelayCancelBlock?
        
        let delayed: MotionDelayCancelBlock = {
            if !$0 {
                DispatchQueue.main.async(execute: block)
            }
            
            cancelable = nil
        }
        
        cancelable = delayed
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            cancelable?(false)
        }
        
        return cancelable
    }
    
    /**
     Cancels the delayed MotionDelayCancelBlock.
     - Parameter delayed completion: An MotionDelayCancelBlock.
     */
    public class func cancel(delayed completion: MotionDelayCancelBlock) {
        completion(true)
    }
    
    /**
     Disables the default animations set on CALayers.
     - Parameter animations: A callback that wraps the animations to disable.
     */
    public class func disable(_ animations: (() -> Void)) {
        animate(duration: 0, animations: animations)
    }
    
    /**
     Runs an animation with a specified duration.
     - Parameter duration: An animation duration time.
     - Parameter animations: An animation block.
     - Parameter mediaTimingFunctionType: An CAMediaTimingFunctionType value.
     - Parameter completion: A completion block that is executed once
     the animations have completed.
     */
    public class func animate(duration: CFTimeInterval, mediaTimingFunctionType: CAMediaTimingFunctionType = .easeInOut, animations: (() -> Void), completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setCompletionBlock(completion)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.from(mediaTimingFunctionType: mediaTimingFunctionType))
        animations()
        CATransaction.commit()
    }
    
    /**
     Creates a CAAnimationGroup.
     - Parameter animations: An Array of CAAnimation objects.
     - Parameter mediaTimingFunctionType: An CAMediaTimingFunctionType value.
     - Parameter duration: An animation duration time for the group.
     - Returns: A CAAnimationGroup.
     */
    public class func animate(group animations: [CAAnimation], mediaTimingFunctionType: CAMediaTimingFunctionType = .easeInOut, duration: CFTimeInterval = 0.5) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.fillMode = MotionAnimationFillModeToValue(mode: .both)
        group.isRemovedOnCompletion = false
        group.animations = animations
        group.duration = duration
        group.timingFunction = CAMediaTimingFunction.from(mediaTimingFunctionType: mediaTimingFunctionType)
        return group
    }
}
