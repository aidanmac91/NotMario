//
//  Player.h
//  Not Mario
//
//  By Aidan McCarthy
//  Based on The Ray Wenderlick tutorial
//

#import <SpriteKit/SpriteKit.h>

@interface Player : SKSpriteNode
@property (nonatomic, assign) CGPoint desiredPosition;//position after move
@property (nonatomic, assign) CGPoint velocity;//speed of player
@property (nonatomic, assign) BOOL onGround;//is sprite on the ground
@property (nonatomic, assign) BOOL forwardMarch;//move forward
@property (nonatomic,assign) BOOL backwardMarch;//move backward
@property (nonatomic, assign) BOOL mightAsWellJump;//jump
//@property (nonatomic,assign) int currentLevel;

- (void)update:(NSTimeInterval)delta;//update player
- (CGRect)collisionBoundingBox;//is there a colision
@end
