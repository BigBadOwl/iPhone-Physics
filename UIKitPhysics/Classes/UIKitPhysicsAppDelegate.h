//
//  UIKitPhysicsAppDelegate.h
//  UIKitPhysics
//
//  Created by Colin Bell on 09/03/2011.
//  Copyright 2011 GateWest. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIKitPhysicsViewController;

@interface UIKitPhysicsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UIKitPhysicsViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIKitPhysicsViewController *viewController;

@end

