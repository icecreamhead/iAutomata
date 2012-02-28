//
//  iAutomataMachine.m
//  iAutomata
//
//  Created by Josh on 04/01/2011.
//  Copyright 2011 Josh Cooke. All rights reserved.
//

#import "iAutomataMachine.h"
#import "iAutomataDiagramScene.h"
#import "CCStateSprite.h"
#import "CCTransitionSprite.h"

@implementation iAutomataMachine
@synthesize steps;
@synthesize prevStep;

+(iAutomataMachine*)init {
	iAutomataMachine *m = [[[iAutomataMachine alloc] init] autorelease];
	if (m) {
		[m setName:@""];
	}
	return m;
}
-(iAutomataMachine*)init{
	_states = [[NSMutableArray alloc] init];
	_transitions = [[NSMutableArray alloc] init];
	_alphabet = [[NSMutableArray alloc] init];
	_acceptStates = [[NSMutableArray alloc] init];
	steps = 0;
	return self;
}
-(void)setParent:(iAutomataDiagram*)s {
	parent = s;
}
-(void)setName:(NSString *)n {
	name = n;
}
-(NSString*)getName{
	return name;
}
-(void)addState:(iAutomataState*)state {
	[_states addObject:state];
	if ([state isStartState]) {
		[self addAcceptState:state];
	}
	[parent addChild:[CCStateSprite spriteWithState:state target:self selector:nil] z:2 tag:7];
}
-(void)removeStateByName:(NSString*)n{
	BOOL found = NO;
	iAutomataState *deleteState = [[iAutomataState alloc] init];
	for (iAutomataState *s in _states) {
		if ([s getName] == n) {
			deleteState = s;
			found = YES;
			break;
		}
	}
	if (found) {
		NSLog(@"State removed: %@",[deleteState getName]);
		[_states removeObject:deleteState];
	} else {
		NSLog(@"State could not be deleted: No state with that name exists in the machine!");
	}
}
-(iAutomataState*)getStateByName:(NSString*)n{
	for (iAutomataState *s in _states) {
		if ([s getName] == n) {
			return s;
		}
	}
	NSLog(@"State not found: %@",n);
	return nil;
}
-(void)addTransition:(iAutomataTransition*)trans{
	BOOL found = NO;
	for (iAutomataTransition *t in _transitions) {
		if ([[[t getFromState] getName] isEqualToString:[[trans getFromState] getName]] && [[[t getToState] getName] isEqualToString:[[trans getToState] getName]] && [t getSymbol] == [trans getSymbol]) {
			NSLog(@"Transition already exists");
			found = YES;
		}
	}
	if (!found) {
		NSLog(@"Adding transition");
		[_transitions addObject:trans];
		[parent addChild:[[CCTransitionSprite alloc] spriteWithTransition:trans] z:1 tag:15];
		[self addSymbol:[trans getSymbol]];
	}	
}
-(void)removeTransitionWithLabel:(unichar)label fromStateName:(NSString*)fromState toStateName:(NSString*)toState{
	BOOL foundTransition = NO;
	iAutomataTransition *deleteTransition = nil;
	for (iAutomataTransition *t in _transitions) {
		if (([[t getFromState] getName] == fromState) && ([[t getToState] getName] == toState) && ([t getSymbol] == label)) {
			NSLog(@"Transition found: %@",[t toString]);
			deleteTransition = t;
			[deleteTransition retain];
			foundTransition = YES;
			break;
		}
	}
	if (foundTransition) {
		NSLog(@"Deleting transition: %@",[deleteTransition toString]);
		[_transitions removeObject:deleteTransition];
		[self removeSymbol:[deleteTransition getSymbol]];
	} else {
		NSLog(@"Could not find transition %@--%@->%@",fromState,label,toState);
	}
}
-(iAutomataTransition*)getTransitionWithLabel:(unichar)label fromStateName:(NSString*)fromState toStateName:(NSString*)toState{
	for (iAutomataTransition *t in _transitions) {
		if (([[t getFromState] getName] == fromState) && ([[t getToState] getName] == toState) && ([t getSymbol] == label)) {
			NSLog(@"Transition found: '%@'",[t toString]);
			return t;
		}
	}
	NSLog(@"Could not find transition %@--%c->%@",fromState,label,toState);
	return nil;
}
-(BOOL)transitionExistsFrom:(iAutomataState*)s WithLabel:(unichar)label {
	for (iAutomataTransition *t in _transitions) {
		if ([t getSymbol] == label && [t getFromState] == s) {
			return YES;
		}
	}
	return NO;
}
-(int)numberOfTransitionsFromState:(iAutomataState*)s {
	int i = 0;
	for (iAutomataTransition *t in _transitions) {
		if ([t getFromState] == s) {
			i++;
		}
	}
	return i;
}
-(NSMutableArray*)getTransitions {
	return _transitions;
}
-(void)addSymbol:(unichar)symbol{
	for (int i = 0; i < [_alphabet count]; i++) {
		if (symbol == [(NSNumber*)[_alphabet objectAtIndex:i] charValue]) {
			NSLog(@"Symbol already in alphabet: '%c'",symbol);
			return;
		}
	}
	NSLog(@"Symbol added to alphabet: %c",symbol);
	[_alphabet addObject:[NSNumber numberWithChar:symbol]];
}
-(void)removeSymbol:(unichar)symbol{
	for (iAutomataTransition *t in _transitions) {
		if ([t getSymbol] == symbol) {
			NSLog(@"Symbol in use: '%c'",symbol);
			return;
		}
	}
	int i = -1;
	for (NSNumber *n in _alphabet) {
		i++;
		if ([n charValue] == symbol) {
			break;
		}
	}
	NSLog(@"Symbol removed from alphabet: '%c'",symbol);
	[_alphabet removeObjectAtIndex:i];
}
-(NSMutableArray*)getSymbols{
	return _alphabet;
}
-(void)setStartState:(iAutomataState*)state{
	[self removeStartState];
	startState = state;
	[state makeStartState];
}
-(void)removeStartState{
	[startState removeStartState];
	startState = nil;
}
-(iAutomataState*)getStartState{
	return startState;
}
-(void)addAcceptState:(iAutomataState*)state {
	[state makeAcceptState];
	[_acceptStates addObject:state];
}
-(void)removeAcceptState:(NSString*)n{
	iAutomataState *removeState = nil;
	BOOL found = NO;
	for (iAutomataState *s in _acceptStates) {
			if ([s getName] == n) {
				removeState = s;
				found = YES;
				break;
			}
	}
	if (found) {
		[_acceptStates removeObject:removeState];
		[removeState removeAcceptState];
	} else {
		NSLog(@"Accept state not found");
	}
}
-(iAutomataState*)getAcceptState:(NSString*)n {
	for (iAutomataState *s in _acceptStates) {
		if ([s getName] == n) {
			return s;
		}
	}
	NSLog(@"Accept state not found");
	return nil;
}
-(NSString*)getInput {
	return input;
}
-(void)setInput:(NSString*)i {
	input = i;
	//initInput = [NSString stringWithString:input];
	initInput = [input copy];
	NSLog(@"Input set: %@",input);
}
-(BOOL)runMachineAtSpeed:(float)s; {
	/*
    if (s > 1) {
        speed = (s - 1) * 10;
    } else {
        speed = 1 - s;
    }
     */
    speed = s;
	if ([self validateMachine] && [self validateInput]) {
		activeState = startState;
		NSLog(@"Active state: %@",activeState);
		for (CCStateSprite *s in [parent children]) {
			if (s.tag == 7) {
				NSLog(@"Checking state: %@",[s getState]);
				if ([s getState] == activeState) {
					NSLog(@"Setting as active state!");
					[s setActive:YES];
				}
			}
		}
		NSLog(@"Running machine at speed: %f",speed);
		[self playMachine];
		return YES;
	} else {
		return NO;
	}
}
-(void)executeNextStep {
	//NSLog(@"Stepping :)");
	//prevStep = [self mutableCopy];
	/* Do some stuff */
	unichar nextsym;
	if ([input length] > 0) {
		// continue
		NSLog(@"Input: %@",input);
		nextsym = [input characterAtIndex:0];
		input = [input substringFromIndex:1];
		[input retain];
		UITextField *t = (UITextField*)[(UIBarButtonItem*)[[[parent barTop] items] objectAtIndex:2] customView];
		t.text = input;
		//NSLog(@"Input: %@",input);
		for (iAutomataTransition *t in _transitions) {
			if ([[t getFromState] isEqual:activeState] && ([t getSymbol] == nextsym)) {
				activeState = [t getToState];
				NSLog(@"Current state: %@",[activeState getName]);
				
				for (CCStateSprite *s in [parent children]) {
					if (s.tag == 7) {
						[s setActive:NO];
						NSLog(@"Checking state: %@",[s getState]);
						if ([s getState] == activeState) {
							NSLog(@"Setting as active state!");
							[s setActive:YES];
						}
					}
				}
				for (CCTransitionSprite *ts in [parent children]) {
					if (ts.tag == 15) {
						[ts setActive:NO];
						if ([[ts getTransition] isEqual:t]) {
							NSLog(@"Setting as active transition!");
							[ts setActive:YES];
						}
					}
				}
				
				break;
			}
		}
		steps++;
		NSLog(@"%d steps",steps);
	} else {
		// end
		NSLog(@"Final state: %@",[activeState getName]);
		//if (!(BOOL)[_acceptStates indexOfObject:activeState]) {
		if ([activeState isAcceptState]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input Accepted!" message:@"" delegate:self cancelButtonTitle:@"Hurray!" otherButtonTitles:nil];
			[alert show];
			[alert release];
			//UITextField *t = (UITextField*)[(UIBarButtonItem*)[[[parent barTop] items] objectAtIndex:2] customView];
			//t.text = @"Done!";
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input Rejected!" message:@"" delegate:self cancelButtonTitle:@"Aww!" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		if (![parent isPaused]) {
			[parent togglePlayPauseButton];
		}
		[parent setMachineControlsEnabled:NO];
		UIBarButtonItem *btn = [[[parent barTop] items] objectAtIndex:4];
		btn.title = @"Run";
		[self resetMachine];
	}

}
-(void)pauseMachine{
	//NSLog(@"PauseMachine: Self = %@",self);
	[self unschedule:@selector(executeNextStep)];
}
-(void)playMachine{
	//NSLog(@"PlayMachine: Self = %@",self);
	[self schedule:@selector(executeNextStep) interval:speed];
}
-(void)stepForward{
	[self executeNextStep];
}
-(void)stepBack{
	//self = prevStep;
	//[self setSteps:[prevStep steps]];
	//[prevStep setSteps:[[prevStep prevStep] steps]];
}
-(void)updateSpeed:(float)s {
    NSLog(@"Updating speed: %f",s);
    speed = s;
}
-(void)continueExecution{
    [self playMachine];
}
-(void)resetMachine{
	//[self unschedule:@selector(executeNextStep:)];
	[self pauseMachine];
	input = @"";
	steps = 0; // example reset. implement all the others!
	UITextField *t = (UITextField*)[(UIBarButtonItem*)[[[parent barTop] items] objectAtIndex:2] customView];
	t.text = initInput;
	for (CCStateSprite *s in [parent children]) {
		if (s.tag == 7) {
			[s setActive:NO];
		}
		if (s.tag == 15) {
			[s setActive:NO];
		}
	}
}
-(void) schedule:(SEL)selector interval:(ccTime)interval
{
	NSAssert( selector != nil, @"Argument must be non-nil");
	NSAssert( interval >=0, @"Arguemnt must be positive");
	
	[[CCScheduler sharedScheduler] scheduleSelector:selector forTarget:self interval:interval paused:NO];
}
-(void) unschedule:(SEL)selector
{
	// explicit nil handling
	if (selector == nil)
		return;
	[[CCScheduler sharedScheduler] unscheduleSelector:selector forTarget:self];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
	iAutomataMachine *m = [[iAutomataMachine allocWithZone:zone] init];
    NSLog(@"_mutableCopy: %@", [m self]);
    //[newPlanet setName:name];
    //[newPlanet setType:type];
    //[newPlanet setMass:mass];
    //[newPlanet setIndex:index];
	[m setSteps:steps];
	
    //NSMutableArray *copiedArray = [[self data] mutableCopyWithZone:zone];
    //[newPlanet setData: copiedArray];
    //[copiedArray release];
	
    return(m);
}
-(BOOL)validateInput {
	for (int i = 0; i < [input length]; i++) {
		unichar c = [input characterAtIndex:i];
		BOOL found = NO;
		for (NSNumber *n in _alphabet) {
			unichar a = [n charValue];
			if (a == c) {
				found = YES;
				break;
			}
			NSLog(@"Input char: %c Alphabet char: %c\n",c,a);
		}
		if (!found) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Input" message:[NSString stringWithFormat:@"Input character '%c' is not in the alphabet!",c] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return NO;
		}
	}
	return YES;
}
-(BOOL)validateMachine {
	if ([_states count] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Machine" message:@"No states defined!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	}
	if (startState == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Machine" message:@"No start state defined!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	}
	if ([_acceptStates count] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Machine" message:@"No accept states defined!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	}
	if ([_transitions count] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Machine" message:@"No transitions have been defined!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	}
	for (iAutomataState *s in _states) {
		for (NSNumber *n in _alphabet) {
				if (![self transitionExistsFrom:s WithLabel:[n charValue]]) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid DFA" message:[NSString stringWithFormat:@"State %@ has no transition for symbol '%c'",[s getName],[n charValue]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
					[alert show];
					[alert release];
					return NO;
				}
		}
		if ([self numberOfTransitionsFromState:s] != [_alphabet count]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid DFA" message:[NSString stringWithFormat:@"State %@ has multiple transitions for the same symbol",[s getName]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return NO;
		}
	}
	return YES;
}
@end
