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
     - Parameter motion: A Motion instance.
     - Parameter willStartTransitionFrom viewController: A UIViewController.
     */
    @objc
    optional func motionWillStartTransition(motion: Motion)
    
    /**
     An optional delegation method that is executed motion did end the transition.
     - Parameter motion: A Motion instance.
     - Parameter willStartTransitionFrom viewController: A UIViewController.
     */
    @objc
    optional func motionDidEndTransition(motion: Motion)
    
    /**
     An optional delegation method that is executed motion did cancel the transition.
     - Parameter motion: A Motion instance.
     - Parameter willStartTransitionFrom viewController: A UIViewController.
     */
    @objc
    optional func motionDidCancelTransition(motion: Motion)
    
    /**
     An optional delegation method that is executed when the source
     view controller will start the transition.
     - Parameter motion: A Motion instance.
     - Parameter willStartTransitionFrom viewController: A UIViewController.
     */
    @objc
    optional func motion(motion: Motion, willStartTransitionFrom viewController: UIViewController)
    
    /**
     An optional delegation method that is executed when the source
     view controller did end the transition.
     - Parameter motion: A Motion instance.
     - Parameter willStartTransitionFrom viewController: A UIViewController.
     */
    @objc
    optional func motion(motion: Motion, didEndTransitionFrom viewController: UIViewController)
    
    /**
     An optional delegation method that is executed when the source
     view controller did cancel the transition.
     - Parameter motion: A Motion instance.
     - Parameter willStartTransitionFrom viewController: A UIViewController.
     */
    @objc
    optional func motion(motion: Motion, didCancelTransitionFrom viewController: UIViewController)
    
    /**
     An optional delegation method that is executed when the destination
     view controller will start the transition.
     - Parameter motion: A Motion instance.
     - Parameter willStartTransitionFrom viewController: A UIViewController.
     */
    @objc
    optional func motion(motion: Motion, willStartTransitionTo viewController: UIViewController)
    
    /**
     An optional delegation method that is executed when the destination
     view controller did end the transition.
     - Parameter motion: A Motion instance.
     - Parameter willStartTransitionFrom viewController: A UIViewController.
     */
    @objc
    optional func motion(motion: Motion, didEndTransitionTo viewController: UIViewController)
    
    /**
     An optional delegation method that is executed when the destination
     view controller did cancel the transition.
     - Parameter motion: A Motion instance.
     - Parameter willStartTransitionFrom viewController: A UIViewController.
     */
    @objc
    optional func motion(motion: Motion, didCancelTransitionTo viewController: UIViewController)
}

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
 func apply(transitions: [MotionTransition], to view: UIView)
 ```
 */
import UIKit

public class Motion: NSObject, MotionProgressRunnerDelegate {
    /// Shared singleton object for controlling the transition
    public static let shared = Motion()
    
    /// Plugins that are enabled during the transition.
    internal static var enabledPlugins = [MotionPlugin.Type]()
    
    /// A reference to a fullscreen snapshot.
    internal var fullScreenSnapshot: UIView!
    
    /// A reference to the MotionContext.
    public internal(set) var context: MotionContext!
    
    /// A boolean indicating whether the transition interactive or not.
    public var isInteractive: Bool {
        return nil == displayLink
    }
    
    /// Source view controller.
    public internal(set) var fromViewController: UIViewController?
    
    /// Destination view controller.
    public internal(set) var toViewController: UIViewController?
    
    /// A reference to the fromView, fromViewController.view.
    internal var fromView: UIView? {
        return fromViewController?.view
    }
    
    /// A reference to the toView, toViewController.view.
    internal var toView: UIView? {
        return toViewController?.view
    }
    
    /// The color of the transitioning container.
    internal var containerBackgroundColor: UIColor?
    
    /**
     A UIViewControllerContextTransitioning object provided by UIKit, which
     might be nil when isTransitioning. This happens when calling motionReplaceViewController
     */
    internal weak var transitionContext: UIViewControllerContextTransitioning?
    
    /// Progress of the current transition. 0 if no transition is happening.
    public internal(set) var elapsedTime: TimeInterval = 0 {
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
            
            transitionContext?.updateInteractiveTransition(CGFloat(elapsedTime))
        }
    }
    
    /// State of the transition.
    public internal(set) var state = MotionState.possible {
        didSet {
            guard .notified != state else {
                return
            }
            
            guard .starting != state else {
                return
            }
            
            beginCallback?(.animating == state)
            beginCallback = nil
        }
    }
    
    /// A boolean indicating whether a transition is active.
    public var isTransitioning: Bool {
        return nil != transitionContainer
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
    
    /// Binds the render cycle to the transition animation.
    internal var displayLink: CADisplayLink?
    
    /// An Array of observers that are updated during a transition.
    internal var transitionObservers: [MotionTransitionObserver]?
    
    /// Max duration used by MotionAnimators and MotionPlugins.
    public internal(set) var totalDuration: TimeInterval = 0
    
    /// The currently running animation duration.
    internal var currentAnimationDuration: TimeInterval = 0
    
    /// A reference to a MotionProgressRunner.
    lazy var progressRunner: MotionProgressRunner = {
        let runner = MotionProgressRunner()
        runner.delegate = self
        return runner
    }()
    
    /// The start time of the animation.
    internal var beginTime: TimeInterval? {
        didSet {
            guard nil != beginTime else {
                displayLink?.isPaused = true
                displayLink?.remove(from: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
                displayLink = nil
                return
            }
            
            guard nil == displayLink else {
                return
            }
            
            displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
            displayLink?.add(to: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        }
    }
    
    /// A boolean indicating if the transition has finished.
    internal var isFinished = true
    
    /// An Array of MotionPreprocessors used during a transition.
    internal lazy var preprocessors = [MotionPreprocessor]()
    
    /// An Array of MotionAnimators used during a transition.
    internal lazy var animators = [MotionAnimator]()
    
    /// An Array of MotionPlugins used during a transition.
    internal lazy var plugins = [MotionPlugin]()
    
    /// The matching fromViews to toViews based on the motionIdentifier value.
    internal lazy var transitionPairs = [(fromViews: [UIView], toViews: [UIView])]()
    
    /// Whether or not we are presenting the destination view controller.
    public var isPresenting = true
    
    /// Indicates whether the transition is animating or not.
    public var isAnimating = false
    
    /// Default animation type.
    internal var defaultAnimation = MotionTransitionType.auto
    
    /**
     By default, Motion will always appear to be interactive to UIKit. This forces it to appear non-interactive.
     Used when doing a motionReplaceViewController within a UINavigationController, to fix a bug with
     UINavigationController.setViewControllers not able to handle interactive transitions.
     */
    internal var forceNonInteractive = false
    internal var forceFinishing: Bool?
    internal var startingProgress: CGFloat?
    
    /// Inserts the toViews first.
    internal var insertToViewFirst = false
    
    /// Indicates whether a UINavigationController is transitioning.
    internal var isNavigationController = false
    
    /// Indicates whether a UITabBarController is transitioning.
    internal var isTabBarController = false
    
    /// Indicates whether a UINavigationController or UITabBarController is transitioning.
    internal var isContainerController: Bool {
        return isNavigationController || isTabBarController
    }
    
    /// Indicates whether the from view controller is full screen.
    internal var fromOverFullScreen: Bool {
        guard let v = fromViewController else {
            return false
        }
        
        return !isContainerController && (.overFullScreen == v.modalPresentationStyle || .overCurrentContext == v.modalPresentationStyle)
    }
    
    /// Indicates whether the to view controller is full screen.
    internal var toOverFullScreen: Bool {
        guard let v = toViewController else {
            return false
        }
        
        return !isContainerController && (.overFullScreen == v.modalPresentationStyle || .overCurrentContext == v.modalPresentationStyle)
    }
    
    /// An initializer.
    internal override init() {
        super.init()
    }
}

public extension Motion {
    /**
     Receive callbacks on each animation frame.
     Observers will be cleaned when a transition completes.
     - Parameter observer: A MotionTransitionObserver.
     */
    func addTransitionObserver(observer: MotionTransitionObserver) {
        if nil == transitionObservers {
            transitionObservers = []
        }
        
        transitionObservers?.append(observer)
    }
}

private extension Motion {
    /// Updates the transition observers.
    func updateTransitionObservers() {
        guard let observers = transitionObservers else {
            return
        }
        
        for v in observers {
            v.motion(transitionObserver: v, didUpdateWith: elapsedTime)
        }
    }
    
    /// Updates the animators.
    func updateAnimators() {
        let t = elapsedTime * totalDuration
        for a in animators {
            a.seek(to: t)
        }
    }
    
    /// Updates the plugins.
    func updatePlugins() {
        let t = elapsedTime * totalDuration
        for p in plugins where p.requirePerFrameCallback {
            p.seek(to: t)
        }
    }
}

private extension Motion {
    /**
     Handler for the DisplayLink updates.
     - Parameter _ link: CADisplayLink.
     */
    @objc
    func handleDisplayLink(_ link: CADisplayLink) {
        guard isTransitioning else {
            return
        }
        
        guard 0 < currentAnimationDuration else {
            return
        }
        
        guard let t = beginTime else {
            return
        }
        
        let cTime = CACurrentMediaTime() - t
        
        if cTime > currentAnimationDuration {
            elapsedTime = isFinished ? 1 : 0
            
            beginTime = nil
            
            complete(isFinished: isFinished)
            
        } else {
            var eTime = cTime / totalDuration
            
            if !isFinished {
                eTime = 1 - eTime
            }
            
            elapsedTime = max(0, min(1, eTime))
        }
    }
}

public extension Motion {
    /**
     Updates the elapsed time for the interactive transition.
     - Parameter elapsedTime t: the current progress, must be between -1...1.
     */
    public func update(elapsedTime: TimeInterval) {
        guard isTransitioning else {
            return
        }
        
        beginTime = nil
        self.elapsedTime = max(-1, min(1, elapsedTime))
    }
    
    /**
     Finish the interactive transition.
     Will stop the interactive transition and animate from the
     current state to the **end** state
     - Parameter isAnimated: A boolean indicating if the completion is animated.
     */
    public func end(isAnimated: Bool = true) {
        guard isTransitioning else {
            return
        }
        
        guard isAnimated else {
            complete(isFinished: true)
            return
        }
        
        var t: TimeInterval = 0
        
        for a in animators {
            t = max(t, a.resume(at: elapsedTime * totalDuration, isReversed: false))
        }
        
        complete(after: t, isFinished: true)
    }
    
    /**
     Cancel the interactive transition.
     Will stop the interactive transition and animate from the
     current state to the **begining** state
     - Parameter isAnimated: A boolean indicating if the completion is animated.
     */
    public func cancel(isAnimated: Bool = true) {
        guard isTransitioning else {
            return
        }
        
        guard isAnimated else {
            complete(isFinished: false)
            return
        }
        
        var d: TimeInterval = 0
        
        for a in animators {
            var t = elapsedTime
            if t < 0 {
                t = -t
            }
            
            d = max(d, a.resume(at: t * totalDuration, isReversed: true))
        }
        
        complete(after: d, isFinished: false)
    }
    
    /**
     Override transition animations during an interactive animation.
     
     For example:
     
     Motion.shared.apply([.position(x:50, y:50)], to: view)
     
     will set the view's position to 50, 50
     - Parameter transitions: An Array of MotionTransitions.
     - Parameter to view: A UIView.
     */
    public func apply(transitions: [MotionTransition], to view: UIView) {
        guard isTransitioning else {
            return
        }
        
        let s = MotionTransitionState(transitions: transitions)
        let v = context.transitionPairedView(for: view) ?? view
        
        for a in animators {
            a.apply(state: s, to: v)
        }
    }
}

internal extension Motion {
    /**
     Load plugins, processors, animators, container, & context
     The transitionContainer must already be set.
     Subclasses should call context.set(fromViews: toViews) after
     inserting fromViews & toViews into the container
     */
    @objc
    func prepareTransition() {
        guard isTransitioning else {
            return
        }
        
        prepareTransitionContainer()
        prepareContext()
        preparePreprocessors()
        prepareAnimators()
        preparePlugins()
    }
    
    /// Prepares the transition fromView & toView pairs.
    @objc
    func prepareTransitionPairs() {
        guard isTransitioning else {
            return
        }
        
        for a in animators {
            let fv = context.fromViews.filter { (view) -> Bool in
                return a.canAnimate(view: view, isAppearing: false)
            }
            
            let tv = context.toViews.filter {
                return a.canAnimate(view: $0, isAppearing: true)
            }
            
            transitionPairs.append((fv, tv))
        }
        
        guard let tv = toView else {
            return
        }
        
        context.hide(view: tv)
    }
}

internal extension Motion {
    /// Executes the preprocessors' process function.
    func processContext() {
        guard isTransitioning else {
            return
        }
        
        for x in preprocessors {
            x.process(fromViews: context.fromViews, toViews: context.toViews)
        }
    }
    
    /**
     Animates the views. Subclasses should call `prepareTransition` &
     `prepareTransitionPairs` before calling `animate`.
     */
    @objc
    func animate() {
        guard .starting == state else {
            return
        }
        
        state = .animating
        
        if let tv = toView {
            context.unhide(view: tv)
        }
        
        for (fv, tv) in transitionPairs {
            for view in fv {
                context.hide(view: view)
            }
            
            for view in tv {
                context.hide(view: view)
            }
        }
        
        var t: TimeInterval = 0
        var b = false
        
        for (i, a) in animators.enumerated() {
            let d = a.animate(fromViews: transitionPairs[i].0, toViews: transitionPairs[i].1)
            
            if .infinity == d {
                b = true
            } else {
                t = max(t, d)
            }
        }
        
        totalDuration = t
        
        if b {
            update(elapsedTime: 0)
        } else {
            complete(after: t, isFinished: true)
        }
        
        updateContainerBackgroundColor()
        updateInsertOrder()
        
        
        fullScreenSnapshot?.removeFromSuperview()
        
    }
}

private extension Motion {
    /// Prepares the transition container.
    func prepareTransitionContainer() {
        guard let v = transitionContainer else {
            return
        }
        
        v.isUserInteractionEnabled = false
        
        // a view to hold all the animating views
        container = UIView(frame: v.bounds)
        v.addSubview(container!)
    }
    
    /// Prepares the preprocessors.
    func preparePreprocessors() {
        for x in [
            IgnoreSubviewTransitionsPreprocessor(),
            MatchPreprocessor(),
            SourcePreprocessor(),
            CascadePreprocessor(),
            TransitionPreprocessor(motion: self),
            DurationPreprocessor()] as [MotionPreprocessor] {
                preprocessors.append(x)
        }
        
        for x in preprocessors {
            x.context = context
        }
    }
    
    /// Prepares the animators.
    func prepareAnimators() {
        animators.append(MotionTransitionAnimator<MotionCoreAnimationViewContext>())
        
        if #available(iOS 10, tvOS 10, *) {
            animators.append(MotionTransitionAnimator<MotionViewPropertyViewContext>())
        }
        
        for v in animators {
            v.context = context
        }
    }
    
    /// Prepares the plugins.
    func preparePlugins() {
        for x in Motion.enabledPlugins.map({
            return $0.init()
        }) {
            plugins.append(x)
        }
        
        for plugin in plugins {
            preprocessors.append(plugin)
            animators.append(plugin)
        }
    }
}

private extension Motion {
    /// Updates the container background color.
    func updateContainerBackgroundColor() {
        if let v = containerBackgroundColor {
            container?.backgroundColor = v
            
        } else if !toOverFullScreen && !fromOverFullScreen {
            container?.backgroundColor = toView?.backgroundColor
        }
    }
    
    /// Updates the insertToViewFirst boolean for animators.
    func updateInsertOrder() {
        if fromOverFullScreen {
            insertToViewFirst = true
        }
        
        for v in animators {
            (v as? MotionHasInsertOrder)?.insertToViewFirst = insertToViewFirst
        }
    }
}

internal extension Motion {
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

internal extension Motion {
    // should call this after `prepareTransitionPairs` & before `processContext`
    func insert<T>(preprocessor: MotionPreprocessor, before: T.Type) {
        let i = preprocessors.index { $0 is T } ?? preprocessors.count
        preprocessor.context = context
        preprocessors.insert(preprocessor, at: i)
    }
}

public extension Motion {
    /// Turn off built-in animations for the next transition.
    func disableDefaultAnimationForNextTransition() {
        defaultAnimation = .none
    }
    
    /**
     Set the default animation for the next transition. This may override the
     root-view's motionTransitions during the transition.
     - Parameter animation: A MotionTransitionType.
     */
    func setAnimationForNextTransition(_ animation: MotionTransitionType) {
        defaultAnimation = animation
    }
    
    /**
     Set the container background color for the next transition.
     - Parameter _ color: An optional UIColor.
     */
    func setContainerBackgroundColorForNextTransition(_ color: UIColor?) {
        containerBackgroundColor = color
    }
}

public extension Motion {
    /**
     A helper transition function.
     - Parameter from: A UIViewController.
     - Parameter to: A UIViewController.
     - Parameter in view: A UIView.
     - Parameter completion: An optional completion handler.
     */
    func transition(from: UIViewController, to: UIViewController, in view: UIView, completion: ((Bool) -> Void)? = nil) {
        guard !isTransitioning else {
            return
        }
        
        isPresenting = true
        transitionContainer = view
        fromViewController = from
        toViewController = to
        completionCallback = completion
        
        start()
    }
}

private extension Motion {
    /// Starts the transition animation.
    func start() {
        guard .notified == state else {
            return
        }
        
        state = .starting
        
        prepareViewControllers()
        prepareSnapshotView()
        prepareTransition()
        prepareContext()
        prepareToView()
        prepareViewHierarchy()
        processContext()
        prepareTransitionPairs()
        processForAnimation()
    }
}

internal extension Motion {
    /// Resets the transition values.
    func resetTransition() {
        transitionContext = nil
        fromViewController = nil
        toViewController = nil
        containerBackgroundColor = nil
        isNavigationController = false
        isTabBarController = false
        forceNonInteractive = false
        insertToViewFirst = false
        defaultAnimation = .auto
    }
}

internal extension Motion {
    /// Prepares the from and to view controllers.
    func prepareViewControllers() {
        processStartTransitionDelegation(fromViewController: fromViewController, toViewController: toViewController)
    }
    
    /// Prepares the snapshot view, which hides any flashing that may occur.
    func prepareSnapshotView() {
        guard let v = transitionContainer else {
            return
        }
        
        fullScreenSnapshot = v.window?.snapshotView(afterScreenUpdates: true) ?? fromView?.snapshotView(afterScreenUpdates: true)
        (v.window ?? transitionContainer)?.addSubview(fullScreenSnapshot)
        
        if let v = fromViewController?.motionStoredSnapshot {
            v.removeFromSuperview()
            fromViewController?.motionStoredSnapshot = nil
        }
        
        if let v = toViewController?.motionStoredSnapshot {
            v.removeFromSuperview()
            toViewController?.motionStoredSnapshot = nil
        }
    }
    
    /// Prepares the MotionContext instance.
    func prepareContext() {
        guard let v = container else {
            return
        }
        
        guard let fv = fromView else {
            return
        }
        
        guard let tv = toView else {
            return
        }
        
        context = MotionContext(container: v)
        
        context.loadViewAlpha(rootView: tv)
        v.addSubview(tv)
        
        context.loadViewAlpha(rootView: fv)
        v.addSubview(fv)
    }
    
    /// Prepares the toView instance.
    func prepareToView() {
        guard let fv = fromView else {
            return
        }
        
        guard let tv = toView else {
            return
        }
        
        if let toViewController = toViewController, let transitionContext = transitionContext {
            tv.frame = transitionContext.finalFrame(for: toViewController)
        } else {
            tv.frame = fv.frame
        }
        
        tv.setNeedsLayout()
        tv.layoutIfNeeded()
    }
    
    /// Prepares the view hierarchy.
    func prepareViewHierarchy() {
        guard let fv = fromView else {
            return
        }
        
        guard let tv = toView else {
            return
        }
        
        context.set(fromViews: fv.flattenedViewHierarchy, toViews: tv.flattenedViewHierarchy)
    }
}

internal extension Motion {
    /// Processes the animations.
    func processForAnimation() {
        #if os(tvOS)
            animate()
            
        #else
            if isNavigationController {
                // When animating within navigationController, we have to dispatch later into the main queue.
                // otherwise snapshots will be pure white. Possibly a bug with UIKit
                Motion.async { [weak self] in
                    self?.animate()
                }
            } else {
                animate()
            }
            
        #endif
    }
    
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
        
        fvc.beginAppearanceTransition(false, animated: true)
        tvc.beginAppearanceTransition(true, animated: true)
        
        processForMotionDelegate(viewController: fvc) { [weak self] in
            guard let s = self else {
                return
            }
            
            $0.motion?(motion: s, willStartTransitionTo: tvc)
            $0.motionWillStartTransition?(motion: s)
        }
        
        processForMotionDelegate(viewController: tvc) { [weak self] in
            guard let s = self else {
                return
            }
            
            $0.motion?(motion: s, willStartTransitionFrom: fvc)
            $0.motionWillStartTransition?(motion: s)
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
        
        tvc.endAppearanceTransition()
        fvc.endAppearanceTransition()
        
        processForMotionDelegate(viewController: fvc) { [weak self] in
            guard let s = self else {
                return
            }
            
            $0.motion?(motion: s, didEndTransitionTo: tvc)
            $0.motionDidEndTransition?(motion: s)
        }
        
        processForMotionDelegate(viewController: tvc) { [weak self] in
            guard let s = self else {
                return
            }
            
            $0.motion?(motion: s, didEndTransitionFrom: fvc)
            $0.motionDidEndTransition?(motion: s)
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
            guard let s = self else {
                return
            }
            
            $0.motion?(motion: s, didCancelTransitionTo: tvc)
            $0.motionDidCancelTransition?(motion: s)
        }
        
        processForMotionDelegate(viewController: tvc) { [weak self] in
            guard let s = self else {
                return
            }
            
            $0.motion?(motion: s, didCancelTransitionFrom: fvc)
            $0.motionDidCancelTransition?(motion: s)
        }
        
        transitionContext?.finishInteractiveTransition()
    }
}

internal extension Motion {
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

extension Motion: UIViewControllerAnimatedTransitioning {
    /**
     The animation method that is used to coordinate the transition.
     - Parameter using transitionContext: A UIViewControllerContextTransitioning.
     */
    public func animateTransition(using context: UIViewControllerContextTransitioning) {
        guard !isTransitioning else {
            return
        }
        
        transitionContext = context
        fromViewController = fromViewController ?? context.viewController(forKey: .from)
        toViewController = toViewController ?? context.viewController(forKey: .to)
        transitionContainer = context.containerView
        
        start()
    }
    
    /**
     Returns the transition duration time interval.
     - Parameter using transitionContext: An optional UIViewControllerContextTransitioning.
     - Returns: A TimeInterval that is the total animation time including delays.
     */
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0 // Time will be updated dynamically.
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        isAnimating = !transitionCompleted
    }
}

extension Motion: UIViewControllerTransitioningDelegate {
    /// A reference to the interactive transitioning instance.
    var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
        return forceNonInteractive ? nil : self
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        fromViewController = fromViewController ?? presenting
        toViewController = toViewController ?? presented
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        fromViewController = fromViewController ?? dismissed
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
        isPresenting = .push == operation
        fromViewController = fromViewController ?? fromVC
        toViewController = toViewController ?? toVC
        isNavigationController = true
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
        
        isPresenting = toVCIndex > fromVCIndex
        fromViewController = fromViewController ?? fromVC
        toViewController = toViewController ?? toVC
        isTabBarController = true
        
        return self
    }
}

public typealias MotionCancelBlock = (Bool) -> Void

extension Motion {
    /**
     Executes a block of code asynchronously on the main thread.
     - Parameter execute: A block that is executed asynchronously on the main thread.
     */
    public class func async(_ execute: @escaping () -> Void) {
        Motion.delay(0, execute: execute)
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
                DispatchQueue.main.async(execute: execute)
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
