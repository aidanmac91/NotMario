//
//  GameLevelScene.h
//  SuperKoalio
//

//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class GameLevelScene;
@protocol GameLevelSceneDelegate <NSObject>


-(void)moveForward;
@property (nonatomic, assign) BOOL isMoving;
//@property (nonatomic) int currentLevel;

@end
@interface GameLevelScene : SKScene
{
  NSTimer *timer;
}


//@property (nonatomic, assign) BOOL isMoving;
@end
