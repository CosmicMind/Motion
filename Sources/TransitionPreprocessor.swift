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

public enum MotionTransitionType {
  public enum Direction: MotionStringConvertible {
    case left, right, up, down
    public static func from(node: ExprNode) -> Direction? {
      switch node.name {
      case "left": return .left
      case "right": return .right
      case "up": return .up
      case "down": return .down
      default: return nil
      }
    }
  }
  case auto
  case push(direction: Direction)
  case pull(direction: Direction)
  case cover(direction: Direction)
  case uncover(direction: Direction)
  case slide(direction: Direction)
  case zoomSlide(direction: Direction)
  case pageIn(direction: Direction)
  case pageOut(direction: Direction)
  case fade
  case zoom
  case zoomOut

  indirect case selectBy(presenting: MotionTransitionType, dismissing: MotionTransitionType)

  public static func autoReverse(presenting: MotionTransitionType) -> MotionTransitionType {
    return .selectBy(presenting: presenting, dismissing: presenting.reversed())
  }

  case none

  func reversed() -> MotionTransitionType {
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

  public var label: String? {
    let mirror = Mirror(reflecting: self)
    if let associated = mirror.children.first {
      let valuesMirror = Mirror(reflecting: associated.value)
      if !valuesMirror.children.isEmpty {
        let parameters = valuesMirror.children.map { ".\($0.value)" }.joined(separator: ",")
        return ".\(associated.label ?? "")(\(parameters))"
      }
      return ".\(associated.label ?? "")(.\(associated.value))"
    }
    return ".\(self)"
  }
}

extension MotionTransitionType: MotionStringConvertible {
  public static func from(node: ExprNode) -> MotionTransitionType? {
    let name: String = node.name
    let parameters: [ExprNode] = (node as? CallNode)?.arguments ?? []

    switch name {
    case "auto":
      return .auto
    case "push":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .push(direction: direction)
      }
    case "pull":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .pull(direction: direction)
      }
    case "cover":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .cover(direction: direction)
      }
    case "uncover":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .uncover(direction: direction)
      }
    case "slide":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .slide(direction: direction)
      }
    case "zoomSlide":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .zoomSlide(direction: direction)
      }
    case "pageIn":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .pageIn(direction: direction)
      }
    case "pageOut":
      if let node = parameters.get(0), let direction = Direction.from(node: node) {
        return .pageOut(direction: direction)
      }
    case "fade": return .fade
    case "zoom": return .zoom
    case "zoomOut": return .zoomOut
    case "selectBy":
      if let presentingNode = parameters.get(0),
        let presenting = MotionTransitionType.from(node: presentingNode),
        let dismissingNode = parameters.get(1),
        let dismissing = MotionTransitionType.from(node: dismissingNode) {
        return .selectBy(presenting: presenting, dismissing: dismissing)
      }
    case "none": return .none
    default: break
    }
    return nil
  }
}

class TransitionPreprocessor: MotionPreprocessor {
    /// A reference to a MotionContext.
    weak var context: MotionContext!
    
  weak var motion: Motion?

  init(motion: Motion) {
    self.motion = motion
  }

  func shift(direction: MotionTransitionType.Direction, isAppearing: Bool, size: CGSize? = nil, transpose: Bool = false) -> CGPoint {
    let size = size ?? context.container.bounds.size
    let rtn: CGPoint
    switch direction {
    case .left, .right:
      rtn = CGPoint(x: (direction == .right) == isAppearing ? -size.width : size.width, y: 0)
    case .up, .down:
      rtn = CGPoint(x: 0, y: (direction == .down) == isAppearing ? -size.height : size.height)
    }
    if transpose {
      return CGPoint(x: rtn.y, y: rtn.x)
    }
    return rtn
  }

    /**
     Implementation for processor.
     - Parameter fromViews: An Array of UIViews.
     - Parameter toViews: An Array of UIViews.
     */
  func process(fromViews: [UIView], toViews: [UIView]) {
    guard let motion = motion else { return }
    var defaultAnimation = motion.defaultAnimation
    let inNavigationController = motion.isNavigationController
    let inTabBarController = motion.isTabBarController
    let toViewController = motion.toViewController
    let fromViewController = motion.fromViewController
    let presenting = motion.isPresenting
    let fromOverFullScreen = motion.fromOverFullScreen
    let toOverFullScreen = motion.toOverFullScreen
    let toView = motion.toView
    let fromView = motion.fromView
    let animators = motion.animators

    if case .auto = defaultAnimation {
      if inNavigationController, let navAnim = toViewController?.navigationController?.motionNavigationTransitionType {
        defaultAnimation = navAnim
      } else if inTabBarController, let tabAnim = toViewController?.tabBarController?.motionTabBarTransitionType {
        defaultAnimation = tabAnim
      } else if let modalAnim = (presenting ? toViewController : fromViewController)?.motionModalTransitionType {
        defaultAnimation = modalAnim
      }
    }

    if case .selectBy(let presentAnim, let dismissAnim) = defaultAnimation {
      defaultAnimation = presenting ? presentAnim : dismissAnim
    }

    if case .auto = defaultAnimation {
      if animators!.contains(where: { $0.canAnimate(view: toView, isAppearing: true) || $0.canAnimate(view: fromView, isAppearing: false) }) {
        defaultAnimation = .none
      } else if inNavigationController {
        defaultAnimation = presenting ? .push(direction:.left) : .pull(direction:.right)
      } else if inTabBarController {
        defaultAnimation = presenting ? .slide(direction:.left) : .slide(direction:.right)
      } else {
        defaultAnimation = .fade
      }
    }

    if case .none = defaultAnimation {
      return
    }

    context[fromView] = [.timingFunction(.standard), .duration(0.35)]
    context[toView] = [.timingFunction(.standard), .duration(0.35)]

    let shadowState: [MotionTransition] = [.shadow(opacity: 0.5),
                                           .shadow(color: .black),
                                           .shadow(radius: 5),
                                           .shadow(offset: .zero),
                                       .masksToBounds(false)]
    switch defaultAnimation {
    case .push(let direction):
        context[toView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: true)),
                                             .shadow(opacity: 0),
                                           .beginWith(transitions: shadowState),
                                           .timingFunction(.deceleration)])
        context[fromView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: false) / 3),
                                             .overlay(color: .black, opacity: 0.1),
                                             .timingFunction(.deceleration)])
    case .pull(let direction):
      motion.insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: false)),
                                             .shadow(opacity: 0),
                                             .beginWith(transitions: shadowState)])
      context[toView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: true) / 3),
                                           .overlay(color: .black, opacity: 0.1)])
    case .slide(let direction):
        context[fromView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: false))])
        context[toView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: true))])
    case .zoomSlide(let direction):
        context[fromView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: false)), .scale(to: 0.8)])
        context[toView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: true)), .scale(to: 0.8)])
    case .cover(let direction):
        context[toView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: true)),
                                             .shadow(opacity: 0),
                                           .beginWith(transitions: shadowState),
                                           .timingFunction(.deceleration)])
      context[fromView]!.append(contentsOf: [.overlay(color: .black, opacity: 0.1),
                                             .timingFunction(.deceleration)])
    case .uncover(let direction):
      motion.insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: false)),
                                             .shadow(opacity: 0),
                                             .beginWith(transitions: shadowState)])
      context[toView]!.append(contentsOf: [.overlay(color: .black, opacity: 0.1)])
    case .pageIn(let direction):
      context[toView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: true)),
                                           .shadow(opacity: 0),
                                           .beginWith(transitions: shadowState),
                                           .timingFunction(.deceleration)])
      context[fromView]!.append(contentsOf: [.scale(to: 0.7),
                                             .overlay(color: .black, opacity: 0.1),
                                             .timingFunction(.deceleration)])
    case .pageOut(let direction):
      motion.insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.translate(to: shift(direction: direction, isAppearing: false)),
                                             .shadow(opacity: 0),
                                             .beginWith(transitions: shadowState)])
      context[toView]!.append(contentsOf: [.scale(to: 0.7),
                                           .overlay(color: .black, opacity: 0.1)])
    case .fade:
      // TODO: clean up this. overFullScreen logic shouldn't be here
      if !(fromOverFullScreen && !presenting) {
        context[toView] = [.fade]
      }

      #if os(tvOS)
        context[fromView] = [.fade]
      #else
        if (!presenting && toOverFullScreen) || !fromView.isOpaque || (fromView.backgroundColor?.alphaComponent ?? 1) < 1 {
          context[fromView] = [.fade]
        }
      #endif

      context[toView]!.append(.preferredDurationMatchesLongest)
      context[fromView]!.append(.preferredDurationMatchesLongest)
    case .zoom:
      motion.insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.scale(to: 1.3), .fade])
      context[toView]!.append(contentsOf: [.scale(to: 0.7)])
    case .zoomOut:
      context[toView]!.append(contentsOf: [.scale(to: 1.3), .fade])
      context[fromView]!.append(contentsOf: [.scale(to: 0.7)])
    default:
      fatalError("Not implemented")
    }
  }
}
