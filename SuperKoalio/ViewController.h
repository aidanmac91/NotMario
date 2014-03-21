//
//  ViewController.h
//  SuperKoalio
//

//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameLevelScene.h"
@interface ViewController : UIViewController <GameLevelSceneDelegate>

@property (nonatomic, weak) id <GameLevelSceneDelegate> delegate;

@end
