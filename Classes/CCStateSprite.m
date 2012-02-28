#import "CCStateSprite.h"
 
 
@implementation CCStateSprite
+ (id)spriteWithState:(iAutomataState*)state target:(id)target selector:(SEL)selector {
	CCStateSprite *menu = [CCStateSprite menuWithItems:[CCStateSpriteItem spriteItemWithState:state target:target selector:selector], nil];
	menu.position = [state getPosition];
	return menu;
}
- (void)setActive:(BOOL)active {
	[(CCStateSpriteItem*)[[self children] objectAtIndex:0] setActive:active];
}
- (void)setAccept:(BOOL)accept {
	[(CCStateSpriteItem*)[[self children] objectAtIndex:0] setAccept:accept];
}
- (void)setStart:(BOOL)start {
	[(CCStateSpriteItem*)[[self children] objectAtIndex:0] setStart:start];
}
- (iAutomataState*)getState{
	return [[[self children] objectAtIndex:0] getState];
}
- (void)setStateName:(NSString*)n {
	NSLog(@"call to set name in ccstatesprite: %@",n);
	[(CCStateSpriteItem*)[[self children] objectAtIndex:0] setStateName:n];
}
- (void)setPosition:(CGPoint)pos {
	[super setPosition:pos];
	[[self getState] setPosition:pos];
}
@end
 
@implementation CCStateSpriteItem
+ (id)spriteItemWithState:(iAutomataState*)s target:(id)target selector:(SEL)selector {
	return [[[self alloc] initSpriteWithState:s target:target selector:selector] autorelease];
}
- (id)initSpriteWithState:(iAutomataState*)s target:target selector:(SEL)selector {
	if((self = [super initWithTarget:target selector:selector])) {
		state = s;
		stateImage = [[CCSprite spriteWithFile:@"state_sprite_new.png"] retain];
		stateImage.anchorPoint = ccp(0,0);
		acceptStateImage = [[CCSprite spriteWithFile:@"acceptstate_sprite_new.png"] retain];
		acceptStateImage.anchorPoint = ccp(0,0);
		activeStateImage = [[CCSprite spriteWithFile:@"active_state_sprite_new.png"] retain];
		activeStateImage.anchorPoint = ccp(0,0);
		activeAcceptStateImage = [[CCSprite spriteWithFile:@"active_acceptstate_sprite_new.png"] retain];
		activeAcceptStateImage.anchorPoint = ccp(0,0);
		startStateArrow = [[CCSprite spriteWithFile:@"startArrow.png"] retain];
		startStateArrow.anchorPoint = ccp(1,0.5);
		startStateArrow.position = ccp(0,30);
		
		if ([state isAcceptState]) {
			[self addChild:acceptStateImage z:1 tag:5];
		} else {
			[self addChild:stateImage z:1 tag:5];
		}
		if ([state isStartState]) {
			[self addChild:startStateArrow z:1 tag:8];
		}
		self.contentSize = stateImage.contentSize;
		
		CCLabelTTF *stateName = [CCLabelTTF labelWithString:[state getName] fontName:@"Marker Felt" fontSize:12];
		stateName.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
		stateName.color = ccBLACK;
		[self addChild:stateName z:2 tag:3];
		[self setIsEnabled:NO];
	}
	return self;
}
- (void)setActive:(BOOL)active {
		if (active) {
			if ([state isAcceptState]) {
				[self removeChild:acceptStateImage cleanup:NO];
				[self removeChild:activeAcceptStateImage cleanup:NO];
				[self addChild:activeAcceptStateImage z:1 tag:5];					
			} else {
				[self removeChild:stateImage cleanup:NO];
				[self removeChild:activeStateImage cleanup:NO];
				[self addChild:activeStateImage z:1 tag:5];						
			}
		} else {
			if ([state isAcceptState]) {
				[self removeChild:acceptStateImage cleanup:NO];
				[self removeChild:activeAcceptStateImage cleanup:NO];
				[self addChild:acceptStateImage z:1 tag:5];					
			} else {
				[self removeChild:stateImage cleanup:NO];
				[self removeChild:activeStateImage cleanup:NO];
				[self addChild:stateImage z:1 tag:5];						
			}	
		}
}
- (void)setAccept:(BOOL)accept {
	if (accept) {
		[self removeChild:acceptStateImage cleanup:NO];
		[self removeChild:stateImage cleanup:NO];
		[self addChild:acceptStateImage z:1 tag:5];					
	} else {
		[self removeChild:stateImage cleanup:NO];
		[self removeChild:acceptStateImage cleanup:NO];
		[self addChild:stateImage z:1 tag:5];						
	}
}
- (void)setStart:(BOOL)start {
	if (start) {
		[self removeChild:startStateArrow cleanup:NO];
		[self addChild:startStateArrow z:1 tag:8];					
	} else {
		[self removeChild:startStateArrow cleanup:NO];			
	}
}
- (void)setStateName:(NSString *)n {
	[state setName:n];
	CCLabelTTF *stateName = [CCLabelTTF labelWithString:n fontName:@"Marker Felt" fontSize:12];
	stateName.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
	stateName.color = ccBLACK;
	NSLog(@"removing old name and adding new name: %@",n);
	[self removeChildByTag:3 cleanup:YES];
	[self addChild:stateName z:2 tag:3];
}
- (iAutomataState*)getState {
	//NSLog(@"returning state");
	return state;
}
 
-(void) selected {
	//[self removeChild:back cleanup:NO];
	//[self addChild:backPressed];
	[super selected];
}
 
-(void) unselected {
	//[self removeChild:backPressed cleanup:NO];
	//[self addChild:back];
	[super unselected];
}
 
- (void)activate {
	[super activate];
	[self setIsEnabled:NO];
	[self schedule:@selector(resetButton:) interval:0.5];
}
 
- (void)resetButton:(ccTime)dt {
	[self unschedule:@selector(resetButton:)];
	[self setIsEnabled:YES];
}
 
- (void)dealloc {
	[stateImage release];
	[acceptStateImage release];
	[activeStateImage release];
	[activeAcceptStateImage release];
	[super dealloc];
}
 
@end