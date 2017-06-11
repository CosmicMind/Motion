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

/// used to construct MotionTransition from motionTransitionsString
extension MotionTransition: MotionStringConvertible {
  public static func from(node: ExprNode) -> MotionTransition? {
    let name: String = node.name
    let parameters: [ExprNode] = (node as? CallNode)?.arguments ?? []

    switch name {
    case "fade":
      return .fade
    case "opacity":
        return MotionTransition.fade(to: parameters.getFloat(0) ?? 1)
    case "position":
        return .position(to: CGPoint(x: parameters.getCGFloat(0) ?? 0, y: parameters.getCGFloat(1) ?? 0))
    case "size":
      return .size(CGSize(width: parameters.getCGFloat(0) ?? 0, height: parameters.getCGFloat(1) ?? 0))
    case "scale":
      if parameters.count == 1 {
        return .scale(to: parameters.getCGFloat(0) ?? 1)
      } else {
        return .scale(x: parameters.getCGFloat(0) ?? 1,
                          y: parameters.getCGFloat(1) ?? 1,
                          z: parameters.getCGFloat(2) ?? 1)
      }
    case "rotate":
      if parameters.count == 1 {
        return .rotate(parameters.getCGFloat(0) ?? 0)
      } else {
        return .rotate(x: parameters.getCGFloat(0) ?? 0,
                           y: parameters.getCGFloat(1) ?? 0,
                           z: parameters.getCGFloat(2) ?? 0)
      }
    case "translate":
      return .translate(x: parameters.getCGFloat(0) ?? 0,
                            y: parameters.getCGFloat(1) ?? 0,
                            z: parameters.getCGFloat(2) ?? 0)
    case "overlay":
      return .overlay(color: UIColor(red: parameters.getCGFloat(0) ?? 1,
                                         green: parameters.getCGFloat(1) ?? 1,
                                         blue: parameters.getCGFloat(2) ?? 1,
                                         alpha: 1),
                          opacity: parameters.getCGFloat(3) ?? 1)
    case "duration":
      if let duration = parameters.getDouble(0) {
        return .duration(duration)
      }
    case "preferredDurationMatchesLongest":
      return .preferredDurationMatchesLongest
    case "delay":
      if let delay = parameters.getDouble(0) {
        return .delay(delay)
      }
    case "spring":
      if #available(iOS 9, *) {
        return .spring(stiffness: parameters.getCGFloat(0) ?? 250, damping: parameters.getCGFloat(1) ?? 30)
      }
    case "timingFunction":
      if let c1 = parameters.getFloat(0),
        let c2 = parameters.getFloat(1),
        let c3 = parameters.getFloat(2),
        let c4 = parameters.getFloat(3) {
        return .timingFunction(CAMediaTimingFunction(controlPoints: c1, c2, c3, c4))
      } else if let name = parameters.get(0)?.name, let timingFunction = CAMediaTimingFunction.from(mediaTimingFunctionType: name) {
        return .timingFunction(timingFunction)
      }
    case "arc":
      return .arc(intensity: parameters.getCGFloat(0) ?? 1)
    case "cascade":
      var cascadeDirection = CascadeDirection.topToBottom
      if let directionString = parameters.get(1)?.name,
        let direction = CascadeDirection(directionString) {
        cascadeDirection = direction
      }
      return .cascade(delta: parameters.getDouble(0) ?? 0.02, direction: cascadeDirection, animationDelayUntilMatchedViews:parameters.getBool(2) ?? false)
    case "source":
      if let motionIdentifier = parameters.get(0)?.name {
        return .motionIdentifier(motionIdentifier)
      }
    case "useGlobalCoordinateSpace":
      return .useGlobalCoordinateSpace
    case "useSameParentCoordinateSpace":
      return .useSameParentCoordinateSpace
    case "ignoreSubviewTransitions":
      return .ignoreSubviewTransitions(recursive:parameters.getBool(0) ?? false)
    case "zPosition":
      if let zPosition = parameters.getCGFloat(0) {
        return .zPosition(zPosition)
      }
    case "useOptimizedSnapshot":
      return .useOptimizedSnapshot
    case "useNormalSnapshot":
      return .useNormalSnapshot
    case "useLayerRenderSnapshot":
      return .useLayerRenderSnapshot
    case "useNoSnapshot":
      return .useNoSnapshot
    case "forceAnimate":
      return .forceAnimate
    default: break
    }
    return nil
  }
}
