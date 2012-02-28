//
//  CCButton.h
//  StickWars - Siege
//
//  Created by EricH on 8/3/09.
//
#import "cocos2d.h"
 
@interface CCButton : CCMenu {
}
+ (id)buttonWithText:(NSString*)text atPosition:(CGPoint)position target:(id)target selector:(SEL)selector;
+ (id)buttonWithImage:(NSString*)file atPosition:(CGPoint)position target:(id)target selector:(SEL)selector;
+ (id)buttonWithImages:(NSString*)file imagePressed:(NSString*)file2 atPosition:(CGPoint)position target:(id)target selector:(SEL)selector;
+ (id)buttonWithImagesAndLabel:(NSString*)file imagePressed:(NSString*)file2 label:(NSString*)l atPosition:(CGPoint)position target:(id)target selector:(SEL)selector;
@end
 
@interface CCButtonItem : CCMenuItem {
	CCSprite *back;
	CCSprite *backPressed;
}
+ (id)buttonWithText:(NSString*)text target:(id)target selector:(SEL)selector;
+ (id)buttonWithImage:(NSString*)file target:(id)target selector:(SEL)selector;
+ (id)buttonWithImages:(NSString*)file filePressed:(NSString*)file2 target:(id)target selector:(SEL)selector;
+ (id)buttonWithImagesAndLabel:(NSString*)file imagePressed:(NSString*)file2 label:(NSString*)l atPosition:(CGPoint)position target:(id)target selector:(SEL)selector;
- (id)initWithText:(NSString*)text target:(id)target selector:(SEL)selector;
- (id)initWithImage:(NSString*)file target:(id)target selector:(SEL)selector;
- (id)initWithImages:(NSString*)file filePressed:(NSString*)file2 target:(id)target selector:(SEL)selector;
- (id)initWithImagesAndLabel:(NSString*)file filePressed:(NSString*)file2 label:(NSString*)l target:(id)target selector:(SEL)selector;
@end