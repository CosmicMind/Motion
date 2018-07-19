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

@objc(MotionViewControllerDelegate)
public protocol MotionViewControllerDelegate {
  /**
   An optional delegation method that is executed motion will start the transition.
   - Parameter motion: A MotionTransition instance.
   - Parameter willStartTransitionFrom viewController: A UIViewController.
   */
  @objc
  optional func motionWillStartTransition(motion: MotionTransition)
  
  /**
   An optional delegation method that is executed motion did end the transition.
   - Parameter motion: A MotionTransition instance.
   - Parameter willStartTransitionFrom viewController: A UIViewController.
   */
  @objc
  optional func motionDidEndTransition(motion: MotionTransition)
  
  /**
   An optional delegation method that is executed motion did cancel the transition.
   - Parameter motion: A MotionTransition instance.
   - Parameter willStartTransitionFrom viewController: A UIViewController.
   */
  @objc
  optional func motionDidCancelTransition(motion: MotionTransition)
  
  /**
   An optional delegation method that is executed when the source
   view controller will start the transition.
   - Parameter motion: A MotionTransition instance.
   - Parameter willStartTransitionFrom viewController: A UIViewController.
   */
  @objc
  optional func motion(motion: MotionTransition, willStartTransitionFrom viewController: UIViewController)
  
  /**
   An optional delegation method that is executed when the source
   view controller did end the transition.
   - Parameter motion: A MotionTransition instance.
   - Parameter willStartTransitionFrom viewController: A UIViewController.
   */
  @objc
  optional func motion(motion: MotionTransition, didEndTransitionFrom viewController: UIViewController)
  
  /**
   An optional delegation method that is executed when the source
   view controller did cancel the transition.
   - Parameter motion: A MotionTransition instance.
   - Parameter willStartTransitionFrom viewController: A UIViewController.
   */
  @objc
  optional func motion(motion: MotionTransition, didCancelTransitionFrom viewController: UIViewController)
  
  /**
   An optional delegation method that is executed when the destination
   view controller will start the transition.
   - Parameter motion: A MotionTransition instance.
   - Parameter willStartTransitionFrom viewController: A UIViewController.
   */
  @objc
  optional func motion(motion: MotionTransition, willStartTransitionTo viewController: UIViewController)
  
  /**
   An optional delegation method that is executed when the destination
   view controller did end the transition.
   - Parameter motion: A MotionTransition instance.
   - Parameter willStartTransitionFrom viewController: A UIViewController.
   */
  @objc
  optional func motion(motion: MotionTransition, didEndTransitionTo viewController: UIViewController)
  
  /**
   An optional delegation method that is executed when the destination
   view controller did cancel the transition.
   - Parameter motion: A MotionTransition instance.
   - Parameter willStartTransitionFrom viewController: A UIViewController.
   */
  @objc
  optional func motion(motion: MotionTransition, didCancelTransitionTo viewController: UIViewController)
}

/**
 ### The singleton class/object for controlling interactive transitions.
 
 ```swift
 Motion.shared
 ```
 
 #### Use the following methods for controlling the interactive transition:
 
 ```swift
 func update(progress: Double)
 func end()
 func cancel()
 func apply(transitions: [MotionTargetState], to view: UIView)
 ```
 */
public typealias MotionCancelBlock = (Bool) -> Void

public class Motion: NSObject {}

extension Motion {
  /**
   Executes a block of code asynchronously on the main thread.
   - Parameter execute: A block that is executed asynchronously on the main thread.
   */
  public class func async(_ execute: @escaping () -> Void) {
    DispatchQueue.main.async(execute: execute)
  }
  
  /**
   Executes a block of code after a time delay.
   - Parameter _ time: A delay time.
   - Parameter execute: A block that is executed once delay has passed.
   - Returns: An optional MotionCancelBlock.
   */
  @discardableResult
  public class func delay(_ time: TimeInterval, execute: @escaping () -> Void) -> MotionCancelBlock? {
    var cancelable: MotionCancelBlock?
    
    let delayed: MotionCancelBlock = {
      if !$0 {
        async(execute)
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
   Cancels the delayed MotionCancelBlock.
   - Parameter delayed completion: An MotionCancelBlock.
   */
  public class func cancel(delayed completion: MotionCancelBlock) {
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
   - Parameter timingFunction: A CAMediaTimingFunction.
   - Parameter completion: A completion block that is executed once
   the animations have completed.
   */
  public class func animate(duration: CFTimeInterval, timingFunction: CAMediaTimingFunction = .easeInOut, animations: (() -> Void), completion: (() -> Void)? = nil) {
    CATransaction.begin()
    CATransaction.setAnimationDuration(duration)
    CATransaction.setCompletionBlock(completion)
    CATransaction.setAnimationTimingFunction(timingFunction)
    animations()
    CATransaction.commit()
  }
  
  /**
   Creates a CAAnimationGroup.
   - Parameter animations: An Array of CAAnimation objects.
   - Parameter timingFunction: A CAMediaTimingFunction.
   - Parameter duration: An animation duration time for the group.
   - Returns: A CAAnimationGroup.
   */
  public class func animate(group animations: [CAAnimation], timingFunction: CAMediaTimingFunction = .easeInOut, duration: CFTimeInterval = 0.5) -> CAAnimationGroup {
    let group = CAAnimationGroup()
    group.fillMode = MotionAnimationFillModeToValue(mode: .both)
    group.isRemovedOnCompletion = false
    group.animations = animations
    group.duration = duration
    group.timingFunction = timingFunction
    return group
  }
}

public enum MotionTransitionState: Int {
  /// Motion is able to start a new transition.
  case possible
  
  /// UIKit has notified Motion about a pending transition.
  /// Motion hasn't started preparation.
  case notified
  
  /// Motion's `start` method has been called. Preparing the animation.
  case starting
  
  /// Motions's `animate` method has been called. Animation has started.
  case animating
  
  /// Motions's `complete` method has been called. Transition has ended or has
  /// been cancelled. Motion is cleaning up.
  case completing
}

open class MotionTransition: NSObject {
  /// Shared singleton object for controlling the transition
  public static let shared = MotionTransition()
  
  /// Default animation type.
  internal var defaultAnimation = MotionTransitionAnimationType.auto
  
  /// The color of the transitioning container.
  internal var containerBackgroundColor = UIColor.black
  
  /// A boolean indicating if the user may interact with the
  /// view controller while in transition.
  public var isUserInteractionEnabled = false
  
  /// A reference to the MotionViewOrderStrategy.
  public var viewOrderStrategy = MotionViewOrderStrategy.auto
  
  /// State of the transition.
  public internal(set) var state = MotionTransitionState.possible {
    didSet {
      guard .notified != state, .starting != state else {
        return
      }
      
      beginCallback?(.animating == state)
      beginCallback = nil
    }
  }
  
  /// A boolean indicating whether a transition is active.
  public var isTransitioning: Bool {
    return state != .possible
  }
  
  /// Whether or not we are presenting the destination view controller.
  public internal(set) var isPresenting = true
    
  /**
   A boolean indicating if the transition is of modal type.
   True if `viewController.present(_:animated:completion:)` or
   `viewController.dismiss(animated:completion:)` is called, false otherwise.
   */
  public internal(set) var isModalTransition = false
  
  /// A boolean indicating whether the transition interactive or not.
  public var isInteractive: Bool {
    return !progressRunner.isRunning
  }
  
  /**
   A view container used to hold all the animating views during a
   transition.
   */
  public internal(set) var container: UIView!
  
  /// UIKit's supplied transition container.
  internal var transitionContainer: UIView?
  
  /// An optional begin callbcak.
  internal var beginCallback: ((Bool) -> Void)?
  
  /// An optional completion callback.
  internal var completionCallback: ((Bool) -> Void)?
  
  /// An Array of MotionPreprocessors used during a transition.
  internal lazy var preprocessors = [MotionPreprocessor]()
  
  /// An Array of MotionAnimators used during a transition.
  internal lazy var animators = [MotionAnimator]()
  
  /// An Array of MotionPlugins used during a transition.
  internal lazy var plugins = [MotionPlugin]()
  
  /// The matching fromViews to toViews based on the motionIdentifier value.
  internal var animatingFromViews = [UIView]()
  internal var animatingToViews = [UIView]()
  
  /// Plugins that are enabled during the transition.
  internal static var enabledPlugins = [MotionPlugin.Type]()
  
  /// Source view controller.
  public internal(set) var fromViewController: UIViewController?
  
  /// A reference to the fromView, fromViewController.view.
  internal var fromView: UIView? {
    return fromViewController?.view
  }
  
  /// Destination view controller.
  public internal(set) var toViewController: UIViewController?
  
  /// A reference to the toView, toViewController.view.
  internal var toView: UIView? {
    return toViewController?.view
  }
  
  /// A reference to the MotionContext.
  public internal(set) var context: MotionContext!
  
  /// An Array of observers that are updated during a transition.
  internal var transitionObservers: [MotionTargetStateObserver]?
  
  /// Max duration used by MotionAnimators and MotionPlugins.
  public internal(set) var totalDuration: TimeInterval = 0
  
  /// Progress of the current transition. 0 if no transition is happening.
  public internal(set) var progress: TimeInterval = 0 {
    didSet {
      guard .animating == state else {
        return
      }
      
      updateTransitionObservers()
      
      if isInteractive {
        updateAnimators()
      } else {
        updatePlugins()
      }
      
      transitionContext?.updateInteractiveTransition(CGFloat(progress))
    }
  }
  
  /// A reference to a MotionProgressRunner.
  lazy var progressRunner: MotionProgressRunner = {
    let runner = MotionProgressRunner()
    runner.delegate = self
    return runner
  }()
  
  /**
   A UIViewControllerContextTransitioning object provided by UIKit, which
   might be nil when isTransitioning. This happens when calling motionReplaceViewController
   */
  internal weak var transitionContext: UIViewControllerContextTransitioning?
  
  /// A reference to a fullscreen snapshot.
  internal var fullScreenSnapshot: UIView?
  
  /**
   By default, Motion will always appear to be interactive to UIKit. This forces it to appear non-interactive.
   Used when doing a motionReplaceViewController within a UINavigationController, to fix a bug with
   UINavigationController.setViewControllers not able to handle interactive transitions.
   */
  internal var forceNonInteractive = false
  internal var forceFinishing: Bool?
  internal var startingProgress: TimeInterval?
  
  /// A weak reference to the currently transitioning view controller.
  internal weak var transitioningViewController: UIViewController?
  
  /// Indicates whether a UINavigationController is transitioning.
  internal var isNavigationController: Bool {
    return transitioningViewController is UINavigationController
  }
  
  /// Indicates whether a UITabBarController is transitioning.
  internal var isTabBarController: Bool {
    return transitioningViewController is UITabBarController
  }
  
  /// Indicates whether a UINavigationController or UITabBarController is transitioning.
  internal var isContainerController: Bool {
    return isNavigationController || isTabBarController
  }
  
  /// Indicates whether the to view controller is full screen.
  internal var toOverFullScreen: Bool {
    return !isContainerController && (toViewController?.modalPresentationStyle == .overFullScreen || toViewController?.modalPresentationStyle == .overCurrentContext)
  }
  
  /// Indicates whether the from view controller is full screen.
  internal var fromOverFullScreen: Bool {
    return !isContainerController && (fromViewController?.modalPresentationStyle == .overFullScreen || fromViewController?.modalPresentationStyle == .overCurrentContext)
  }
  
  /// An initializer.
  internal override init() {
    super.init()
  }
  
  /**
   Complete the transition.
   - Parameter after: A TimeInterval.
   - Parameter isFinishing: A Boolean indicating if the transition
   has completed.
   */
  func complete(after: TimeInterval, isFinishing: Bool) {
    guard [MotionTransitionState.animating, .starting, .notified].contains(state) else {
      return
    }
    
    if after <= 1.0 / 120 {
      complete(isFinishing: isFinishing)
      return
    }
    
    let duration = after / (isFinishing ? max((1 - progress), 0.01) : max(progress, 0.01))
    
    progressRunner.start(progress: progress * duration, duration: duration, isReversed: !isFinishing)
  }

  private func delegate(respondingTo selector: Selector?) -> NSObjectProtocol? {
    guard let selector = selector else { return nil }

    /// Workaround for recursion happening during navigationController transtion.
    /// Avoiding private selectors (e.g _shouldCrossFadeBottomBars)
    guard !selector.description.starts(with: "_") else { return nil }
    
    /// Get relevant delegate according to controller type
    let delegate: NSObjectProtocol? = {
      if isTabBarController {
        return transitioningViewController?.previousTabBarDelegate
      }
      
      if isNavigationController {
        return transitioningViewController?.previousNavigationDelegate
      }
      
      return nil
    }()
    
    return true == delegate?.responds(to: selector) ? delegate : nil
  }
  
  open override func forwardingTarget(for aSelector: Selector!) -> Any? {
    guard let superTarget = super.forwardingTarget(for: aSelector) else {
      return delegate(respondingTo: aSelector)
    }
    
    return superTarget
  }
  
  open override func responds(to aSelector: Selector!) -> Bool {
    return super.responds(to: aSelector) || nil != delegate(respondingTo: aSelector)
  }
}

extension MotionTransition: MotionProgressRunnerDelegate {
  func update(progress: TimeInterval) {
    self.progress = progress
  }
}

extension MotionTransition {
  /**
   Receive callbacks on each animation frame.
   Observers will be cleaned when a transition completes.
   - Parameter observer: A MotionTargetStateObserver.
   */
  func addTransitionObserver(observer: MotionTargetStateObserver) {
    if nil == transitionObservers {
      transitionObservers = []
    }
    
    transitionObservers?.append(observer)
  }
}

fileprivate extension MotionTransition {
  /// Updates the transition observers.
  func updateTransitionObservers() {
    guard let observers = transitionObservers else {
      return
    }
    
    for v in observers {
      v.motion(transitionObserver: v, didUpdateWith: progress)
    }
  }
  
  /// Updates the animators.
  func updateAnimators() {
    let t = progress * totalDuration
    for v in animators {
      v.seek(to: t)
    }
  }
  
  /// Updates the plugins.
  func updatePlugins() {
    let t = progress * totalDuration
    for v in plugins where v.requirePerFrameCallback {
      v.seek(to: t)
    }
  }
}

internal extension MotionTransition {
  /**
   Checks if a given plugin is enabled.
   - Parameter plugin: A MotionPlugin.Type.
   - Returns: A boolean indicating if the plugin is enabled or not.
   */
  static func isEnabled(plugin: MotionPlugin.Type) -> Bool {
    return nil != enabledPlugins.index(where: { return $0 == plugin })
  }
  
  /**
   Enables a given plugin.
   - Parameter plugin: A MotionPlugin.Type.
   */
  static func enable(plugin: MotionPlugin.Type) {
    disable(plugin: plugin)
    enabledPlugins.append(plugin)
  }
  
  /**
   Disables a given plugin.
   - Parameter plugin: A MotionPlugin.Type.
   */
  static func disable(plugin: MotionPlugin.Type) {
    guard let index = enabledPlugins.index(where: { return $0 == plugin }) else {
      return
    }
    
    enabledPlugins.remove(at: index)
  }
}

public extension MotionTransition {
  /// Turn off built-in animations for the next transition.
  func disableDefaultAnimationForNextTransition() {
    defaultAnimation = .none
  }
  
  /**
   Set the default animation for the next transition. This may override the
   root-view's motionModifiers during the transition.
   - Parameter animation: A MotionTransitionAnimationType.
   */
  func setAnimationForNextTransition(_ animation: MotionTransitionAnimationType) {
    defaultAnimation = animation
  }
  
  /**
   Set the container background color for the next transition.
   - Parameter _ color: A UIColor.
   */
  func setContainerBackgroundColorForNextTransition(_ color: UIColor) {
    containerBackgroundColor = color
  }
}

internal extension MotionTransition {
  /**
   Processes the start transition delegation methods.
   - Parameter fromViewController: An optional UIViewController.
   - Parameter toViewController: An optional UIViewController.
   */
  func processStartTransitionDelegation(fromViewController: UIViewController?, toViewController: UIViewController?) {
    guard let fvc = fromViewController else {
      return
    }
    
    guard let tvc = toViewController else {
      return
    }
    
    if !isModalTransition {
        fvc.beginAppearanceTransition(false, animated: true)
        tvc.beginAppearanceTransition(true, animated: true)
    }
    
    processForMotionDelegate(viewController: fvc) { [weak self] in
      guard let `self` = self else {
        return
      }
      
      $0.motion?(motion: self, willStartTransitionTo: tvc)
      $0.motionWillStartTransition?(motion: self)
    }
    
    processForMotionDelegate(viewController: tvc) { [weak self] in
      guard let `self` = self else {
        return
      }
      
      $0.motion?(motion: self, willStartTransitionFrom: fvc)
      $0.motionWillStartTransition?(motion: self)
    }
  }
  
  /**
   Processes the end transition delegation methods.
   - Parameter transitionContext: An optional UIViewControllerContextTransitioning.
   - Parameter fromViewController: An optional UIViewController.
   - Parameter toViewController: An optional UIViewController.
   */
  func processEndTransitionDelegation(transitionContext: UIViewControllerContextTransitioning?, fromViewController: UIViewController?, toViewController: UIViewController?) {
    guard let fvc = fromViewController else {
      return
    }
    
    guard let tvc = toViewController else {
      return
    }
    
    if !isModalTransition {
        tvc.endAppearanceTransition()
        fvc.endAppearanceTransition()
    }
    
    processForMotionDelegate(viewController: fvc) { [weak self] in
      guard let `self` = self else {
        return
      }
      
      $0.motion?(motion: self, didEndTransitionTo: tvc)
      $0.motionDidEndTransition?(motion: self)
    }
    
    processForMotionDelegate(viewController: tvc) { [weak self] in
      guard let `self` = self else {
        return
      }
      
      $0.motion?(motion: self, didEndTransitionFrom: fvc)
      $0.motionDidEndTransition?(motion: self)
    }
    
    transitionContext?.finishInteractiveTransition()
  }
  
  /**
   Processes the cancel transition delegation methods.
   - Parameter transitionContext: An optional UIViewControllerContextTransitioning.
   - Parameter fromViewController: An optional UIViewController.
   - Parameter toViewController: An optional UIViewController.
   */
  func processCancelTransitionDelegation(transitionContext: UIViewControllerContextTransitioning?, fromViewController: UIViewController?, toViewController: UIViewController?) {
    guard let fvc = fromViewController else {
      return
    }
    
    guard let tvc = toViewController else {
      return
    }
    
    tvc.endAppearanceTransition()
    fvc.endAppearanceTransition()
    
    processForMotionDelegate(viewController: fvc) { [weak self] in
      guard let `self` = self else {
        return
      }
      
      $0.motion?(motion: self, didCancelTransitionTo: tvc)
      $0.motionDidCancelTransition?(motion: self)
    }
    
    processForMotionDelegate(viewController: tvc) { [weak self] in
      guard let `self` = self else {
        return
      }
      
      $0.motion?(motion: self, didCancelTransitionFrom: fvc)
      $0.motionDidCancelTransition?(motion: self)
    }
    
    transitionContext?.finishInteractiveTransition()
  }
}

internal extension MotionTransition {
  /**
   Helper for processing the MotionViewControllerDelegate.
   - Parameter viewController: A UIViewController of type `T`.
   - Parameter execute: A callback for execution during processing.
   */
  func processForMotionDelegate<T: UIViewController>(viewController: T, execute: (MotionViewControllerDelegate) -> Void) {
    if let delegate = viewController as? MotionViewControllerDelegate {
      execute(delegate)
    }
    
    if let v = viewController as? UINavigationController,
      let delegate = v.topViewController as? MotionViewControllerDelegate {
      execute(delegate)
    }
    
    if let v = viewController as? UITabBarController,
      let delegate = v.viewControllers?[v.selectedIndex] as? MotionViewControllerDelegate {
      execute(delegate)
    }
  }
}
