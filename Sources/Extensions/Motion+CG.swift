/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import MetalKit

internal struct KeySet<Key: Hashable, Value: Hashable> {
    /// A reference to the dictionary storing the key / Set pairs.
    fileprivate var dictionary = [Key: Set<Value>]()
    
    /**
     Subscript for matching keys and returning the corresponding set.
     - Parameter key: A Key type.
     - Returns: A Set<Value> type.
     */
    subscript(key: Key) -> Set<Value> {
        mutating get {
            if nil == dictionary[key] {
                dictionary[key] = Set<Value>()
            }
            
            return dictionary[key]!
        }
        set(value) {
            dictionary[key] = value
        }
    }
}

internal extension CGSize {
    internal var center: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
    
    internal var point: CGPoint {
        return CGPoint(x: width, y: height)
    }
    
    internal func transform(_ t: CGAffineTransform) -> CGSize {
        return applying(t)
    }
    
    internal func transform(_ t: CATransform3D) -> CGSize {
        return applying(CATransform3DGetAffineTransform(t))
    }
}

internal extension CGRect {
    var center: CGPoint {
        return CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
    
    var bounds: CGRect {
        return CGRect(origin: CGPoint.zero, size: size)
    }
    
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }
}

internal extension CGFloat {
    func clamp(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        return self < a ? a : self > b ? b : self
    }
}

internal extension CGPoint {
    func translate(_ dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
    
    func transform(_ t: CGAffineTransform) -> CGPoint {
        return applying(t)
    }
    
    func transform(_ t: CATransform3D) -> CGPoint {
        return applying(CATransform3DGetAffineTransform(t))
    }
    
    func distance(_ b: CGPoint) -> CGFloat {
        return sqrt(pow(x - b.x, 2) + pow(y - b.y, 2))
    }
}

internal func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

internal func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

internal func /(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x / right, y: left.y / right)
}

internal func /(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

internal func *(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}

internal func *(left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x * right.width, y: left.y * right.width)
}

internal func *(left: CGFloat, right: CGPoint) -> CGPoint {
    return right * left
}

internal func *(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

internal prefix func -(point: CGPoint) -> CGPoint {
    return CGPoint.zero - point
}

internal func abs(_ p: CGPoint) -> CGPoint {
    return CGPoint(x: abs(p.x), y: abs(p.y))
}

internal func *(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}

internal func *(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.width)
}

internal func /(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width / right.width, height: left.height / right.height)
}

internal func == (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
    var lhs = lhs
    var rhs = rhs
    return memcmp(&lhs, &rhs, MemoryLayout<CATransform3D>.size) == 0
}

internal func != (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
    return !(lhs == rhs)
}
