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

@objc public enum MotionTransitionAnimationDirection : Int
{
  case left
  case right
  case up
  case down
}

@objc public enum MotionTransitionAnimationTyp : Int
{
  case none
  case auto
  case push
  case pull
  case cover
  case uncover
  case slide
  case zoomSlide
  case pageIn
  case pageOut
  case fade
  case zoom
  case zoomOut
}

public enum MotionTransitionAnimationType {

  case none
  case auto
  case push(direction: MotionTransitionAnimationDirection)
  case pull(direction: MotionTransitionAnimationDirection)
  case cover(direction: MotionTransitionAnimationDirection)
  case uncover(direction: MotionTransitionAnimationDirection)
  case slide(direction: MotionTransitionAnimationDirection)
  case zoomSlide(direction: MotionTransitionAnimationDirection)
  case pageIn(direction: MotionTransitionAnimationDirection)
  case pageOut(direction: MotionTransitionAnimationDirection)
  case fade
  case zoom
  case zoomOut
  
  indirect case selectBy(presenting: MotionTransitionAnimationType, dismissing: MotionTransitionAnimationType)
  
  /**
   Sets the presenting and dismissing modifiers.
   - Parameter presenting: A MotionTransitionAnimationType.
   - Returns: A MotionTransitionAnimationType.
   */
  public static func autoReverse(presenting: MotionTransitionAnimationType) -> MotionTransitionAnimationType {
    return .selectBy(presenting: presenting, dismissing: presenting.reversed())
  }
  
  /// Returns a reversal transition.
  func reversed() -> MotionTransitionAnimationType {
    switch self {
    case .push(direction: .up):
      return .pull(direction: .down)
      
    case .push(direction: .right):
      return .pull(direction: .left)
      
    case .push(direction: .down):
      return .pull(direction: .up)
      
    case .push(direction: .left):
      return .pull(direction: .right)
      
    case .pull(direction: .up):
      return .push(direction: .down)
      
    case .pull(direction: .right):
      return .push(direction: .left)
      
    case .pull(direction: .down):
      return .push(direction: .up)
      
    case .pull(direction: .left):
      return .push(direction: .right)
      
    case .cover(direction: .up):
      return .uncover(direction: .down)
      
    case .cover(direction: .right):
      return .uncover(direction: .left)
      
    case .cover(direction: .down):
      return .uncover(direction: .up)
      
    case .cover(direction: .left):
      return .uncover(direction: .right)
      
    case .uncover(direction: .up):
      return .cover(direction: .down)
      
    case .uncover(direction: .right):
      return .cover(direction: .left)
      
    case .uncover(direction: .down):
      return .cover(direction: .up)
      
    case .uncover(direction: .left):
      return .cover(direction: .right)
      
    case .slide(direction: .up):
      return .slide(direction: .down)
      
    case .slide(direction: .down):
      return .slide(direction: .up)
      
    case .slide(direction: .left):
      return .slide(direction: .right)
      
    case .slide(direction: .right):
      return .slide(direction: .left)
      
    case .zoomSlide(direction: .up):
      return .zoomSlide(direction: .down)
      
    case .zoomSlide(direction: .down):
      return .zoomSlide(direction: .up)
      
    case .zoomSlide(direction: .left):
      return .zoomSlide(direction: .right)
      
    case .zoomSlide(direction: .right):
      return .zoomSlide(direction: .left)
      
    case .pageIn(direction: .up):
      return .pageOut(direction: .down)
      
    case .pageIn(direction: .right):
      return .pageOut(direction: .left)
      
    case .pageIn(direction: .down):
      return .pageOut(direction: .up)
      
    case .pageIn(direction: .left):
      return .pageOut(direction: .right)
      
    case .pageOut(direction: .up):
      return .pageIn(direction: .down)
      
    case .pageOut(direction: .right):
      return .pageIn(direction: .left)
      
    case .pageOut(direction: .down):
      return .pageIn(direction: .up)
      
    case .pageOut(direction: .left):
      return .pageIn(direction: .right)
      
    case .zoom:
      return .zoomOut
      
    case .zoomOut:
      return .zoom
      
    default:
      return self
    }
  }
}

class TransitionPreprocessor: MotionCorePreprocessor {
  /**
   Processes the transitionary views.
   - Parameter fromViews: An Array of UIViews.
   - Parameter toViews: An Array of UIViews.
   */
  override func process(fromViews: [UIView], toViews: [UIView]) {
    guard let m = motion else {
      return
    }
    
    guard let tv = m.toView else {
      return
    }
    
    guard let fv = m.fromView else {
      return
    }
    
    var defaultAnimation = m.defaultAnimation
    let isNavigationController = m.isNavigationController
    let isTabBarController = m.isTabBarController
    let toViewController = m.toViewController
    let fromViewController = m.fromViewController
    let isPresenting = m.isPresenting
    let fromOverFullScreen = m.fromOverFullScreen
    let toOverFullScreen = m.toOverFullScreen
    let animators = m.animators
    
    if case .auto = defaultAnimation {
      if isNavigationController, let navAnim = toViewController?.navigationController?.motionNavigationTransitionType {
        defaultAnimation = navAnim
        
      } else if isTabBarController, let tabAnim = toViewController?.tabBarController?.motionTabBarTransitionType {
        defaultAnimation = tabAnim
        
      } else if let modalAnim = (isPresenting ? toViewController : fromViewController)?.motionTransitionType {
        defaultAnimation = modalAnim
      }
    }
    
    if case .selectBy(let presentAnim, let dismissAnim) = defaultAnimation {
      defaultAnimation = isPresenting ? presentAnim : dismissAnim
    }
    
    if case .auto = defaultAnimation {
      if animators.contains(where: {
        $0.canAnimate(view: tv, isAppearing: true) || $0.canAnimate(view: fv, isAppearing: false)
      }) {
        defaultAnimation = .none
        
      } else if isNavigationController {
        defaultAnimation = isPresenting ? .push(direction: .left) : .pull(direction: .right)
        
      } else if isTabBarController {
        defaultAnimation = isPresenting ? .slide(direction: .left) : .slide(direction: .right)
        
      } else {
        defaultAnimation = .fade
      }
    }
    
    if case .none = defaultAnimation {
      return
    }
    
    context[fv] = [.timingFunction(.standard), .duration(0.35)]
    context[tv] = [.timingFunction(.standard), .duration(0.35)]
    
    let shadowState: [MotionModifier] = [.shadow(opacity: 0.5),
                                         .shadow(color: .black),
                                         .shadow(radius: 5),
                                         .shadow(offset: .zero),
                                         .masksToBounds(false)]
    
    switch defaultAnimation {
    case .push(let direction):
      context.insertToViewFirst = false
      
      context[tv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: true)),
                                       .shadow(opacity: 0),
                                       .beginWith(modifiers: shadowState),
                                       .timingFunction(.deceleration)])
      
      context[fv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: false) / 3),
                                       .overlay(color: .black, opacity: 0.1),
                                       .timingFunction(.deceleration)])
      
    case .pull(let direction):
      context.insertToViewFirst = true
      
      context[fv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: false)),
                                       .shadow(opacity: 0),
                                       .beginWith(modifiers: shadowState)])
      
      context[tv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: true) / 3),
                                       .overlay(color: .black, opacity: 0.1)])
      
    case .slide(let direction):
      context[fv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: false))])
      
      context[tv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: true))])
      
    case .zoomSlide(let direction):
      context[fv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: false)), .scale(0.8)])
      
      context[tv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: true)), .scale(0.8)])
      
    case .cover(let direction):
      context.insertToViewFirst = false
      
      context[tv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: true)),
                                       .shadow(opacity: 0),
                                       .beginWith(modifiers: shadowState),
                                       .timingFunction(.deceleration)])
      
      context[fv]!.append(contentsOf: [.overlay(color: .black, opacity: 0.1),
                                       .timingFunction(.deceleration)])
      
    case .uncover(let direction):
      context.insertToViewFirst = true
      
      context[fv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: false)),
                                       .shadow(opacity: 0),
                                       .beginWith(modifiers: shadowState)])
      
      context[tv]!.append(contentsOf: [.overlay(color: .black, opacity: 0.1)])
      
    case .pageIn(let direction):
      context.insertToViewFirst = false
      
      context[tv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: true)),
                                       .shadow(opacity: 0),
                                       .beginWith(modifiers: shadowState),
                                       .timingFunction(.deceleration)])
      
      context[fv]!.append(contentsOf: [.scale(0.7),
                                       .overlay(color: .black, opacity: 0.1),
                                       .timingFunction(.deceleration)])
      
    case .pageOut(let direction):
      context.insertToViewFirst = true
      
      context[fv]!.append(contentsOf: [.translate(shift(direction: direction, isAppearing: false)),
                                       .shadow(opacity: 0),
                                       .beginWith(modifiers: shadowState)])
      
      context[tv]!.append(contentsOf: [.scale(0.7),
                                       .overlay(color: .black, opacity: 0.1)])
      
    case .fade:
      // TODO: clean up this. overFullScreen logic shouldn't be here
      if !(fromOverFullScreen && !isPresenting) {
        context[tv] = [.fadeOut]
      }
      
      #if os(tvOS)
      context[fromView] = [.fade]
      #else
      if (!isPresenting && toOverFullScreen) || !fv.isOpaque || (fv.backgroundColor?.alphaComponent ?? 1) < 1 {
        context[fv] = [.fadeOut]
      }
      #endif
      
      context[tv]!.append(.durationMatchLongest)
      context[fv]!.append(.durationMatchLongest)
      
    case .zoom:
      context.insertToViewFirst = true
      
      context[fv]!.append(contentsOf: [.scale(1.3), .fadeOut])
      context[tv]!.append(contentsOf: [.scale(0.7)])
      
    case .zoomOut:
      context.insertToViewFirst = false
      
      context[tv]!.append(contentsOf: [.scale(1.3), .fadeOut])
      context[fv]!.append(contentsOf: [.scale(0.7)])
      
    default:
      fatalError("Not implemented")
    }
  }
  
  /**
   Shifts the transition by a given size.
   - Parameter direction: A MotionTransitionAnimationType.Direction.
   - Parameter isAppearing: A boolean indicating whether it is appearing
   or not.
   - Parameter size: An optional CGSize.
   - Parameter transpose: A boolean indicating to change the `x` point for `y`
   and `y` point for `x`.
   - Returns: A CGPoint.
   */
  func shift(direction: MotionTransitionAnimationDirection, isAppearing: Bool, size: CGSize? = nil, transpose: Bool = false) -> CGPoint {
    let size = size ?? context.container.bounds.size
    let point: CGPoint
    
    switch direction {
    case .left, .right:
      point = CGPoint(x: (.right == direction) == isAppearing ? -size.width : size.width, y: 0)
      
    case .up, .down:
      point = CGPoint(x: 0, y: (.down == direction) == isAppearing ? -size.height : size.height)
    }
    
    if transpose {
      return CGPoint(x: point.y, y: point.x)
    }
    
    return point
  }
}
