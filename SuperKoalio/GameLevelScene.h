//
//  GameLevelScene.h
//  Not Mario
//
//  By Aidan McCarthy
//  Based on The Ray Wenderlick tutorial
//

#import <SpriteKit/SpriteKit.h>
@class GameLevelScene;
@protocol GameLevelSceneDelegate <NSObject>

@end
@interface GameLevelScene : SKScene
{
  NSTimer *timer1;//countdown timer
}

@end
