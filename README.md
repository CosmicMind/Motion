**Motion** is a library used to create beautiful animations and transitions for views, layers, and view controllers.
 
## Requirements

* iOS 8.0+
* Xcode 8.0+

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/cosmicmind). (Tag 'cosmicmind')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/cosmicmind).
- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

> **Embedded frameworks require a minimum deployment target of iOS 8.**
> - [Download Motion](https://github.com/CosmicMind/Motion/archive/master.zip)

Visit the [Installation](https://github.com/CosmicMind/Motion/wiki/Installation) page to learn how to install Motion using [CocoaPods](http://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage).

## Changelog

Motion is a growing project and will encounter changes throughout its development. It is recommended that the [Changelog](https://github.com/CosmicMind/Motion/wiki/Changelog) be reviewed prior to updating versions.

## Animations

Motion offers a clean API to add animations to your views and layers. Simply pass in animation structs with configurable parameters. Take a look at some examples below: 

| Animation | Property  | Swift |
| --- | --- | --- |
| ![BackgroundColor](http://www.cosmicmind.com/motion/background_color.gif)  | Background Color  | view.animate(.background(color: .cyan)) |
| ![Border Color & Border Width](http://www.cosmicmind.com/motion/border_color.gif)  | Border Color & Border Width  | view.animate(.border(color: .cyan), .border(width: 20)) |
| ![Corner Radius](http://www.cosmicmind.com/motion/corner_radius.gif)  | Corner Radius  | view.animate(.corner(radius: 50)) |
| ![Depth](http://www.cosmicmind.com/motion/depth.gif)  | Depth  | view.animate(.depth(offset: CGSize(width: 10, height: 10), opacity: 0.5, radius: 3)) |
| ![Fade](http://www.cosmicmind.com/motion/fade.gif)  | Fade  | view.animate(.fadeOut) |
| ![Position](http://www.cosmicmind.com/motion/position.gif)  | Position  | view.animate(.position(CGPoint(x: 200, y: 200))) |
| ![Rotate](http://www.cosmicmind.com/motion/rotate.gif)  | Rotate  | view.animate(.rotate(180)) |
| ![Scale](http://www.cosmicmind.com/motion/scale.gif)  | Scale  | view.animate(.scale(3)) |
| ![Size](http://www.cosmicmind.com/motion/size.gif)  | Size  | view.animate(.size(CGSize(width: 200, height: 200))) |
| ![Spin](http://www.cosmicmind.com/motion/spin.gif)  | Spin  | view.animate(.spin(x: 1, y: 1, z: 1)) |
| ![Spring](http://www.cosmicmind.com/motion/spring.gif)  | Spring  | view.animate(.spring(stiffness: 15, damping: 2)) |
| ![Translate](http://www.cosmicmind.com/motion/translate.gif)  | Translate  | view.animate(.translate(x: 50, y: 100)) |


## License

The MIT License (MIT)

Copyright (C) 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
