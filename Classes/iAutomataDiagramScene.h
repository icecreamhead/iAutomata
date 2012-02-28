//
//  iAutomataDiagramScene.h
//  iAutomata
//
//  Created by Josh on 04/01/2011.
//  Copyright 2011 Josh Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCUIViewWrapper.h"
#import "CCButton.h"
#import "iAutomataMachine.h"
#import "CCStateSprite.h"
#import "FRCurve.h"
#import "CCTransitionSprite.h"

//static CGSize globalSize;

@interface iAutomataDiagram : CCColorLayer <UITextFieldDelegate,UIAlertViewDelegate> {	
	UIToolbar *barTop, *barBottom;
	//UIButton *btnMenu;
	CGSize size;
	iAutomataMachine *machine;
	BOOL barLoaded,paused_,touchMoved_,listeningForSecondTap,doubleTapped,enteringSymbol,accessingStateMenu,accessingTransitionMenu;
	CGPoint startPoint_,currentPoint_,endPoint_;
	CCStateSprite *touchedSprite,*stateSpriteToEdit;
    CCTransitionSprite *touchedTransition, *transitionToEdit;
	FRCurve *transitionBlueprint;
	UIAlertView *enterSymbolAlert,*stateOptionsAlert,*changeStateNameAlert,*transitionOptionsAlert,*updateSymbolAlert;
	iAutomataTransition *transitionToUpdate;
	int stateNumber;
    UISlider *sldSpeed;
    CCScene *helpView;
}
@property (nonatomic,retain) UIToolbar *barTop, *barBottom;
//@property (nonatomic,retain) UIButton *btnMenu;
//@property (nonatomic, retain) CGSize size;
+ (id) scene;
- (id) scene;
-(void) drawview;
-(void) warmup;
- (void) cooldown;
- (void) closeKeyboard;
- (NSString*) getInput;
- (void) initToolbars;
- (void) setMachineControlsEnabled:(BOOL)enabled;
- (void) togglePlayPauseButton;
-(void)testMachine;
-(UIToolbar*)barTop;
- (CGPoint)validatePosition:(CGPoint)p;
+ (CGSize)getSize;
-(void)startListening;
-(void)stopListening;
- (BOOL)isPaused;
-(float)speedToInterval:(int)s;
@end
