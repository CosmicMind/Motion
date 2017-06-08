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
    public internal(set) var container: UIView!

    /// UIKit's supplied transition container.
    internal var transitionContainer: UIView!

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
    internal var processors: [MotionPreprocessor]!

    /// An Array of MotionAnimators used during a transition.
    internal var animators: [MotionAnimator]!

    /// An Array of MotionPlugins used during a transition.
    internal var plugins: [MotionPlugin]!

    /// The matching from-views to to-views based on the motionIdentifier value.
    internal var transitionPairs: [(fromViews: [UIView], toViews: [UIView])]!

    /// Plugins that are enabled during the transition.
    internal static var enabledPlugins = [MotionPlugin.Type]()

    /// Initializer.
    internal override init() {}
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
        for a in animators {
            a.seek(to: v)
        }
    }
    
    /// Updates the plugins.
    func updatePlugins() {
        let v = elapsedTime * totalDuration
        for p in plugins where p.requirePerFrameCallback {
            p.seek(to: v)
        }
    }
}

fileprivate extension MotionController {
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
  // MARK: Interactive Transition

  /**
   Update the progress for the interactive transition.
   - Parameters:
   - progress: the current progress, must be between -1...1
   */
  public func update(progress: Double) {
    guard isTransitioning else { return }
    self.beginTime = nil
    self.elapsedTime = max(-1, min(1, progress))
  }

  /**
   Finish the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **end** state
   */
  public func end(animate: Bool = true) {
    guard isTransitioning else { return }
    if !animate {
      self.complete(isFinished:true)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in self.animators {
      maxTime = max(maxTime, animator.resume(at: self.elapsedTime * self.totalDuration, isReversed: false))
    }
    self.complete(after: maxTime, isFinished: true)
  }

  /**
   Cancel the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **begining** state
   */
  public func cancel(animate: Bool = true) {
    guard isTransitioning else { return }
    if !animate {
      self.complete(isFinished:false)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in self.animators {
      var adjustedProgress = self.elapsedTime
      if adjustedProgress < 0 {
        adjustedProgress = -adjustedProgress
      }
      maxTime = max(maxTime, animator.resume(at: adjustedProgress * self.totalDuration, isReversed: true))
    }
    self.complete(after: maxTime, isFinished: false)
  }

  /**
   Override modifiers during an interactive animation.

   For example:

   Motion.shared.apply([.position(x:50, y:50)], to:view)

   will set the view's position to 50, 50
   - Parameters:
   - modifiers: the modifiers to override
   - view: the view to override to
   */
  public func apply(transitions: [MotionTransition], to view: UIView) {
    guard isTransitioning else { return }
    let targetState = MotionTargetState(transitions: transitions)
    if let otherView = self.context.pairedView(for: view) {
      for animator in self.animators {
        animator.apply(state: targetState, to: otherView)
      }
    }
    for animator in self.animators {
      animator.apply(state: targetState, to: view)
    }
  }
}

public extension MotionController {
  // MARK: Observe Progress

  /**
   Receive callbacks on each animation frame.
   Observers will be cleaned when transition completes

   - Parameters:
   - observer: the observer
   */
  func observeForProgressUpdate(observer: MotionTransitionObserver) {
    if transitionObservers == nil {
      transitionObservers = []
    }
    transitionObservers!.append(observer)
  }
}

// internal methods for transition
internal extension MotionController {
  /// Load plugins, processors, animators, container, & context
  /// must have transitionContainer set already
  /// subclass should call context.set(fromViews:toViews) after inserting fromViews & toViews into the container
  func prepareForTransition() {
    guard isTransitioning else { fatalError() }
    plugins = Motion.enabledPlugins.map({ return $0.init() })
    processors = [
      IgnoreSubviewModifiersPreprocessor(),
      MatchPreprocessor(),
      SourcePreprocessor(),
      CascadePreprocessor(),
      DurationPreprocessor()
    ]
    animators = [
      MotionDefaultAnimator<MotionCoreAnimationViewContext>()
    ]

    if #available(iOS 10, tvOS 10, *) {
      animators.append(MotionDefaultAnimator<MotionViewPropertyViewContext>())
    }

    // There is no covariant in Swift, so we need to add plugins one by one.
    for plugin in plugins {
      processors.append(plugin)
      animators.append(plugin)
    }

    transitionContainer.isUserInteractionEnabled = false

    // a view to hold all the animating views
    container = UIView(frame: transitionContainer.bounds)
    transitionContainer.addSubview(container)

    context = MotionContext(container:container)

    for processor in processors {
      processor.context = context
    }
    for animator in animators {
      animator.context = context
    }
  }

    
    
  func processContext() {
    guard isTransitioning else { fatalError() }
    for processor in processors {
      processor.process(fromViews: context.fromViews, toViews: context.toViews)
    }
  }

  func prepareForAnimation() {
    guard isTransitioning else { fatalError() }
    transitionPairs = [([UIView], [UIView])]()
    for animator in animators {
      let currentFromViews = context.fromViews.filter { (view: UIView) -> Bool in
        return animator.canAnimate(view: view, isAppearing: false)
      }
      let currentToViews = context.toViews.filter { (view: UIView) -> Bool in
        return animator.canAnimate(view: view, isAppearing: true)
      }
      transitionPairs.append((currentFromViews, currentToViews))
    }
  }

  /// Actually animate the views
  /// subclass should call `prepareForTransition` & `prepareForAnimation` before calling `animate`
  func animate() {
    guard isTransitioning else { fatalError() }
    for (currentFromViews, currentToViews) in transitionPairs {
      // auto hide all animated views
      for view in currentFromViews {
        context.hide(view: view)
      }
      for view in currentToViews {
        context.hide(view: view)
      }
    }

    var totalDuration: TimeInterval = 0
    var animatorWantsInteractive = false
    for (i, animator) in animators.enumerated() {
      let duration = animator.animate(fromViews: transitionPairs[i].0,
                                      toViews: transitionPairs[i].1)
      if duration == .infinity {
        animatorWantsInteractive = true
      } else {
        totalDuration = max(totalDuration, duration)
      }
    }

    self.totalDuration = totalDuration
    if animatorWantsInteractive {
      update(progress: 0)
    } else {
      complete(after: totalDuration, isFinished: true)
    }
  }

  func complete(after: TimeInterval, isFinished: Bool) {
    guard isTransitioning else { fatalError() }
    if after <= 0.001 {
      complete(isFinished: isFinished)
      return
    }
    let v = (isFinished ? elapsedTime : 1 - elapsedTime) * totalDuration
    self.isFinished = isFinished
    self.currentAnimationDuration = after + v
    self.beginTime = CACurrentMediaTime() - v
  }

  func complete(isFinished: Bool) {
    guard isTransitioning else { fatalError() }
    for animator in animators {
      animator.clean()
    }

    transitionContainer!.isUserInteractionEnabled = true

    let completion = completionCallback

    transitionPairs = nil
    transitionObservers = nil
    transitionContainer = nil
    completionCallback = nil
    container = nil
    processors = nil
    animators = nil
    plugins = nil
    context = nil
    beginTime = nil
    elapsedTime = 0
    totalDuration = 0

    completion?(isFinished)
  }
}

// MARK: Plugin Support
internal extension MotionController {
  static func isEnabled(plugin: MotionPlugin.Type) -> Bool {
    return enabledPlugins.index(where: { return $0 == plugin}) != nil
  }

  static func enable(plugin: MotionPlugin.Type) {
    disable(plugin: plugin)
    enabledPlugins.append(plugin)
  }

  static func disable(plugin: MotionPlugin.Type) {
    if let index = enabledPlugins.index(where: { return $0 == plugin}) {
      enabledPlugins.remove(at: index)
    }
  }
}

internal extension MotionController {
  // should call this after `prepareForTransition` & before `processContext`
  func insert<T>(preprocessor: MotionPreprocessor, before: T.Type) {
    let processorIndex = processors.index {
      $0 is T
      } ?? processors.count
    preprocessor.context = context
    processors.insert(preprocessor, at: processorIndex)
  }
}
