//
//  iAutomataTransition.m
//  iAutomata
//
//  Created by Josh on 04/01/2011.
//  Copyright 2011 Josh Cooke. All rights reserved.
//

#import "iAutomataTransition.h"


@implementation iAutomataTransition

+ (iAutomataTransition*)initWithFromState:(iAutomataState *)startState toState:(iAutomataState *)endState symbol:(unichar)sym {
	iAutomataTransition *t = [[[iAutomataTransition alloc] init] autorelease];
	if (t) {
		[t setFromState:startState];
		[t setToState:endState];
		[t setSymbol:sym];
	}
	return t;
}

- (iAutomataTransition*)init {
	//symbols = [[NSMutableArray alloc] init];
	return self;
}

- (iAutomataState*)getFromState {
	return fromState;
}
- (void)setFromState:(iAutomataState*)state {
	fromState = state;
}
- (iAutomataState*)getToState {
	return toState;
}
- (void)setToState:(iAutomataState*)state {
	toState = state;
}
- (unichar)getSymbol {
	return symbol;
}
- (void)setSymbol:(unichar)sym {
	symbol = sym;
}
- (NSString*)toString {
	NSString *s = [NSString stringWithFormat:@"%@--%c->%@",[fromState getName],symbol, [toState getName]];
	return s;
}

@end
