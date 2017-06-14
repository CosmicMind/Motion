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

public class MotionController: NSObject {
    /// A reference to the MotionContext.
    public internal(set) var context: MotionContext!

    /// A boolean indicating whether the transition interactive or not.
    public var isInteractive: Bool {
        return nil == displayLink
    }
    
    /// Progress of the current transition. 0 if no transition is happening.
    public internal(set) var elapsedTime: TimeInterval = 0 {
        didSet {
            guard isTransitioning else {
                return
            }
            
            updateTransitionObservers()
            
            guard isInteractive else {
                updatePlugins()
                return
            }
            
            updateAnimators()
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
    public internal(set) var container: UIView?

    /// UIKit's supplied transition container.
    internal var transitionContainer: UIView?

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
    internal var preprocessors: [MotionPreprocessor]?

    /// An Array of MotionAnimators used during a transition.
    internal var animators: [MotionAnimator]?

    /// An Array of MotionPlugins used during a transition.
    internal var plugins: [MotionPlugin]?

    /// The matching fromViews to toViews based on the motionIdentifier value.
    internal var transitionPairs: [(fromViews: [UIView], toViews: [UIView])]?

    /// Plugins that are enabled during the transition.
    internal static var enabledPlugins = [MotionPlugin.Type]()

    /// Initializer.
    internal override init() {}
}

public extension MotionController {
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

fileprivate extension MotionController {
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
        let v = elapsedTime * totalDuration
        
        animators?.forEach {
            $0.seek(to: v)
        }
    }
    
    /// Updates the plugins.
    func updatePlugins() {
        guard let p = plugins else {
            return
        }
        
        let v = elapsedTime * totalDuration
        
        for plugin in p where plugin.requirePerFrameCallback {
            plugin.seek(to: v)
        }
    }
}

fileprivate extension MotionController {
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

public extension MotionController {
    /**
     Updates the elapsed time for the interactive transition.
     - Parameter elapsedTime t: the current progress, must be between -1...1.
     */
    public func update(elapsedTime t: TimeInterval) {
        guard isTransitioning else {
            return
        }
        
        beginTime = nil
        elapsedTime = max(-1, min(1, t))
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
        
        var v: TimeInterval = 0
        animators?.forEach {
            v = max(v, $0.resume(at: elapsedTime * totalDuration, isReversed: false))
        }
        
        complete(after: v, isFinished: true)
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
        
        var v: TimeInterval = 0
        let et = elapsedTime
        
        animators?.forEach {
            var t = et
            
            if t < 0 {
                t = -t
            }
            
            v = max(v, $0.resume(at: t * totalDuration, isReversed: true))
        }
        
        complete(after: v, isFinished: false)
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
        
        animators?.forEach {
            $0.apply(state: s, to: v)
        }
    }
}

internal extension MotionController {
    /**
     Load plugins, processors, animators, container, & context
     The transitionContainer must already be set.
     Subclasses should call context.set(fromViews: toViews) after
     inserting fromViews & toViews into the container
     */
    func prepareTransition() {
        guard isTransitioning else {
            fatalError()
        }
        
        prepareTransitionContainer()
        prepareContext()
        preparePreprocessors()
        prepareAnimators()
        preparePlugins()
    }
    
    /// Prepares the transition fromView & toView pairs.
    func prepareTransitionPairs() {
        guard isTransitioning else {
            fatalError()
        }
        
        transitionPairs = [([UIView], [UIView])]()
        
        guard let v = animators else {
            return
        }
        
        for a in v {
            let fv = context.fromViews.filter { (view: UIView) -> Bool in
                return a.canAnimate(view: view, isAppearing: false)
            }
            
            let tv = context.toViews.filter { (view: UIView) -> Bool in
                return a.canAnimate(view: view, isAppearing: true)
            }
            
            transitionPairs?.append((fv, tv))
        }
    }
}

internal extension MotionController {
    /// Executes the preprocessors' process function.
    func processContext() {
        guard isTransitioning else {
            fatalError()
        }
        
        preprocessors?.forEach { [weak self] in
            guard let s = self else {
                return
            }
            
            $0.process(fromViews: s.context.fromViews, toViews: s.context.toViews)
        }
    }
    
    /**
     Animates the views. Subclasses should call `prepareTransition` &
     `prepareTransitionPairs` before calling `animate`.
     */
    func animate() {
        guard isTransitioning else {
            fatalError()
        }
        
        transitionPairs?.forEach { [weak self] in
            guard let s = self else {
                return
            }
            
            for view in $0.fromViews {
                s.context.hide(view: view)
            }
            
            for view in $0.toViews {
                s.context.hide(view: view)
            }
        }
        
        var t: TimeInterval = 0
        var v = false
        
        if let a = animators, let tp = transitionPairs {
            for (i, x) in a.enumerated() {
                
                
                let d = x.animate(fromViews: tp[i].0, toViews: tp[i].1)
                
                if d == .infinity {
                    v = true
                } else {
                    t = max(t, d)
                }
            }
        }
        
        totalDuration = t
        
        if v {
            update(elapsedTime: 0)
        } else {
            complete(after: t, isFinished: true)
        }
    }
    
    /**
     Complete the transition.
     - Parameter after: A TimeInterval.
     - Parameter isFinished: A Boolean indicating if the transition 
     has completed.
     */
    func complete(after: TimeInterval, isFinished: Bool) {
        guard isTransitioning else {
            fatalError()
        }
        
        if after <= 0.001 {
            complete(isFinished: isFinished)
            return
        }
        
        let v = (isFinished ? elapsedTime : 1 - elapsedTime) * totalDuration
        self.isFinished = isFinished
        self.currentAnimationDuration = after + v
        self.beginTime = CACurrentMediaTime() - v
    }
    
    /**
     Complete the transition.
     - Parameter isFinished: A Boolean indicating if the transition
     has completed.
    */
    func complete(isFinished: Bool) {
        defer {
            
            animators?.forEach {
                $0.clean()
            }
            
            transitionContainer?.isUserInteractionEnabled = true
            
            transitionPairs = nil
            transitionObservers = nil
            transitionContainer = nil
            completionCallback = nil
            container = nil
            preprocessors = nil
            animators = nil
            plugins = nil
            context = nil
            beginTime = nil
            elapsedTime = 0
            totalDuration = 0
        }
        
        guard isTransitioning else {
            return
        }
        
        completionCallback?(isFinished)
    }
}

fileprivate extension MotionController {
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
    
    /// Prepares the context.
    func prepareContext() {
        guard let v = container else {
            return
        }
        
        context = MotionContext(container: v)
    }
    
    /// Prepares the preprocessors.
    func preparePreprocessors() {
        preprocessors = [
            IgnoreSubviewTransitionsPreprocessor(),
            MatchPreprocessor(),
            SourcePreprocessor(),
            CascadePreprocessor(),
            DurationPreprocessor()
        ]
        
        for v in preprocessors! {
            v.context = context
        }
    }
    
    /// Prepares the animators.
    func prepareAnimators() {
        animators = [
            MotionDefaultAnimator<MotionCoreAnimationViewContext>()
        ]
        
        if #available(iOS 10, tvOS 10, *) {
            animators?.append(MotionDefaultAnimator<MotionViewPropertyViewContext>())
        }
        
        for v in animators! {
            v.context = context
        }
    }
    
    /// Prepares the plugins.
    func preparePlugins() {
        plugins = Motion.enabledPlugins.map({
            return $0.init()
        })
        
        for plugin in plugins! {
            preprocessors?.append(plugin)
            animators?.append(plugin)
        }
    }
}

internal extension MotionController {
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

internal extension MotionController {
    // should call this after `prepareTransitionPairs` & before `processContext`
    func insert<T>(preprocessor: MotionPreprocessor, before: T.Type) {
        guard var v = preprocessors else {
            return
        }
        
        let i = v.index { $0 is T } ?? v.count
        preprocessor.context = context
        v.insert(preprocessor, at: i)
    }
}
