    //
//  DraggableView.m
//  UIKitPhysics
//
//  Created by Colin Bell on 09/03/2011.
//  Copyright 2011 GateWest. All rights reserved.
//

#import "DraggableView.h"

@implementation DraggableView

@synthesize isBeingDragged;
@synthesize velocity;

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch *touch = [touches anyObject];
	currentTouch = [touch locationInView:self.superview];
	CGPoint touchPoint = [touch locationInView:self.superview];

	// Set the correct center when touched 
	touchPoint.x -= deltaX;
	touchPoint.y -= deltaY;

	self.center = touchPoint;
	
	velocity = CGPointMake(currentTouch.x - lastTouch.x, currentTouch.y - lastTouch.y);
	//NSLog(@"x value is: %f", currentTouch.x - lastTouch.x);
	//NSLog(@"y value is: %f", currentTouch.y - lastTouch.y);
    lastTouch = currentTouch;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint beginCenter = self.center;

	UITouch *touch = [touches anyObject];
	currentTouch = [touch locationInView:self.superview];
	CGPoint touchPoint = [touch locationInView:self.superview];
	
	isBeingDragged = YES;
	deltaX = touchPoint.x - beginCenter.x;
	deltaY = touchPoint.y - beginCenter.y;
	
	velocity = CGPointMake(0.0, 0.0);
	lastTouch = currentTouch;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	isBeingDragged = NO;
	velocity = CGPointMake(0.0, 0.0);
}

-(void)setPhysical:(b2World *)world{
	// Define the dynamic body.
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
 
	CGPoint p = self.center;
	CGPoint boxDimensions = CGPointMake(self.bounds.size.width/PTM_RATIO/2.0,self.bounds.size.height/PTM_RATIO/2.0);
 
	bodyDef.position.Set(p.x/PTM_RATIO, (self.bounds.size.width - p.y)/PTM_RATIO);
	bodyDef.userData = self;
 
	// Tell the physics world to create the body
	b2Body *body = world->CreateBody(&bodyDef);
 
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
 
	dynamicBox.SetAsBox(boxDimensions.x, boxDimensions.y);
 
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 3.0f;
	fixtureDef.friction = 0.3f;
	fixtureDef.restitution = 0.5f; // 0 is a lead ball, 1 is a super bouncy ball
	body->CreateFixture(&fixtureDef);
 
	// a dynamic body reacts to forces right away
	body->SetType(b2_dynamicBody);
 
	// we abuse the tag property as pointer to the physical body
	self.tag = (int)body;
}

- (void)dealloc {
    [super dealloc];
}


@end
