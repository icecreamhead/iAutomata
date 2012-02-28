#import "cocos2d.h"
#import "iAutomataState.h"
 
@interface CCStateSprite : CCMenu {
}
+ (id)spriteWithState:(iAutomataState*)state target:(id)target selector:(SEL)selector;
- (iAutomataState*)getState;
- (void)setActive:(BOOL)active;
- (void)setAccept:(BOOL)accept;
- (void)setStart:(BOOL)start;
- (void)setStateName:(NSString*)name;
@end
 
@interface CCStateSpriteItem : CCMenuItem {
	iAutomataState *state;
	CCSprite *stateImage;
	CCSprite *acceptStateImage;
	CCSprite *activeStateImage;
	CCSprite *activeAcceptStateImage;
	CCSprite *startStateArrow;
}
+ (id)spriteItemWithState:(iAutomataState*)state target:(id)target selector:(SEL)selector;
- (id)initSpriteWithState:(iAutomataState*)state target:(id)target selector:(SEL)selector;
- (iAutomataState*)getState;
- (void)setActive:(BOOL)active;
- (void)setAccept:(BOOL)accept;
- (void)setStart:(BOOL)start;
- (void)setStateName:(NSString*)name;
@end