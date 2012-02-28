//
//  HelloWorldLayer.m
//  iAutomata
//
//  Created by Josh on 02/01/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

// Import the interfaces
#import "iAutomataMenuScene.h"
#import "iAutomataDiagramScene.h"
#import "CCButton.h"
#import "iAutomataAppDelegate.h"
#import "cocos2d.h"
#import "CCUIViewWrapper.h"
#import "Reachability.h"

// HelloWorld implementation
@implementation iAutomataMenu

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	iAutomataMenu *layer = [iAutomataMenu node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)] )) {
		
		// create and initialize a Label
		CCSprite *label = [CCSprite spriteWithFile:@"Logo.png"];

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , 3*size.height/4 );
		// add the label as a child to this Layer
		[self addChild:label z:0 tag:1];
		
		CCButton *btnNewDiagram = [CCButton buttonWithText:@"Create DFA" atPosition:ccp( size.width/2 , size.height/3 ) target:self selector:@selector(newDiagram)];
		[self addChild:btnNewDiagram];
		
        CCButton *btnLeaveFeedback = [CCButton buttonWithText:@"Leave App Feedback" atPosition:ccp( size.width/2 , size.height/3 - 60) target:self selector:@selector(leaveFeedback)];
		[self addChild:btnLeaveFeedback];
        
		//currentDiagram = [[[iAutomataDiagram alloc] init] autorelease];
		currentDiagram = nil;
	}
	return self;
}

- (void) newDiagram {
	NSLog(@"Swapping to diagram view");
	if (!machineIsInitialised) {
		NSLog(@"Creating new diagram");
		machineIsInitialised = YES;
		currentDiagram = [iAutomataDiagram node];
		[currentDiagram retain];
	} else {
		NSLog(@"Re-using current diagram");
	}
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:1.0 scene:currentDiagram]];
	//[[CCDirector sharedDirector] pushScene:[CCTransitionSlideInR transitionWithDuration:1.0 scene:currentDiagram]];
	[[CCDirector sharedDirector] pushScene:currentDiagram];
}
- (void) leaveFeedback {
	NSLog(@"Swapping to feedback view");
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:1.0 scene:currentDiagram]];
	//[[CCDirector sharedDirector] pushScene:[CCTransitionSlideInR transitionWithDuration:1.0 scene:currentDiagram]];
    feedbackView = [[CCScene alloc] init];

    
    CGRect webFrame = CGRectMake(0, 0, [[CCDirector sharedDirector] winSize].width, [[CCDirector sharedDirector] winSize].height - 50);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webFrame];
    webView.backgroundColor = [UIColor whiteColor];
    [webView setOpaque:NO];
    [webView setScalesPageToFit:YES];
    
    Reachability *reach = [[Reachability reachabilityForInternetConnection] retain];	
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        NSLog(@"No internet!");
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"no_internet" ofType:@"html"]isDirectory:NO]]];
    } else {
        NSLog(@"Internet!");
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://apps.icecreamhead.co.uk/submit"]]];
    }
    [reach release];
    
    CCUIViewWrapper *webview = [CCUIViewWrapper wrapperForUIView:webView];
    webview.position = ccp(0,[[CCDirector sharedDirector] winSize].height - 44);
    [feedbackView addChild:webview];
    [webView release];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[CCDirector sharedDirector] winSize].width, 44)];
    
    [toolbar setItems:[NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToMenu)]]];
    CCUIViewWrapper *barTopWrapper = [CCUIViewWrapper wrapperForUIView:toolbar];
	barTopWrapper.position = ccp(0,[[CCDirector sharedDirector] winSize].height);
	[feedbackView addChild:barTopWrapper z:1 tag:2];
	[[CCDirector sharedDirector] pushScene:feedbackView];
}

- (void)backToMenu {
    [feedbackView removeChildByTag:2 cleanup:YES];
    [[CCDirector sharedDirector] popScene];
    [feedbackView release];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
	[currentDiagram release];
}
@end
