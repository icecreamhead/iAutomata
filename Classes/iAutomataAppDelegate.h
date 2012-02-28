//
//  iAutomataAppDelegate.h
//  iAutomata
//
//  Created by Josh on 02/01/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAutomataDiagramScene.h"
#import "iAutomataMenuScene.h"

@class RootViewController;

@interface iAutomataAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
