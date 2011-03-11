//
//  sprite.h
//  UIKitPhysics
//
//  Created by Colin Bell on 10/03/2011.
//  Copyright 2011 GateWest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIKitPhysicsViewController.h"
#import <Box2D/Box2D.h>

@interface sprite : UIView {

}

-(void)setPhysical:(b2World *)world;

@end
