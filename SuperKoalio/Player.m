//
//  Player.m
//  Not Mario
//
//  By Aidan McCarthy
//  Based on The Ray Wenderlick tutorial
//

#import "Player.h"
#import "SKTUtils.h"

@implementation Player

int multiplierForDirection;//direction of player



/*
  initialise player with image
 set velocity
 */
- (instancetype)initWithImageNamed:(NSString *)name
{
  if (self == [super initWithImageNamed:name]) {
    self.velocity = CGPointMake(0.0, 0.0);
  }
  return self;
}


/*
 update player
 */
- (void)update:(NSTimeInterval)delta
{
  CGPoint gravity = CGPointMake(0.0, -450.0);//setup gravity
  CGPoint gravityStep = CGPointMultiplyScalar(gravity, delta);//gravity over time
  
  
  CGPoint forwardMove = CGPointMake(800.0, 0.0);//setup move forward
  CGPoint forwardMoveStep = CGPointMultiplyScalar(forwardMove, delta);//forward over time
  
  CGPoint backwardMove = CGPointMake(-800.0, 0.0);//setup move backward
  CGPoint backwardMoveStep = CGPointMultiplyScalar(backwardMove, delta);//backward over time

  self.velocity = CGPointAdd(self.velocity, gravityStep);//gravity affects speed

  self.velocity = CGPointMake(self.velocity.x * 0.9, self.velocity.y);//damping force to the horizontal velocity to simulate friction
  
  CGPoint jumpForce = CGPointMake(0.0, 310.0);
  float jumpCutoff = 150.0;
  
  if (self.mightAsWellJump && self.onGround)//jump from ground
  {
    self.velocity = CGPointAdd(self.velocity, jumpForce);//update velocity
    [self runAction:[SKAction playSoundFileNamed:@"jump.wav" waitForCompletion:NO]];//plays sound
  }
  else if (!self.mightAsWellJump && self.velocity.y > jumpCutoff)//jump in air
  {
    self.velocity = CGPointMake(self.velocity.x, jumpCutoff);//update velocity
  }
  
  if (self.forwardMarch)//player moves forward
  {
    self.velocity = CGPointAdd(self.velocity,forwardMoveStep);//applys velocity
    multiplierForDirection = 1;//forward direction
    self.xScale = fabs(self.xScale) * multiplierForDirection;//from animatedBear tutorial changes xScale to show player moving foward
  }
  
  if(self.backwardMarch)//player moves backward
  {
    self.velocity = CGPointAdd(self.velocity,backwardMoveStep);//applies velocity
    
    multiplierForDirection = -1;//backwards direction
    self.xScale = fabs(self.xScale) * multiplierForDirection;//from animatedBear tutorial changes xScale to show player moving foward

  }
  //limits the player’s maximum movement speed
  CGPoint minMovement = CGPointMake(450.0, -450);
  CGPoint maxMovement = CGPointMake(120.0, 250.0);
  self.velocity = CGPointMake(Clamp(self.velocity.x, -minMovement.x, maxMovement.x), Clamp(self.velocity.y, minMovement.y, maxMovement.y));
  
  CGPoint velocityStep = CGPointMultiplyScalar(self.velocity, delta);
  
  self.desiredPosition = CGPointAdd(self.position, velocityStep);
}

/*
 computes a bounding box based on the desired position, which the layer will use for collision detection.
 */
- (CGRect)collisionBoundingBox
{
  CGRect boundingBox = CGRectInset(self.frame, 2, 0);
  CGPoint diff = CGPointSubtract(self.desiredPosition, self.position);
  return CGRectOffset(boundingBox, diff.x, diff.y);
}


@end
