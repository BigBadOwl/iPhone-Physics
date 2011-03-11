//
//  UIKitPhysicsViewController.m
//  UIKitPhysics
//
//  Created by Colin Bell on 09/03/2011.
//  Copyright 2011 GateWest. All rights reserved.
//

#import "UIKitPhysicsViewController.h"
#import "DraggableView.h"
#import "sprite.h"

@implementation UIKitPhysicsViewController

-(void)createPhysicsWorld
{
	CGSize screenSize = self.view.bounds.size;
 
	// Define the gravity vector.
	b2Vec2 gravity(0.0f, -9.81f);
 
	// Do we want to let bodies sleep?
	// This will speed up the physics simulation
	bool doSleep = true;
 
	// Construct a world object, which will hold and simulate the rigid bodies.
	world = new b2World(gravity, doSleep);
	world->SetContinuousPhysics(true);
 
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
 
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	b2EdgeShape groundBox;
	groundBox.Set(b2Vec2(0,0), b2Vec2(screenSize.height/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox, 0);
	
	groundBox.Set(b2Vec2(0,screenSize.width/PTM_RATIO), b2Vec2(screenSize.height/PTM_RATIO,screenSize.width/PTM_RATIO));
	groundBody->CreateFixture(&groundBox, 0);
	
	groundBox.Set(b2Vec2(0,screenSize.width/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox, 0);
	
	groundBox.Set(b2Vec2(screenSize.height/PTM_RATIO,screenSize.width/PTM_RATIO), b2Vec2(screenSize.height/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox, 0);
}

-(void)addPhysicalBodyForView:(UIView *)physicalView
{
	// Define the dynamic body.
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
 
	CGPoint p = physicalView.center;
	CGPoint boxDimensions = CGPointMake(physicalView.bounds.size.width/PTM_RATIO/2.0,physicalView.bounds.size.height/PTM_RATIO/2.0);
 
	bodyDef.position.Set(p.x/PTM_RATIO, (self.view.bounds.size.width - p.y)/PTM_RATIO);
	bodyDef.userData = physicalView;
 
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
	physicalView.tag = (int)body;
}

-(void) tick:(NSTimer *)timer
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
 
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
 
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(1.0f/60.0f, velocityIterations, positionIterations);
 
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()){
		if (b->GetUserData() != NULL){
			id obj = (id)b->GetUserData();
			if ((obj != NULL) && ([obj isKindOfClass:[DraggableView class]])) {
				DraggableView *oneView = (DraggableView *)b->GetUserData();
				
				if(oneView.isBeingDragged){
					CGPoint p = oneView.center;
					b->SetTransform(b2Vec2(p.x/PTM_RATIO, (self.view.bounds.size.height - p.y)/PTM_RATIO), b->GetAngle());
					
					b2Vec2 force = b2Vec2(oneView.velocity.x, -oneView.velocity.y);
					b->ApplyLinearImpulse(force, b2Vec2(p.x/PTM_RATIO, (self.view.bounds.size.width - p.y)/PTM_RATIO));
				}
				else{
					CGPoint newCenter = CGPointMake(b->GetPosition().x * PTM_RATIO,self.view.bounds.size.height - b->GetPosition().y * PTM_RATIO);
					oneView.center = newCenter;
					CGAffineTransform transform = CGAffineTransformMakeRotation(-1 * b->GetAngle());
					oneView.transform = transform;
				}
			}
			else{
				UIView *oneView = (UIView *)b->GetUserData();
				CGPoint newCenter = CGPointMake(b->GetPosition().x * PTM_RATIO,self.view.bounds.size.height - b->GetPosition().y * PTM_RATIO);
				oneView.center = newCenter;
				CGAffineTransform transform = CGAffineTransformMakeRotation(-1 * b->GetAngle());
				oneView.transform = transform;
			}
		}
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
	
	[self createPhysicsWorld];
	for (UIView *oneView in self.view.subviews){
		[self addPhysicalBodyForView:oneView];
	}
	
	//manually add a sprite
	/*sprite *mySprite = [[sprite alloc] init];
	mySprite.center = CGPointMake(0,0);
	mySprite.backgroundColor = [UIColor redColor];
	mySprite.frame = CGRectMake(174, 248, 72, 46);
	[self.view addSubview:mySprite];
	[mySprite setPhysical:world];*/
 
	tickTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

-(void)didRotate:(NSNotification *)notification {
	UIDeviceOrientation orient = [[UIDevice currentDevice] orientation];
	if ((orient != UIDeviceOrientationLandscapeLeft) && (orient != UIDeviceOrientationLandscapeRight)) {
		return;
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[tickTimer invalidate], tickTimer = nil;
	[super dealloc];
}

@end
