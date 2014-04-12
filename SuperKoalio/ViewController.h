//
//  ViewController.h
//  Not Mario
//
//  By Aidan McCarthy
//  Based on The Ray Wenderlick tutorial
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameLevelScene.h"
@interface ViewController : UIViewController <GameLevelSceneDelegate>

@property (nonatomic, weak) id <GameLevelSceneDelegate> delegate;

@end
