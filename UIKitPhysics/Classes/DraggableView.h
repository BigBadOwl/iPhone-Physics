//
//  DraggableView.h
//  UIKitPhysics
//
//  Created by Colin Bell on 09/03/2011.
//  Copyright 2011 GateWest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Box2D/Box2D.h>
#import "UIKitPhysicsViewController.h"

@interface DraggableView : UIView {
	@private float deltaX;
	@private float deltaY;
	CGPoint lastTouch;
    CGPoint currentTouch;
	CGPoint velocity;
	BOOL isBeingDragged;
}

@property BOOL isBeingDragged;
@property CGPoint velocity;

-(void)setPhysical:(b2World *)world;

@end
