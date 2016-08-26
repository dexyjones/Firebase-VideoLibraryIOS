//
//  AppDelegate.h
//  Zuma
//
//  Created by Kemgadi Nwachukwu on 8/14/16.
//  Copyright © 2016 4Bars Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class TopVideosViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic,nullable) TopVideosViewController *mainVideoViewController;


@end

