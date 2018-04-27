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

extension MotionTransition {
  /// Starts the transition animation.
  func start() {
    guard .notified == state else {
      return
    }
    
    state = .starting
    
    prepareViewFrame()
    prepareViewControllers()
    prepareSnapshotView()
    preparePlugins()
    preparePreprocessors()
    prepareAnimators()
    
    for v in plugins {
      preprocessors.append(v)
      animators.append(v)
    }
    
    prepareTransitionContainer()
    prepareContainer()
    prepareContext()
    
    prepareViewHierarchy()
    prepareAnimatingViews()
    prepareToView()
    
    processPreprocessors()
    processAnimation()
  }
}

fileprivate extension MotionTransition {
  /// Prepares the views frames.
  func prepareViewFrame() {
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
  
  /// Prepares the from and to view controllers.
  func prepareViewControllers() {
    processStartTransitionDelegation(fromViewController: fromViewController, toViewController: toViewController)
  }
  
  /// Prepares the snapshot view, which hides any flashing that may occur.
  func prepareSnapshotView() {
    fullScreenSnapshot = transitionContainer?.window?.snapshotView(afterScreenUpdates: false) ?? fromView?.snapshotView(afterScreenUpdates: false)
    
    if let v = fullScreenSnapshot {
      (transitionContainer?.window ?? transitionContainer)?.addSubview(v)
    }
    
    if let v = fromViewController?.motionStoredSnapshot {
      v.removeFromSuperview()
      fromViewController?.motionStoredSnapshot = nil
    }
    
    if let v = toViewController?.motionStoredSnapshot {
      v.removeFromSuperview()
      toViewController?.motionStoredSnapshot = nil
    }
  }
  
  /// Prepares the plugins.
  func preparePlugins() {
    plugins = MotionTransition.enabledPlugins.map {
      return $0.init()
    }
  }
  
  /// Prepares the preprocessors.
  func preparePreprocessors() {
    preprocessors = [IgnoreSubviewTransitionsPreprocessor(),
                     ConditionalPreprocessor(),
                     TransitionPreprocessor(),
                     MatchPreprocessor(),
                     SourcePreprocessor(),
                     CascadePreprocessor()]
  }
  
  /// Prepares the animators.
  func prepareAnimators() {
    animators = [MotionCoreAnimator<MotionCoreAnimationViewContext>()]
    
    if #available(iOS 10, tvOS 10, *) {
      animators.append(MotionCoreAnimator<MotionViewPropertyViewContext>())
    }
  }
  
  /// Prepares the transition container.
  func prepareTransitionContainer() {
    transitionContainer?.isUserInteractionEnabled = isUserInteractionEnabled
  }
  
  /// Prepares the view that holds all the animating views.
  func prepareContainer() {
    container = UIView(frame: transitionContainer?.bounds ?? .zero)
    
    if !toOverFullScreen && !fromOverFullScreen {
      container.backgroundColor = containerBackgroundColor
    }
    
    transitionContainer?.addSubview(container)
  }
  
  /// Prepares the MotionContext instance.
  func prepareContext() {
    context = MotionContext(container: container)
    
    for v in preprocessors {
      v.motion = self
    }
    
    for v in animators {
      v.motion = self
    }
    
    guard let tv = toView else {
      return
    }
    
    guard let fv = fromView else {
      return
    }
    
    context.loadViewAlpha(rootView: tv)
    container.addSubview(tv)
    
    context.loadViewAlpha(rootView: fv)
    container.addSubview(fv)
    
    tv.setNeedsUpdateConstraints()
    tv.updateConstraintsIfNeeded()
    tv.setNeedsLayout()
    tv.layoutIfNeeded()
    
    context.set(fromViews: fv.flattenedViewHierarchy, toViews: tv.flattenedViewHierarchy)
  }
  
  /// Prepares the view hierarchy.
  func prepareViewHierarchy() {
    if (.auto == viewOrderStrategy && !isPresenting && !isTabBarController) ||
      .sourceViewOnTop == viewOrderStrategy {
      context.insertToViewFirst = true
    }
    
    for v in preprocessors {
      v.process(fromViews: context.fromViews, toViews: context.toViews)
    }
  }
  
  /// Prepares the transition fromView & toView pairs.
  func prepareAnimatingViews() {
    animatingFromViews = context.fromViews.filter { (view) -> Bool in
      for animator in animators {
        if animator.canAnimate(view: view, isAppearing: false) {
          return true
        }
      }
      return false
    }
    
    animatingToViews = context.toViews.filter { (view) -> Bool in
      for animator in animators {
        if animator.canAnimate(view: view, isAppearing: true) {
          return true
        }
      }
      return false
    }
  }
  
  /// Prepares the to view.
  func prepareToView() {
    guard let tv = toView else {
      return
    }
    
    context.hide(view: tv)
  }
}

fileprivate extension MotionTransition {
  /// Executes the preprocessors' process function.
  func processPreprocessors() {
    for v in preprocessors {
      v.process(fromViews: context.fromViews, toViews: context.toViews)
    }
  }
  
  /// Processes the animations.
  func processAnimation() {
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
}

