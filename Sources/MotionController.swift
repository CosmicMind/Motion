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

/// Base class for managing a Motion transition
public class MotionController: NSObject {
  // MARK: Properties
  /// context object holding transition informations
  public internal(set) var context: MotionContext!
  /// whether or not we are handling transition interactively
  public var interactive: Bool {
    return displayLink == nil
  }
  /// progress of the current transition. 0 if no transition is happening
  public internal(set) var progress: Double = 0 {
    didSet {
      if isTransitioning {
        if let progressUpdateObservers = progressUpdateObservers {
          for observer in progressUpdateObservers {
            observer.motionDidUpdateProgress(progress: progress)
          }
        }

        let elapsedTime = progress * totalDuration
        if interactive {
          for animator in animators {
            animator.seek(to: elapsedTime)
          }
        } else {
          for plugin in plugins where plugin.requirePerFrameCallback {
            plugin.seek(to: elapsedTime)
          }
        }
      }
    }
  }
  /// whether or not we are doing a transition
  public var isTransitioning: Bool {
    return transitionContainer != nil
  }

  /// container we created to hold all animating views, will be a subview of the
  /// transitionContainer when isTransitioning
  public internal(set) var container: UIView!

  /// this is the container supplied by UIKit
  internal var transitionContainer: UIView!

  internal var completionCallback: ((Bool) -> Void)?

  internal var displayLink: CADisplayLink?
  internal var progressUpdateObservers: [MotionProgressUpdateObserver]?

  /// max duration needed by the default animator and plugins
  public internal(set) var totalDuration: TimeInterval = 0.0

  /// current animation complete duration.
  /// (differs from totalDuration because this one could be the duration for finishing interactive transition)
  internal var duration: TimeInterval = 0.0
  internal var beginTime: TimeInterval? {
    didSet {
      if beginTime != nil {
        if displayLink == nil {
          displayLink = CADisplayLink(target: self, selector: #selector(displayUpdate(_:)))
          displayLink!.add(to: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        }
      } else {
        displayLink?.isPaused = true
        displayLink?.remove(from: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        displayLink = nil
      }
    }
  }
  func displayUpdate(_ link: CADisplayLink) {
    if isTransitioning, duration > 0, let beginTime = beginTime {
      let elapsedTime = CACurrentMediaTime() - beginTime

      if elapsedTime > duration {
        progress = finishing ? 1 : 0
        self.beginTime = nil
        complete(finished: finishing)
      } else {
        var completed = elapsedTime / totalDuration
        if !finishing {
          completed = 1 - completed
        }
        completed = max(0, min(1, completed))
        progress = completed
      }
    }
  }

  internal var finishing: Bool = true

  internal var processors: [MotionPreprocessor]!
  internal var animators: [MotionAnimator]!
  internal var plugins: [MotionPlugin]!

  internal var animatingViews: [(fromViews: [UIView], toViews: [UIView])]!

  internal static var enabledPlugins: [MotionPlugin.Type] = []

  internal override init() {}
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
    self.progress = max(-1, min(1, progress))
  }

  /**
   Finish the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **end** state
   */
  public func end(animate: Bool = true) {
    guard isTransitioning else { return }
    if !animate {
      self.complete(finished:true)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in self.animators {
      maxTime = max(maxTime, animator.resume(at: self.progress * self.totalDuration, isReversed: false))
    }
    self.complete(after: maxTime, finishing: true)
  }

  /**
   Cancel the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **begining** state
   */
  public func cancel(animate: Bool = true) {
    guard isTransitioning else { return }
    if !animate {
      self.complete(finished:false)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in self.animators {
      var adjustedProgress = self.progress
      if adjustedProgress < 0 {
        adjustedProgress = -adjustedProgress
      }
      maxTime = max(maxTime, animator.resume(at: adjustedProgress * self.totalDuration, isReversed: true))
    }
    self.complete(after: maxTime, finishing: false)
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
  func observeForProgressUpdate(observer: MotionProgressUpdateObserver) {
    if progressUpdateObservers == nil {
      progressUpdateObservers = []
    }
    progressUpdateObservers!.append(observer)
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
    animatingViews = [([UIView], [UIView])]()
    for animator in animators {
      let currentFromViews = context.fromViews.filter { (view: UIView) -> Bool in
        return animator.canAnimate(view: view, isAppearing: false)
      }
      let currentToViews = context.toViews.filter { (view: UIView) -> Bool in
        return animator.canAnimate(view: view, isAppearing: true)
      }
      animatingViews.append((currentFromViews, currentToViews))
    }
  }

  /// Actually animate the views
  /// subclass should call `prepareForTransition` & `prepareForAnimation` before calling `animate`
  func animate() {
    guard isTransitioning else { fatalError() }
    for (currentFromViews, currentToViews) in animatingViews {
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
      let duration = animator.animate(fromViews: animatingViews[i].0,
                                      toViews: animatingViews[i].1)
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
      complete(after: totalDuration, finishing: true)
    }
  }

  func complete(after: TimeInterval, finishing: Bool) {
    guard isTransitioning else { fatalError() }
    if after <= 0.001 {
      complete(finished: finishing)
      return
    }
    let elapsedTime = (finishing ? progress : 1 - progress) * totalDuration
    self.finishing = finishing
    self.duration = after + elapsedTime
    self.beginTime = CACurrentMediaTime() - elapsedTime
  }

  func complete(finished: Bool) {
    guard isTransitioning else { fatalError() }
    for animator in animators {
      animator.clean()
    }

    transitionContainer!.isUserInteractionEnabled = true

    let completion = completionCallback

    animatingViews = nil
    progressUpdateObservers = nil
    transitionContainer = nil
    completionCallback = nil
    container = nil
    processors = nil
    animators = nil
    plugins = nil
    context = nil
    beginTime = nil
    progress = 0
    totalDuration = 0

    completion?(finished)
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
