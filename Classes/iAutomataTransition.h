//
//  iAutomataTransition.h
//  iAutomata
//
//  Created by Josh on 04/01/2011.
//  Copyright 2011 Josh Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iAutomataState.h"


@interface iAutomataTransition : NSObject {
	@private
	iAutomataState *fromState;
	iAutomataState *toState;
	unichar symbol;
}

+ (iAutomataTransition*)initWithFromState:(iAutomataState*)startState toState:(iAutomataState*)endState symbol:(unichar)sym;
- (iAutomataTransition*)init;
- (iAutomataState*)getFromState;
- (void)setFromState:(iAutomataState*)state;
- (iAutomataState*)getToState;
- (void)setToState:(iAutomataState*)state;
- (void)setSymbol:(unichar)sym;
- (unichar)getSymbol;
- (NSString*)toString;

@end
