//
//  HelloWorldLayer.h
//  iAutomata
//
//  Created by Josh on 02/01/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "iAutomataDiagramScene.h"

// HelloWorld Layer
@interface iAutomataMenu : CCColorLayer
{
	@public
	 CCScene *currentDiagram;
     CCScene *feedbackView;
	 BOOL machineIsInitialised;
}

// returns a Scene that contains the iAutomataMenu as the only child
+(id) scene;

@end
