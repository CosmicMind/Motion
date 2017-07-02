**Motion** is a library used to create beautiful animations and transitions for views, layers, and view controllers.
 
## Transitions

Motion offers a clean API to add animations to your views and layers. Simply pass in animation structs with configurable parameters. Take a look at some examples below: 

[Download Sample Transitions Project](https://github.com/CosmicMind/Samples/tree/development/Projects/Programmatic/Transitions)

| Cover | Fade | PageIn | PageOut | Pull |
| --- | --- | --- | --- | --- |
| ![Cover](http://www.cosmicmind.com/motion/cover.gif)  | ![Fade](http://www.cosmicmind.com/motion/fade.gif)| ![Page In](http://www.cosmicmind.com/motion/page_in.gif) | ![Page Out](http://www.cosmicmind.com/motion/page_out.gif)  | ![Pull](http://www.cosmicmind.com/motion/pull.gif)|

| Push | Uncover | Zoom | ZoomOut | ZoomSlide |
| --- | --- | --- | --- | --- |
| ![Push](http://www.cosmicmind.com/motion/push.gif) | ![Uncover](http://www.cosmicmind.com/motion/uncover.gif)| ![Zoom](http://www.cosmicmind.com/motion/zoom.gif) | ![Zoom Out](http://www.cosmicmind.com/motion/zoom_out.gif)  | ![Zoom Slide](http://www.cosmicmind.com/motion/zoom_slide.gif)|
 
## Animations

Motion offers a clean API to add animations to your views and layers. Simply pass in animation structs with configurable parameters. Take a look at some examples below: 

[Download Sample Animations Project](https://github.com/CosmicMind/Samples/tree/development/Projects/Programmatic/Animations)

| Animation | Property  | Swift |
| --- |:--- |:--- |
| ![BackgroundColor](http://www.cosmicmind.com/motion/background_color.gif)  | Background Color  | background(color: UIColor) |
| ![Border Color & Border Width](http://www.cosmicmind.com/motion/border_color.gif)  | Border Color & Border Width  | border(color: UIColor), border(width: CGFloat) |
| ![Corner Radius](http://www.cosmicmind.com/motion/corner_radius.gif)  | Corner Radius  | corner(radius: CGFloat) |
| ![Depth](http://www.cosmicmind.com/motion/depth.gif)  | Depth  | depth(offset: CGSize, opacity: Float, radius: CGFloat) |
| ![Fade](http://www.cosmicmind.com/motion/fade.gif)  | Fade  | fade(_ opacity: Double) |
| ![Position](http://www.cosmicmind.com/motion/position.gif)  | Position  | position(_ point: CGPoint) |
| ![Rotate](http://www.cosmicmind.com/motion/rotate.gif)  | Rotate  | rotate(x: CGFloat, y: CGFloat, z: CGFloat) |
| ![Scale](http://www.cosmicmind.com/motion/scale.gif)  | Scale  | scale(x: CGFloat, y: CGFloat, z: CGFloat) |
| ![Size](http://www.cosmicmind.com/motion/size.gif)  | Size  | size(_ size: CGSize) |
| ![Spin](http://www.cosmicmind.com/motion/spin.gif)  | Spin  | spin(x: CGFloat, y: CGFloat, z: CGFloat) |
| ![Spring](http://www.cosmicmind.com/motion/spring.gif)  | Spring  | spring(stiffness: CGFloat, damping: CGFloat) |
| ![Translate](http://www.cosmicmind.com/motion/translate.gif)  | Translate  | translate(x: CGFloat, y: CGFloat, z: CGFloat) |

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
