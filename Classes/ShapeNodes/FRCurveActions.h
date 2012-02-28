//
//  FRCurveActions.h
//  Che
//
//  Created by Lam Pham on 11-01-29.
//  Copyright 2011 Fancy Rat Studios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "FRLines.h"

@interface FRActionLagrangeTo : CCActionInterval {
	ccpCurveCubicParams params_;
	CGPoint startPosition_;
}
+(id) actionWithDuration: (ccTime) t lagrange:(ccBezierConfig) config;
-(id) initWithDuration: (ccTime) t lagrange:(ccBezierConfig) config;
@end
