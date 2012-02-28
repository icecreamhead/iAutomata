//
//  iAutomataDiagramScene.m
//  iAutomata
//
//  Created by Josh on 04/01/2011.
//  Copyright 2011 Josh Cooke. All rights reserved.
//

#import "iAutomataDiagramScene.h"
#import "iAutomataMenuScene.h"
#import "iAutomataMachine.h"
#import "CCStateSprite.h"
#import "CCTransitionSprite.h"
#import "FRCurve.h"
#import "AlertPrompt.h"

@implementation iAutomataDiagram
@synthesize barTop, barBottom;
static CGSize globalSize;
//+(void)initialize {
//	[super initialize];
//	globalSize = [[CCDirector sharedDirector] winSize];
//}
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	iAutomataDiagram *layer = [iAutomataDiagram node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	iAutomataDiagram *layer = self;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)] )) {
		
		// Get screen size
		size = [[CCDirector sharedDirector] winSize];
		globalSize = size;
		stateNumber = 0;
		// Make toolbars
		[self initToolbars];
		
		// create and initialize a Label
		//CCLabelTTF *label = [CCLabelTTF labelWithString:@"Diagram View!" fontName:@"Marker Felt" fontSize:36];
		//label.position =  ccp( size.width /2 , size.height/2 );
		//label.color = ccBLACK;
		//label.tag = 1;
		//[self addChild: label];
		
		NSLog(@"Making machine...");
		machine = [[iAutomataMachine alloc] init];
		[machine setParent:self];
		//[self testMachine];
		
		/* Code to switch back to menu automatically */
			//[self schedule:@selector(onEnd:) interval:5];
		/*------------------------------------------- */
		barLoaded = NO;
		paused_ = YES;
		doubleTapped = NO;
		listeningForSecondTap = NO;
	}
	[self setIsTouchEnabled:YES];
	return self;
}
+ (CGSize)getSize {
	return globalSize;
}
// Switches back to menu
- (void)backToMenu:(ccTime)dt
{
	NSLog(@"Returning to menu");
	//[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionSlideInL class] duration:1.0f];
	barLoaded = NO;
	[self cooldown];
	if (!paused_) {
		[machine pauseMachine];
	}
	[[CCDirector sharedDirector] popScene];
	printf("retain count: %d\n",[self retainCount]);
	
}

-(void)draw {
	[self drawview];
	/* Custom code to update view */
	if (!barLoaded) {
		[self warmup];
		barLoaded = YES;
	}
}

-(void)drawview {
	
	// Standard drawing code from superclass draw method
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, GL_COLOR_ARRAY
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
	
	BOOL newBlend = NO;
	if( blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST ) {
		newBlend = YES;
		glBlendFunc(blendFunc_.src, blendFunc_.dst);
	}
	else if( opacity_ != 255 ) {
		newBlend = YES;
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	// restore default GL state
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
}

- (void) warmup {
	CCUIViewWrapper *barTopWrapper = [CCUIViewWrapper wrapperForUIView:barTop];
	barTopWrapper.position = ccp(0,size.height);
	[self addChild:barTopWrapper z:1 tag:2];	

	CCUIViewWrapper *barBottomWrapper = [CCUIViewWrapper wrapperForUIView:barBottom];
	barBottomWrapper.position = ccp(0,44); // set back to 44
	[self addChild:barBottomWrapper z:1 tag:3];
	
	if (!paused_) {
		[machine playMachine];
	}
}

- (void) cooldown {
	[self removeChildByTag:2 cleanup:YES];
	[self removeChildByTag:3 cleanup:YES];
	if (!paused_) {
		[machine pauseMachine];
	}
}

- (void) testMachine {
	iAutomataState *s = [iAutomataState initWithName:@"q0" coordinates:ccp(70,152)];
	[machine addState:s];
	[machine addState:[iAutomataState initWithName:@"q1" coordinates:ccp(150,250)]];
	[machine addState:[iAutomataState initWithName:@"q2" coordinates:ccp(250,350)]];
	[machine setStartState:[machine getStateByName:@"q0"]];
	[machine addAcceptState:[machine getStateByName:@"q0"]];
	[machine addTransition:[iAutomataTransition initWithFromState:[machine getStateByName:@"q0"] toState:[machine getStateByName:@"q0"] symbol:'0']];
	[machine addTransition:[iAutomataTransition initWithFromState:[machine getStateByName:@"q0"] toState:[machine getStateByName:@"q1"] symbol:'1']];
	[machine addTransition:[iAutomataTransition initWithFromState:[machine getStateByName:@"q1"] toState:[machine getStateByName:@"q2"] symbol:'1']];
	[machine addTransition:[iAutomataTransition initWithFromState:[machine getStateByName:@"q1"] toState:[machine getStateByName:@"q0"] symbol:'0']];
	[machine addTransition:[iAutomataTransition initWithFromState:[machine getStateByName:@"q2"] toState:[machine getStateByName:@"q2"] symbol:'1']];
	[machine addTransition:[iAutomataTransition initWithFromState:[machine getStateByName:@"q2"] toState:[machine getStateByName:@"q1"] symbol:'0']];
}

- (void) initToolbars {
	barTop = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, size.width, 44)];
	UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(backToMenu:)];
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, size.width-150, 30)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont systemFontOfSize:17.0];
	textField.textAlignment = UITextAlignmentCenter;
    textField.placeholder = @"Input String";
    textField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
    textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;  // has a clear 'x' button to the right
	[textField setText:@""];
    UIBarButtonItem *textFieldItem = [[UIBarButtonItem alloc] initWithCustomView:textField];
	UIBarButtonItem *btnRun = [[UIBarButtonItem alloc] initWithTitle:@"Run" style:UIBarButtonItemStyleDone target:self action:@selector(runMachine:)];
	NSMutableArray *barTopItems = [[NSMutableArray alloc] initWithObjects:btnMenu,spacer,textFieldItem,spacer,btnRun,nil];
	[btnMenu release];
	[barTop setItems:barTopItems];
    barTopItems = nil;
    [barTopItems release];
	
	barBottom = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, size.width, 44)];
	UIBarButtonItem *btnStepBack = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(stepBack:)];
	btnStepBack.enabled = NO;
	UIBarButtonItem *btnPlayPause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPause:)];
	btnPlayPause.enabled = NO;
	UIBarButtonItem *btnStepForward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(stepForward:)];
    UIBarButtonItem *btnHelp = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(showHelp)];
    [btnHelp setWidth:100.0];
	btnStepForward.enabled = NO;
	sldSpeed = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [sldSpeed setMinimumValue:1];
    [sldSpeed setMaximumValue:5];
    [sldSpeed setContinuous:NO];
    [sldSpeed setValue:3];
    [sldSpeed addTarget:self action:@selector(changeSpeed) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *slider = [[UIBarButtonItem alloc] initWithCustomView:sldSpeed];
    slider.enabled = NO;

	UIBarButtonItem *spacer10 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
	spacer10.width = 10;
	NSMutableArray *barBottomItems = [[NSMutableArray alloc] initWithObjects:btnHelp,spacer,btnStepBack,spacer10,btnPlayPause,btnStepForward,spacer,slider,nil];
	[barBottom setItems:barBottomItems];
}

-(void) dealloc {
	[super dealloc];
}

- (void)runMachine:(id)sender {
	[self closeKeyboard];
	UIBarButtonItem *btn = [[barTop items] objectAtIndex:4];
	if (btn.title == @"Run") {
		[machine setInput:[self getInput]];
        [sldSpeed setValue:3.0];
		if ([machine runMachineAtSpeed:[self speedToInterval:(int)[sldSpeed value]]]) {
			NSLog(@"Machine running...");
			btn.title = @"Stop";
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Running" message:[NSString stringWithFormat:@"Input: %@",[self getInput]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			//[alert show];
			[alert release];
			[self togglePlayPauseButton];
			[self setMachineControlsEnabled:YES];
		}
	} else {
		btn.title = @"Run";
		NSLog(@"Machine stopping...");
		if (!paused_) {
			[self togglePlayPauseButton];
		}
		[self setMachineControlsEnabled:NO];
		[machine resetMachine];
	}
}

- (void) closeKeyboard {
	UIBarButtonItem *inputButtonItem = [[barTop items] objectAtIndex:2];
	UITextField *inputField = (UITextField*)[inputButtonItem customView];
	[inputField resignFirstResponder];
}

- (NSString*) getInput {
	UIBarButtonItem *inputButtonItem = [[barTop items] objectAtIndex:2];
	UITextField *inputField = (UITextField*)[inputButtonItem customView];
	return inputField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

- (void) setMachineControlsEnabled:(BOOL)enabled {
	if (enabled) {
		((UIBarButtonItem*)[[barBottom items] objectAtIndex:4]).enabled = YES;
        ((UIBarButtonItem*)[[barBottom items] objectAtIndex:7]).enabled = YES;
		UITextField *t = (UITextField*)[(UIBarButtonItem*)[[barTop items] objectAtIndex:2] customView];
		t.enabled = NO;
		[self setIsTouchEnabled:NO];
	} else {
        BOOL first = YES;
		for (UIBarButtonItem *b in [barBottom items]){
			if (!first) {
                b.enabled = NO;
            }
            first = NO;
		}
		UITextField *t = (UITextField*)[(UIBarButtonItem*)[[barTop items] objectAtIndex:2] customView];
		t.enabled = YES;
		[self setIsTouchEnabled:YES];
	}
}
- (void)stepBack:(id)sender {
	[machine stepBack];
}
- (void)playPause:(id)sender {
	if (paused_) {
		[machine playMachine];
	} else {
		[machine pauseMachine];
	}
	[self togglePlayPauseButton];
}
- (void)stepForward:(id)sender {
	[machine stepForward];
}
- (void) togglePlayPauseButton {
	NSMutableArray *a = [NSMutableArray arrayWithArray:[barBottom items]];
	if (paused_) {
		[a replaceObjectAtIndex:4 withObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playPause:)]];
		[(UIBarButtonItem*)[a objectAtIndex:2] setEnabled:NO];
		[(UIBarButtonItem*)[a objectAtIndex:5] setEnabled:NO];
		paused_ = NO;
	} else {
		[a replaceObjectAtIndex:4 withObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPause:)]];
		/* Implement and enable me */ //[(UIBarButtonItem*)[a objectAtIndex:1] setEnabled:YES];
		[(UIBarButtonItem*)[a objectAtIndex:5] setEnabled:YES];
		paused_ = YES;
	}
	[barBottom setItems:a];
}
- (UIToolbar*)barTop {
	return barTop;
}
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self closeKeyboard];
	touchMoved_ = NO;
	touchedSprite = nil;
    touchedTransition = nil;
	UITouch *touch = [touches anyObject];
	CGPoint p = [touch locationInView:[touch view]];
	startPoint_ = [[CCDirector sharedDirector] convertToGL:p];
	
	// find state if touched state
	for (CCStateSprite *s in [self children]) {
		if (s.tag == 7) {
			if ((abs((int)[[s getState] getPosition].x - (int)startPoint_.x) < 30) && (abs((int)[[s getState] getPosition].y - (int)startPoint_.y) < 30)) {
				touchedSprite = s;
				break;
			}
		}
        
	}
    if (!touchedSprite) {
        for (CCTransitionSprite *t in [self children]) {
            if (t.tag == 15) {
                if ((abs((int)[[t getCurve] pointAtIndex:1].x - (int)startPoint_.x) < 20) && (abs((int)[[t getCurve] pointAtIndex:1].y - (int)startPoint_.y) < 20)) {
                    touchedTransition = t;
                    break;
                }
            }
            
        }
    }
    
	// resolve whether first or second click
	if (listeningForSecondTap) { // logic for double tap
		//NSLog(@"Second tap");
		[self stopListening];
		doubleTapped = YES;
		if (touchedSprite) { // draw transition blueprint
			transitionBlueprint = [[FRCurve curveFromType:kFRCurveLagrange order:kFRCurveQuadratic segments:2] retain];
			[transitionBlueprint setWidth:1.0f];
			[transitionBlueprint setShowControlPoints:NO];
			[transitionBlueprint setColor:ccc3(0, 0, 128)];
			[transitionBlueprint setPoint:startPoint_ atIndex:0];
			[transitionBlueprint setPoint:startPoint_ atIndex:1];
			[transitionBlueprint setPoint:startPoint_ atIndex:2];
			[transitionBlueprint invalidate];
			[self addChild:transitionBlueprint];
		}
	} else { // logic for first tap
		[self startListening];
		//NSLog(@"First tap");
		if (touchedSprite) { 
			accessingStateMenu = YES;
			stateSpriteToEdit = touchedSprite;
			[self schedule:@selector(startLongTapOnState:) interval:0.6];
		} else if (touchedTransition) {
            accessingTransitionMenu = YES;
            transitionToEdit = touchedTransition;
            [self schedule:@selector(startLongTapOnTransition:) interval:0.6];
        } else {
			[self schedule:@selector(startLongTapInOpen:) interval:0.6];
		}

	}
	
}
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:[touch view]];
	//startPoint_ = currentPoint_;
	currentPoint_ = [[CCDirector sharedDirector] convertToGL:p];
	currentPoint_ = [self validatePosition:currentPoint_];
	if (!touchMoved_) {
		touchMoved_ = YES;
		accessingStateMenu = NO;
        accessingTransitionMenu = NO;
		[self unschedule:@selector(startLongTapInOpen:)];
		[self unschedule:@selector(startLongTapOnState:)];
        [self unschedule:@selector(startLongTapOnTransition:)];
	}
	if (doubleTapped) {
		// do some double tap stuff
		//NSLog(@"Double tap drag");
		if (touchedSprite) {
			[transitionBlueprint setPoint:currentPoint_ atIndex:2];
			[transitionBlueprint invalidate];
		}
	} else {
		[self stopListening];
		if (touchedSprite) {
			[touchedSprite setPosition:currentPoint_];
			for (CCTransitionSprite *t in [self children]) {
				if (t.tag==15) {
					if ([[t getTransition] getFromState] == [touchedSprite getState] || [[t getTransition] getToState] == [touchedSprite getState]) {
                        [t update];
                    }
				}
			}			
		}
	}

}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:[touch view]];
	endPoint_ = [[CCDirector sharedDirector] convertToGL:p];
	endPoint_ = [self validatePosition:endPoint_];
	[self unschedule:@selector(startLongTapOnState:)];
	[self unschedule:@selector(startLongTapInOpen:)];
    [self unschedule:@selector(startLongTapOnTransition:)];
	accessingStateMenu = NO;
    accessingTransitionMenu = NO;
	if (doubleTapped) {
		// do some double tap stuff
		//NSLog(@"Double tap drag ended");
		doubleTapped = NO;
		if (touchedSprite) {
			[self removeChild:transitionBlueprint cleanup:YES];
			[transitionBlueprint release];
			// if dragged to other state, make new transition
			for (CCStateSprite *s in [self children]) {
				if (s.tag == 7) {
					if ((abs((int)[[s getState] getPosition].x - (int)endPoint_.x) < 30) && (abs((int)[[s getState] getPosition].y - (int)endPoint_.y) < 30)) {
						iAutomataTransition *t = [iAutomataTransition initWithFromState:[touchedSprite getState] toState:[s getState] symbol:' '];
						[machine addTransition:t];
                        
                        enterSymbolAlert = [[AlertPrompt alloc] initWithTitle:@"Enter transition symbol:" message:@"/n/n" delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"OK"];
                        [enterSymbolAlert show];
                        
                        /*
						enterSymbolAlert = [[[UIAlertView alloc] initWithTitle:@"Enter transition symbol:" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK",nil] retain];
						[enterSymbolAlert addTextFieldWithValue:@"" label:@"Symbol"];
						UITextField *textField = [enterSymbolAlert textFieldAtIndex:0];
						textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
						textField.keyboardAppearance = UIKeyboardAppearanceAlert;
						textField.autocapitalizationType  = UITextAutocapitalizationTypeNone;
						textField.autocorrectionType = UITextAutocapitalizationTypeNone;
						textField.textAlignment = UITextAlignmentCenter;
						*/
                        enteringSymbol = YES;
						transitionToUpdate = t;
						//UITextField *sym = [enterSymbolAlert textFieldAtIndex:0];
						//[t setSymbol:[[sym text] characterAtIndex:0]];
						//[alert release];
						//NSLog(@"Released alert");
						break;
					}
				}
			}
		}
	} else {
		//NSLog(@"Single tap drag ended");
	}

	touchedSprite = nil;
    touchedTransition = nil;
}
- (CGPoint)validatePosition:(CGPoint)p {
	if (p.x > size.width) {
		p.x = size.width;
	} else if (p.x < 0) {
		p.x = 0;
	}
	if (p.y > size.height - barTop.bounds.size.height) {
		p.y = size.height - barTop.bounds.size.height;
	} else if (p.y < barBottom.bounds.size.height) {
		p.y = barBottom.bounds.size.height;
	}
	return p;
}
-(void)listen:(ccTime)dt {
	[self stopListening];
}
-(void)startListening {
	listeningForSecondTap = YES;
	[self schedule:@selector(listen:) interval:0.3];
}
-(void)stopListening {
	listeningForSecondTap = NO;
	[self unschedule:@selector(listen:)];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == enterSymbolAlert) { // logic for transition symbol entry alert
        NSLog(@"Worked like a charm...");
		enteringSymbol = NO;
		
        UITextField *sym = [(AlertPrompt*)enterSymbolAlert textField];
        //NSString *sym = [(AlertPrompt*)enterSymbolAlert enteredText
        
        
		unichar oldSymbol = [transitionToUpdate getSymbol];
		if (buttonIndex == 0 || [[sym text] isEqualToString:@""]) {
			if ([[sym text] isEqualToString:@""] && buttonIndex == 1) {
				UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Symbol cannot be empty" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[a show];
				[a release];
			}
			[machine getTransitionWithLabel:[transitionToUpdate getSymbol] fromStateName:[[transitionToUpdate getFromState] getName] toStateName:[[transitionToUpdate getToState] getName]];
			[machine removeTransitionWithLabel:oldSymbol fromStateName:[[transitionToUpdate getFromState] getName] toStateName:[[transitionToUpdate getToState] getName]];
			CCTransitionSprite *transSpriteToRemove = nil;
			for (CCTransitionSprite *t in [self children]) {
				if (t.tag==15) {
					if ([t getTransition] == transitionToUpdate) {
						transSpriteToRemove = t;
					}
				}
			}
			[self removeChild:transSpriteToRemove cleanup:YES];
			[transSpriteToRemove release];
			[transitionToUpdate release]; 
			return;
		}

		//NSLog(@"Setting symbol... %c",[[sym text] characterAtIndex:0]);
		[transitionToUpdate setSymbol:[[sym text] characterAtIndex:0]];
		[machine addSymbol:[[sym text] characterAtIndex:0]];
		[machine removeSymbol:oldSymbol];
		//NSLog(@"Releasing alert...");
		[enterSymbolAlert release];
		for (CCTransitionSprite *t in [self children]) {
			if (t.tag==15) {
				[t update];
			}
		}
	} else if (alertView == stateOptionsAlert) { // Logic for state options menu
		iAutomataState *state = [stateSpriteToEdit getState];
		//NSLog(@"Hit logic for state options. State stored is '%@'",[state getName]);
		NSMutableArray *transitionsToRemove = [[NSMutableArray arrayWithCapacity:[[self children] count]] retain];
		switch (buttonIndex) {
			case 1: // make start state
				[machine setStartState:state];
				for (CCStateSprite *s in [self children]) {
					if (s.tag == 7) {
						if (stateSpriteToEdit != s) {
							[s setStart:NO];
						}
					}
				}
				[stateSpriteToEdit setStart:YES];
				break;
			case 2: // toggle accept state
				if ([state isAcceptState]) {
					[machine removeAcceptState:[state getName]];
					[stateSpriteToEdit setAccept:NO];
				} else {
					[machine addAcceptState:state];
					[stateSpriteToEdit setAccept:YES];
				}
				break;
			case 3: // change state name
				//[[stateSpriteToEdit getState] setName:@""]
                
                changeStateNameAlert = [[AlertPrompt alloc] initWithTitle:@"Set new state name:" message:@"/n/n" delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"OK"];
                
                
                
				//changeStateNameAlert = [[[UIAlertView alloc] initWithTitle:@"Set new state name" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil] retain];
				//[changeStateNameAlert addTextFieldWithValue:@"" label:@"State Name"];
				//UITextField *textField = [changeStateNameAlert textFieldAtIndex:0];
				//textField.keyboardType = UIKeyboardTypeDefault;
				//textField.keyboardAppearance = UIKeyboardAppearanceAlert;
				//textField.autocapitalizationType  = UITextAutocapitalizationTypeNone;
				//textField.autocorrectionType = UITextAutocapitalizationTypeNone;
				//textField.textAlignment = UITextAlignmentCenter;
				//enteringSymbol = YES;
				[changeStateNameAlert show];
				break;
			case 4: // delete state
				for (CCTransitionSprite *t in [self children]) {
					if (t.tag==15) {
						if ([[t getTransition] getFromState] == [stateSpriteToEdit getState] || [[t getTransition] getToState] == [stateSpriteToEdit getState]) {
							[transitionsToRemove addObject:t];
							[machine removeTransitionWithLabel:[[t getTransition] getSymbol] fromStateName:[[[t getTransition] getFromState] getName] toStateName:[[[t getTransition] getToState] getName]];
							//[self removeChild:t cleanup:YES];
						}
					}
				}
				for (int i = 0; i < [transitionsToRemove count]; i++) {
					[self removeChild:[transitionsToRemove objectAtIndex:i] cleanup:YES];
				}
				if ([machine getStartState] == [stateSpriteToEdit getState]) {
					[machine removeStartState];
				}
				if ([[stateSpriteToEdit getState] isAcceptState]) {
					[machine removeAcceptState:[[stateSpriteToEdit getState] getName]];
				}
				[machine removeStateByName:[[stateSpriteToEdit getState] getName]];
				[self removeChild:stateSpriteToEdit cleanup:YES];
				break;
			default:
				break;
		}
		[stateOptionsAlert release];
		[transitionsToRemove release];
	} else if (alertView == changeStateNameAlert) {
		NSString *newName = [NSString stringWithString:[[(AlertPrompt*)changeStateNameAlert textField] text]];
		//NSLog(@"entered name: %@",newName);
		if (buttonIndex == 1) {
			//[[stateSpriteToEdit getState] setName:newName];
			[stateSpriteToEdit setStateName:newName];
			//NSLog(@"state name: %@",[[stateSpriteToEdit getState] getName]);
		}
		[changeStateNameAlert release];
	} else if (alertView == transitionOptionsAlert) {
        if (buttonIndex == 1) { // delete
            [machine removeTransitionWithLabel:[[transitionToEdit getTransition] getSymbol] fromStateName:[[[transitionToEdit getTransition] getFromState] getName] toStateName:[[[transitionToEdit getTransition] getToState] getName]];
            [self removeChild:transitionToEdit cleanup:YES];
        } else if (buttonIndex == 2) { // change symbol
            
            updateSymbolAlert = [[AlertPrompt alloc] initWithTitle:@"Enter new transition symbol:" message:@"/n/n" delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"OK"];
            /*
            updateSymbolAlert = [[[UIAlertView alloc] initWithTitle:@"Enter new transition symbol:" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK",nil] retain];
            [updateSymbolAlert addTextFieldWithValue:@"" label:@"Symbol"];
            UITextField *textField = [updateSymbolAlert textFieldAtIndex:0];
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.keyboardAppearance = UIKeyboardAppearanceAlert;
            textField.autocapitalizationType  = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocapitalizationTypeNone;
            textField.textAlignment = UITextAlignmentCenter;
             */
            [updateSymbolAlert show];
        }
    } else if (alertView == updateSymbolAlert) {
        
        UITextField *sym = [(AlertPrompt*)updateSymbolAlert textField];
		unichar oldSymbol = [[transitionToEdit getTransition] getSymbol];
		if (buttonIndex == 0 || [[sym text] isEqualToString:@""]) {
			if ([[sym text] isEqualToString:@""] && buttonIndex == 1) {
				UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Symbol cannot be empty" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[a show];
				[a release];
			} 
			return;
		}
		//NSLog(@"Setting symbol... %c",[[sym text] characterAtIndex:0]);
		[[transitionToEdit getTransition] setSymbol:[[sym text] characterAtIndex:0]];
		[machine addSymbol:[[sym text] characterAtIndex:0]];
		[machine removeSymbol:oldSymbol];
		//NSLog(@"Releasing alert...");
        [transitionToEdit update];
        [updateSymbolAlert release];
    }
	//stateSpriteToEdit = nil;
	//[stateSpriteToEdit release];
}
-(void)startLongTapOnState:(ccTime)dt {
	[self unschedule:@selector(startLongTapOnState:)];
	stateOptionsAlert = [[UIAlertView alloc] initWithTitle:@"State options" message:@"" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:@"Make start state",@"Toggle accept state",@"Change name",@"Delete state",nil];
	[stateOptionsAlert show];
}
-(void)startLongTapOnTransition:(ccTime)dt {
    [self unschedule:@selector(startLongTapOnTransition:)];
    transitionOptionsAlert = [[UIAlertView alloc] initWithTitle:@"Transition Options" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Delete Transition",@"Change transition symbol", nil];
    [transitionOptionsAlert show];
    //[transitionOptionsAlert release];
}
-(void)startLongTapInOpen:(ccTime)dt {
	[self unschedule:@selector(startLongTapInOpen:)];
	//stateOptionsAlert = [[UIAlertView alloc] initWithTitle:@"State options" message:@"" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:@"Make start state",@"Toggle accept state",@"Change name",@"Delete state",nil];
	//[stateOptionsAlert show];
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New state added" message:@"Yay!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	//[alert show];
	//[alert release];
	[machine addState:[iAutomataState initWithName:[NSString stringWithFormat:@"q%d",stateNumber] coordinates:startPoint_]];
	stateNumber++;
}
- (BOOL)isPaused {
	return paused_;
}
- (void)showHelp {
    NSLog(@"Showing help view");
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:1.0 scene:currentDiagram]];
	//[[CCDirector sharedDirector] pushScene:[CCTransitionSlideInR transitionWithDuration:1.0 scene:currentDiagram]];
    helpView = [[CCScene alloc] init];
    
    CCSprite *helpImage = [CCSprite spriteWithFile:@"Help.png"];
    [helpImage setAnchorPoint:ccp(0.5,0.5)];
    
    helpImage.position = ccp([[CCDirector sharedDirector] winSize].width/2,[[CCDirector sharedDirector] winSize].height/2 - 22);
    [helpView addChild:helpImage];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[CCDirector sharedDirector] winSize].width, 44)];
    
    [toolbar setItems:[NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(closeHelp)]]];
    CCUIViewWrapper *barTopWrapper = [CCUIViewWrapper wrapperForUIView:toolbar];
	barTopWrapper.position = ccp(0,[[CCDirector sharedDirector] winSize].height);
	[helpView addChild:barTopWrapper z:1 tag:2];
	//[[CCDirector sharedDirector] pushScene:helpView];
    [[CCDirector sharedDirector] pushScene:[CCTransitionSlideInB transitionWithDuration:0.1 scene:helpView]];
    [self cooldown];
}
-(void)closeHelp {
    [helpView removeChildByTag:2 cleanup:YES];
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionSlideInB class] duration:0.1];
    [self warmup];
}
-(void)changeSpeed {
    NSLog(@"slider moved: %f",[sldSpeed value]);
    [machine updateSpeed:[self speedToInterval:[sldSpeed value]]];
    if (!paused_) {
        [machine continueExecution];
    }
}
-(float)speedToInterval:(int)s {
    switch (s) {
        case 1:
            return 5.0f;
            break;
        case 2:
            return 3.0f;
            break;
        case 3:
            return 1.0f;
            break;
        case 4:
            return 0.5f;
            break;
        case 5:
            return 0.01f;
            break;
        default:
            return 1.0f;
            break;
    }
}
@end
