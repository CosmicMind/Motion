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

public protocol MotionStringConvertible {
    /**
     Retrieves an instance of Self from a give ExprNode.
     - Parameter node: An ExprNode.
     - Returns: An optional Self.
     */
    static func from(node: ExprNode) -> Self?
}

extension String {
    /**
     Parses a string that implements the MotionStringConvertible protocol.
     - Returns: An optional Array of Elements of type T.
     */
    func parse<T: MotionStringConvertible>() -> [T]? {
        let lexer = Lexer(input: self)
        let parser = Parser(tokens: lexer.tokenize())
        
        do {
            let nodes = try parser.parse()
            var results = [T]()
            
            for v in nodes {
                if let modifier = T.from(node: v) {
                    results.append(modifier)
                } else {
                    print("\(v.name) doesn't exist in \(T.self)")
                }
            }
            
            return results
        } catch let error {
            print("failed to parse \"\(self)\", error: \(error)")
        }
        
        return nil
    }

    /**
     Retrieves a single instance of a token.
     - Returns: An optional Element ot type T.
    */
    func parseOne<T: MotionStringConvertible>() -> T? {
        return parse()?.last
    }
}
