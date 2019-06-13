//
//  ViewController.m
//  Example
//
//  Created by Stefan Nebel on 13.06.19.
//  Copyright © 2019 CosmicMind, Inc. All rights reserved.
//

#import "ViewControllers.h"
@import Motion;



@implementation VC_1

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.viewMotion = [[UIView alloc] initWithFrame:CGRectMake([self view].center.x - 50, 100, 100, 100)];
  
  [self.viewMotion setBackgroundColor:[UIColor orangeColor]];
  [self.viewMotion setMotionIdentifier:@"identifier"];
  
  [[self view] addSubview:self.viewMotion];
  [[self view] setBackgroundColor:[UIColor grayColor]];
  
  [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(navigate)]];
}
- (void)navigate
{
  [[self navigationController] setIsMotionEnabled:YES];
  [[self navigationController] motionNavigationTransitionWithType:MotionTransitionAnimationTypPull direction:MotionTransitionAnimationDirectionLeft];
  
  [[self navigationController] pushViewController:[[VC_2 alloc] init] animated:YES];
}


@end


@implementation VC_2

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.viewMotion = [[UIView alloc] initWithFrame:CGRectMake([self view].center.x - 100, 300, 200, 100)];
  
  [self.viewMotion setBackgroundColor:[UIColor darkGrayColor]];
  [self.viewMotion setMotionIdentifier:@"identifier"];
  
  [[self view] addSubview:self.viewMotion];
  [[self view] setBackgroundColor:[UIColor lightGrayColor]];
}


@end
