//
//  HelloWorldLayer.m
//  Pinch and Scroll like COC
//
//  Created by ekin on 13-10-20.
//  Copyright ekin 2013年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer{
    CCTMXTiledMap *map;
    CGSize winSize;
    CGFloat mapWidth;
    CGFloat mapHeight;
}

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) ) {
        
        winSize=[CCDirector sharedDirector].winSize;
        
        //加载地图
        map=[[CCTMXTiledMap alloc] initWithTMXFile:@"square_tile.tmx"];
        map.anchorPoint=CGPointZero;
        map.position=CGPointZero;
        map.scale=2;
        [self addChild:map];
        
        //除以2是考虑retina，实际中应该对此判断
        mapWidth= map.tileSize.width*map.mapSize.width/2.0f;
        mapHeight= map.tileSize.height*map.mapSize.height/2.0f;
        
        //缩放处理
        UIPinchGestureRecognizer *pinchRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)] autorelease];
        [[[CCDirector sharedDirector] view] addGestureRecognizer:pinchRecognizer];
        
        //滑动
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	}
	return self;
}

-(void) handlePinchFrom:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        
        UIView *piece = gestureRecognizer.view;
        
        CGPoint location = [gestureRecognizer locationInView:piece];
        
        location=[[CCDirector sharedDirector] convertToGL:location];
        
        CGPoint locationInView=[map convertToNodeSpace:location];
        
        //ax-新的anchor point中x的值，ay同理
        CGFloat ax=locationInView.x / mapWidth;
        CGFloat ay=locationInView.y / mapHeight;
        
        CGPoint prevAnchor=map.anchorPoint;
        
        map.anchorPoint = ccp(ax,ay);
        
        //调整后的地图位置
        map.position=ccp(mapWidth*ax*map.scale+map.position.x-map.boundingBox.size.width*prevAnchor.x,mapHeight*ay*map.scale+map.position.y -map.boundingBox.size.height*prevAnchor.y);
        
        
        gestureRecognizer.scale=map.scale;
    }
    
    map.scale=gestureRecognizer.scale;
    
    [self adjustViewBoundingPosition:self.position];
}

-(void)adjustViewBoundingPosition:(CGPoint)newPos
{
    CGFloat adjustWidth=map.boundingBox.size.width*map.anchorPoint.x-map.position.x;
    CGFloat adjustHeight=map.boundingBox.size.height*map.anchorPoint.y-map.position.y;
    
    newPos.x=  MIN(newPos.x, adjustWidth);
    newPos.x = MAX(newPos.x, winSize.width-[map boundingBox].size.width+adjustWidth);
    newPos.y = MIN(newPos.y,adjustHeight);
    newPos.y = MAX(newPos.y, winSize.height-[map boundingBox].size.height+adjustHeight);
    self.position=newPos;
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    CGPoint newPos= ccpAdd(self.position, translation);
    
    [self adjustViewBoundingPosition:newPos];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
