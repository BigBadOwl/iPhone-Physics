//
//  UIKitPhysicsViewController.h
//  UIKitPhysics
//
//  Created by Colin Bell on 09/03/2011.
//  Copyright 2011 GateWest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Box2D/Box2D.h>

#define PTM_RATIO 16

@interface UIKitPhysicsViewController : UIViewController {
	b2World* world;
	NSTimer *tickTimer;
}

@end

