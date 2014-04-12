//
//  AppDelegate.h
//  Not Mario
//
//  By Aidan McCarthy
//  Based on The Ray Wenderlick tutorial
//

#import <UIKit/UIKit.h>

#include <AudioToolbox/AudioToolbox.h>

#import <AVFoundation/AVFoundation.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) AVAudioPlayer *myAudioPlayer;
@end
