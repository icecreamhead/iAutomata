//
//  iAutomataMachine.h
//  iAutomata
//
//  Created by Josh on 04/01/2011.
//  Copyright 2011 Josh Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iAutomataState.h"
#import "iAutomataTransition.h"
#import "cocos2d.h"
@class iAutomataDiagram;

@interface iAutomataMachine : NSObject {
  @private
	NSString *name;
	NSMutableArray *_states;
	NSMutableArray *_transitions;
	NSMutableArray *_alphabet;
	iAutomataState *startState;
	NSMutableArray *_acceptStates;
	NSString *input,*initInput;
	float speed;
	iAutomataState *activeState;
	iAutomataMachine *prevStep;
	iAutomataDiagram *parent;
	int steps;
}
@property (nonatomic) int steps;
@property (nonatomic,retain) iAutomataMachine *prevStep;
+(iAutomataMachine*)init;
-(iAutomataMachine*)init;
-(void)setParent:(iAutomataDiagram*)s;
-(void)setName:(NSString*)n;
-(NSString*)getName;
-(void)addState:(iAutomataState*)state;
-(void)removeStateByName:(NSString*)name;
-(iAutomataState*)getStateByName:(NSString*)name;
-(void)addTransition:(iAutomataTransition*)trans;
-(void)removeTransitionWithLabel:(unichar)label fromStateName:(NSString*)fromState toStateName:(NSString*)toState;
-(iAutomataTransition*)getTransitionWithLabel:(unichar)label fromStateName:(NSString*)fromState toStateName:(NSString*)toState;
-(NSMutableArray*)getTransitions;
-(void)addSymbol:(unichar)symbol;
-(void)removeSymbol:(unichar)symbol;
-(NSMutableArray*)getSymbols;
-(void)setStartState:(iAutomataState*)state;
-(void)removeStartState;
-(iAutomataState*)getStartState;
-(void)addAcceptState:(iAutomataState*)state;
-(void)removeAcceptState:(NSString*)name;
-(iAutomataState*)getAcceptState:(NSString*)name;
-(NSString*)getInput;
-(void)setInput:(NSString*)i;
-(BOOL)runMachineAtSpeed:(float)s;
-(void)pauseMachine;
-(void)playMachine;
-(void)executeNextStep;
-(void)stepForward;
-(void)stepBack;
-(void)resetMachine;
-(void)schedule:(SEL)selector interval:(ccTime)interval;
-(void) unschedule:(SEL)selector;
-(BOOL)validateInput;
-(BOOL)validateMachine;
-(BOOL)transitionExistsFrom:(iAutomataState*)s WithLabel:(unichar)label;
-(void)updateSpeed:(float)s;
-(void)continueExecution;
@end
