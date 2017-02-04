## Welcome to Motion

Seamless animations and transitions in Swift.

Motion is a new tool used to create transition animations between view controllers. 

### Features

- [x] Add animations to views and layers.
- [x] Setup custom transition animations between view controllers.

### Sample

Take a look at a sample [Photo Collection](https://github.com/CosmicMind/Samples/tree/master/Motion/PhotoCollection) project.

![Motion Photo Collection Sample](http://www.cosmicmind.com/motion/motion_sample.gif)

### Motion Animations

You can add animations to any UIView or CALayer using the *motion* API. For example, to change the background color of a view with a 45 degree rotation:

```swift
view.motion(.backgroundColor(.blue), .rotationAngle(45))
``` 

#### Available Motion Animation Values

- delay
- timingFunction
- duration
- custom
- backgroundColor
- barTintColor
- cornerRadius
- transform
- rotationAngle
- rotationAngleX
- rotationAngleY
- rotationAngleZ
- spin
- spinX
- spinY
- spinZ
- scale
- scaleX
- scaleY
- scaleZ
- translate
- translateX
- translateY
- translateZ
- x
- y
- point
- position
- shadow
- fade
- zPosition
- width
- height
- size

### Motion Transitions

Motion allows for view controllers to animate between each other. By adding a value to a view's *motionIdentifier* property, a view will animate to the look of another view. For example, animating a floating button to a bar:

![Motion Button To Bar](http://www.cosmicmind.com/motion/cosmicmind_motion_button_to_bar.gif)

## License

Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

*   Redistributions of source code must retain the above copyright notice, this     
    list of conditions and the following disclaimer.

*   Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

*   Neither the name of CosmicMind nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
