//
//  GameLevelScene.m
//  SuperKoalio
//
//  Created by Jake Gundersen on 12/27/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "GameLevelScene.h"
#import "JSTileMap.h"
#import "Player.h"
#import "SKTAudio.h"
#import "SKTUtils.h"

@interface GameLevelScene()<SKPhysicsContactDelegate>


@property (nonatomic, strong) JSTileMap *map;
@property (nonatomic, strong) Player *player;
@property (nonatomic, assign) NSTimeInterval previousUpdateTime;
@property (nonatomic, strong) TMXLayer *walls;
@property (nonatomic, strong) TMXLayer *hazards;
@property (nonatomic, strong) TMXLayer *prizes;
@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic) int numberOfLives;
@property (nonatomic)SKSpriteNode * monster;
@property (nonatomic, assign) int currentLevel;
@property (nonatomic)int timer;



@end



static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
  return CGPointMake(a.x + b.x, a.y + b.y);
}

//static inline CGPoint rwSub(CGPoint a, CGPoint b) {
//  return CGPointMake(a.x - b.x, a.y - b.y);
//}
static inline CGPoint rwMult(CGPoint a, float b) {
  return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
  return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
  float length = rwLength(a);
  return CGPointMake(a.x / length, a.y / length);
}

@implementation GameLevelScene
int currentLevel=0;
int numberOfLives=3;
int score=0;
bool isScoreable=YES;


-(id)initWithSize:(CGSize)size {
  _timer=10;
  [self startTimer];
  if (self = [super initWithSize:size]) {
    
    [self LoadLevel];
    
    UIImageView *likeImageImageview = [[UIImageView alloc] initWithFrame:CGRectMake(20,7.5,39.6,39.6)];
    
    UIImage *img0 = [UIImage imageNamed:@"heartDead"];
    [likeImageImageview setImage:img0];
    
    [self.view addSubview:likeImageImageview];
  }
  return self;
}

-(void)LoadLevel{
  NSLog(@"%d",numberOfLives);
  
  _monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
  if(currentLevel==1)
  {
    self.map = [JSTileMap mapNamed:@"level2.tmx"];
    [self addChild:self.map];
    
    //[[SKTAudio sharedInstance] playBackgroundMusic:@"level1.mp3"];
  }
  else if (currentLevel==2)
  {
    self.map = [JSTileMap mapNamed:@"level3.tmx"];
    [self addChild:self.map];
  }
  else{
    self.map = [JSTileMap mapNamed:@"level1.tmx"];
    [self addChild:self.map];
    
    
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    //monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
//        int minDuration = 2.0;
//    int maxDuration = 4.0;
//    int rangeDuration = maxDuration - minDuration;
//    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
//    SKAction * actionMove = [SKAction moveTo:CGPointMake(-_monster.size.width/2, 100) duration:actualDuration];
//    SKAction * actionMoveDone = [SKAction removeFromParent];
//   SKAction * loseAction = [SKAction runBlock:^{
//     NSLog(@"loss");
//      //SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
//      //SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
//      //[self.view presentScene:gameOverScene transition: reveal];
//    }];
//    [_monster runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
    

    
    //[[SKTAudio sharedInstance] playBackgroundMusic:@"Music1.mp3"];
  }
  
  //[[SKTAudio sharedInstance] playBackgroundMusic:@"Music1.mp3"];
  
  self.backgroundColor = [SKColor colorWithRed:.4 green:.4 blue:.95 alpha:1.0];
  self.walls = [self.map layerNamed:@"walls"];
  self.hazards = [self.map layerNamed:@"hazards"];
  self.prizes=[self.map layerNamed:@"prizes"];
  
  self.player = [[Player alloc] initWithImageNamed:@"koalio_stand"];
  self.player.position = CGPointMake(100, 80);
  self.player.zPosition = 15;
  [self.map addChild:self.player];
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, 0, 0);
  CGPathAddLineToPoint(path, NULL, 50, 00);
  SKAction *followline = [SKAction followPath:path asOffset:YES orientToPath:NO duration:3.0];
  SKAction *reversedLine = [followline reversedAction];
 // UIBezierPath *square = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 100, 100)];
//  SKAction *followSquare = [SKAction followPath:square.CGPath asOffset:YES orientToPath:NO duration:5.0];
//  UIBezierPath *circle = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 100, 100) cornerRadius:100];
//  SKAction *followCircle = [SKAction followPath:circle.CGPath asOffset:YES orientToPath:NO duration:5.0];
 // [_monster runAction:[SKAction sequence:@[followline, reversedLine]]];
  SKAction *sequence = [SKAction sequence:@[followline, reversedLine]];
  [_monster runAction:[SKAction repeatActionForever:sequence]];

 // self.player.physicsBody
//   self.player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: self.player.size.width/2];
//  self.player.physicsBody.dynamic = YES;
//   self.player.physicsBody.categoryBitMask = projectileCategory;
//   self.player.physicsBody.contactTestBitMask = monsterCategory;
//   self.player.physicsBody.collisionBitMask = 0;
//   self.player.physicsBody.usesPreciseCollisionDetection = YES;
//  //self.player.texture
//  
//  _monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_monster.size]; // 1
//  _monster.physicsBody.dynamic = YES; // 2
//  _monster.physicsBody.categoryBitMask = monsterCategory; // 3
//  _monster.physicsBody.contactTestBitMask = projectileCategory; // 4
//  _monster.physicsBody.collisionBitMask = 0; // 5
  self.userInteractionEnabled = YES;
  
}

- (void)update:(NSTimeInterval)currentTime
{
  
  UILabel *label=(UILabel *)[self.view viewWithTag:5];
  NSString *str = [NSString stringWithFormat:@"%d", _timer];
  [label setText:str];
  [label sizeToFit];
  
  if(_timer==0)
  {
   [self gameOver:0];
  }
  
  if(self.player.position.x-_monster.position.x<0.5 &&self.player.position.y-_monster.position.y<1)
  {
    //NSLog(@"Hit");
  }
  if (self.gameOver) return;

  NSTimeInterval delta = currentTime - self.previousUpdateTime;
 

  if (delta > 0.02) {
    delta = 0.02;
  }
  self.previousUpdateTime = currentTime;

  [self.player update:delta];
  
  [self checkForAndResolveCollisionsForPlayer:self.player forLayer:self.walls];
  [self handleHazardCollisions:self.player];
  [self handlePrizeCollisions:self.player];
  [self checkForWin];
  [self setViewpointCenter:self.player.position];
}

-(CGRect)tileRectFromTileCoords:(CGPoint)tileCoords
{
  float levelHeightInPixels = self.map.mapSize.height * self.map.tileSize.height;
  CGPoint origin = CGPointMake(tileCoords.x * self.map.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1) * self.map.tileSize.height));
  return CGRectMake(origin.x, origin.y, self.map.tileSize.width, self.map.tileSize.height);
}

- (NSInteger)tileGIDAtTileCoord:(CGPoint)coord forLayer:(TMXLayer *)layer
{
  TMXLayerInfo *layerInfo = layer.layerInfo;
  return [layerInfo tileGidAtCoord:coord];
}



- (void)checkForAndResolveCollisionsForPlayer:(Player *)player forLayer:(TMXLayer *)layer
{
  NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};
  player.onGround = NO;  ////Here
  for (NSUInteger i = 0; i < 8; i++) {
    NSInteger tileIndex = indices[i];
    
    CGRect playerRect = [player collisionBoundingBox];
    CGPoint playerCoord = [layer coordForPoint:player.desiredPosition];
    
    if (playerCoord.y >= self.map.mapSize.height - 1) {
      [self gameOver:0];
      return;
    }
    
    NSInteger tileColumn = tileIndex % 3;
    NSInteger tileRow = tileIndex / 3;
    CGPoint tileCoord = CGPointMake(playerCoord.x + (tileColumn - 1), playerCoord.y + (tileRow - 1));
    
    NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:layer];
    if (gid != 0) {
      CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
      //NSLog(@"GID %ld, Tile Coord %@, Tile Rect %@, player rect %@", (long)gid, NSStringFromCGPoint(tileCoord), NSStringFromCGRect(tileRect), NSStringFromCGRect(playerRect));
      //1
      if (CGRectIntersectsRect(playerRect, tileRect)) {
        CGRect intersection = CGRectIntersection(playerRect, tileRect);
        //2
        if (tileIndex == 7) {
          //tile is directly below Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height);
          player.velocity = CGPointMake(player.velocity.x, 0.0);
          player.onGround = YES;
        } else if (tileIndex == 1) {
          //tile is directly above Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y - intersection.size.height);
        } else if (tileIndex == 3) {
          //tile is left of Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x + intersection.size.width, player.desiredPosition.y);
        } else if (tileIndex == 5) {
          //tile is right of Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x - intersection.size.width, player.desiredPosition.y);
          //3
        } else {
          if (intersection.size.width > intersection.size.height) {
            //tile is diagonal, but resolving collision vertically
            //4
            player.velocity = CGPointMake(player.velocity.x, 0.0); ////Here
            float intersectionHeight;
            if (tileIndex > 4) {
              intersectionHeight = intersection.size.height;
              player.onGround = YES; ////Here
            } else {
              intersectionHeight = -intersection.size.height;
            }
            player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height );
          } else {
            //tile is diagonal, but resolving horizontally
            float intersectionWidth;
            if (tileIndex == 6 || tileIndex == 0) {
              intersectionWidth = intersection.size.width;
            } else {
              intersectionWidth = -intersection.size.width;
            }
            //5
            player.desiredPosition = CGPointMake(player.desiredPosition.x  + intersectionWidth, player.desiredPosition.y);
          }
        }
      }
    }
  }
  //6
  player.position = player.desiredPosition;
}

- (void)handleHazardCollisions:(Player *)player
{
  if (self.gameOver) return;
  NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};

  for (NSUInteger i = 0; i < 8; i++) {
    NSInteger tileIndex = indices[i];
    
    CGRect playerRect = [player collisionBoundingBox];
    CGPoint playerCoord = [self.hazards coordForPoint:player.desiredPosition];
    
    NSInteger tileColumn = tileIndex % 3;
    NSInteger tileRow = tileIndex / 3;
    CGPoint tileCoord = CGPointMake(playerCoord.x + (tileColumn - 1), playerCoord.y + (tileRow - 1));
    
    NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:self.hazards];
    if (gid != 0) {
      CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
      if (CGRectIntersectsRect(playerRect, tileRect)) {
       [self gameOver:0];
      
      }
    }
  }
}

- (void)handlePrizeCollisions:(Player *)player
{
  
  if (self.gameOver) return;
  NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};
  
  for (NSUInteger i = 0; i < 8; i++) {
    NSInteger tileIndex = indices[i];
    
    CGRect playerRect = [player collisionBoundingBox];
    CGPoint playerCoord = [self.prizes coordForPoint:player.desiredPosition];
    
    NSInteger tileColumn = tileIndex % 3;
    NSInteger tileRow = tileIndex / 3;
    CGPoint tileCoord = CGPointMake(playerCoord.x + (tileColumn - 1), playerCoord.y + (tileRow - 1));
    
    NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:self.prizes];
    if (gid != 0) {
      CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
      if (CGRectIntersectsRect(playerRect, tileRect)&& isScoreable) {
      //  [self gameOver:0];
        score++;
        NSLog(@"Score %d",score);
        //isScoreable=false;
      }
    }
//    if (!isScoreable) {
//      NSLog(@"sleep");
//      [NSThread sleepForTimeInterval:2.0f];
//      NSLog(@"sleep");
//      isScoreable=true;
//    }
  }
}

-(void)checkForWin {
  if (self.player.position.x > 3130.0) {
    [self gameOver:1];
  }
}

-(void)gameOver:(BOOL)won {
  self.gameOver = YES;
  [self runAction:[SKAction playSoundFileNamed:@"hurt.wav" waitForCompletion:NO]];
  
  NSString *gameText;
  
  
    
  if (won && currentLevel==2)
  {
    gameText=@"You beat the game!!";
    currentLevel=0;
    [self resetHearts];
  }
  else if (won) {
  gameText = @"You Won!";
  currentLevel++;
  }
  
  else if (_timer==0&&!won)
  {
    
    gameText = @"Time ran out!";
    numberOfLives--;
    
   UIImageView *imageView=(UIImageView *)[self.view viewWithTag:numberOfLives+1];
    [imageView setImage:[UIImage imageNamed:@"heartDead"]];
    _timer=-1;

  }
  else {
    gameText = @"You have Died!";
    numberOfLives--;
  
    UIImageView *imageView=(UIImageView *)[self.view viewWithTag:numberOfLives+1];
    [imageView setImage:[UIImage imageNamed:@"heartDead"]];
    //}
    //else if (numberOfLives==1)
    
  }
  
  if(numberOfLives==0)
  {
    [self resetHearts];
  }
	
  //1
  SKLabelNode *endGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
  endGameLabel.text = gameText;
  endGameLabel.fontSize = 40;
  endGameLabel.position = CGPointMake(self.size.width / 2.0, self.size.height / 1.7);
  [self addChild:endGameLabel];
  
  //2
  UIButton *replay = [UIButton buttonWithType:UIButtonTypeCustom];
  replay.tag = 321;
  UIImage *replayImage = [UIImage imageNamed:@"replay"];
  [replay setImage:replayImage forState:UIControlStateNormal];
  [replay addTarget:self action:@selector(replay:) forControlEvents:UIControlEventTouchUpInside];
  replay.frame = CGRectMake(self.size.width / 2.0 - replayImage.size.width / 2.0, self.size.height / 2.0 - replayImage.size.height / 2.0, replayImage.size.width, replayImage.size.height);
  [self.view addSubview:replay];
    //NSLog(@"Value2: %d",self.player.currentLevel);
}

//3
- (void)replay:(id)sender
{
  [[self.view viewWithTag:321] removeFromSuperview];
  //self.player.currentLevel=1;
  //NSLog(@"Value3: %d",self.player.currentLevel);
 // [self LoadLevel];
 [self.view presentScene:[[GameLevelScene alloc] initWithSize:self.size]];
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
     for (UITouch *touch in touches) {
    CGPoint touchLocation = [touch locationInNode:self];
   // NSLog(@"Point %f",touchLocation.x);
    //NSLog(@"Point %f",touchLocation.x);
    if(touchLocation.y<60)
    {
    if (touchLocation.x >=420 &&touchLocation.x<=450) {
      self.player.mightAsWellJump = YES;
    }
    else if (touchLocation.x<(110)&&touchLocation.x>(85))
    {
      self.player.forwardMarch=YES;
    }
    else if (touchLocation.x >=15 &&touchLocation.x<=65)
    {
      self.player.backwardMarch = YES;
    }
      else if (touchLocation.x<545&&touchLocation.x>520)
      {
              // NSLog(@"Position Monster: %@",NSStringFromCGPoint(_monster.position));
       // NSLog(@"Position Player: %@",NSStringFromCGPoint(self.position));
        
//        _monster.position=CGPointMake(self.player.position.x, self.player.position.y);
//        [self addChild:_monster];
//        
//        CGMutablePathRef path = CGPathCreateMutable();
//        CGPathMoveToPoint(path, NULL, 0, 0);
//        CGPathAddLineToPoint(path, NULL, 100, 00);
//        SKAction *followline = [SKAction followPath:path asOffset:YES orientToPath:NO duration:3.0];
//        SKAction *reversedLine = [followline reversedAction];
//        // UIBezierPath *square = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 100, 100)];
//        //  SKAction *followSquare = [SKAction followPath:square.CGPath asOffset:YES orientToPath:NO duration:5.0];
//        //  UIBezierPath *circle = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 100, 100) cornerRadius:100];
//        //  SKAction *followCircle = [SKAction followPath:circle.CGPath asOffset:YES orientToPath:NO duration:5.0];
//        // [_monster runAction:[SKAction sequence:@[followline, reversedLine]]];
//        SKAction *sequence = [SKAction sequence:@[followline, reversedLine]];
//        [_monster runAction:[SKAction repeatActionForever:sequence]];


      }
    }
  }
}

-(void)startTimer{
  timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES ];
  
}

-(void)countDown{
  _timer-=1;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    
    //float halfWidth = self.size.width / 2.0;
    CGPoint touchLocation = [touch locationInNode:self];
    
    //get previous touch and convert it to node space
    CGPoint previousTouchLocation = [touch previousLocationInNode:self];
    
    if(touchLocation.y<60)
    {
    if (touchLocation.x > 420 &&touchLocation.x<450 && previousTouchLocation.x <= 420&&previousTouchLocation.x>=450)
    {
      self.player.forwardMarch = NO;
      self.player.backwardMarch=NO;
      self.player.mightAsWellJump = YES;
    }
    else if (touchLocation.x <= 110 && touchLocation.x>=85 &&previousTouchLocation.x<85 &&previousTouchLocation.x>110) {
      self.player.forwardMarch = YES;
      //self.player.texture
      self.player.mightAsWellJump = NO;
      self.player.backwardMarch=NO;
    }
    else if (touchLocation.x<65 && touchLocation.x>15 && previousTouchLocation.x>=65)
    {
      self.player.forwardMarch=NO;
      self.player.mightAsWellJump=NO;
      self.player.backwardMarch=YES;
    }
//    else
//    {
//      self.player.forwardMarch=NO;
//      self.player.mightAsWellJump=NO;
//      self.player.backwardMarch=NO;
//    }
    }
  }
  
  
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  for (UITouch *touch in touches) {
    CGPoint touchLocation = [touch locationInNode:self];
    if(touchLocation.y<60)
    {
    if (touchLocation.x < 65 &&touchLocation.x>15) {
      self.player.backwardMarch=NO;
    }
    else if(touchLocation.x<110&&touchLocation.x>85)
    {
      self.player.forwardMarch = NO;
      
    }
    else if(touchLocation.x<450&&touchLocation.x>420)
    {
      self.player.mightAsWellJump = NO;
      //UITouch * touch = [touches anyObject];
      //CGPoint location = [touch locationInNode:self];
      [self shoot];
      
      // 2 - Set up initial location of projectile
     
      
     
    }
    }
  }
}

- (void)setViewpointCenter:(CGPoint)position
{
  NSInteger x = MAX(position.x, self.size.width / 2);
  NSInteger y = MAX(position.y, self.size.height / 2);
  x = MIN(x, (self.map.mapSize.width * self.map.tileSize.width) - self.size.width / 2);
  y = MIN(y, (self.map.mapSize.height * self.map.tileSize.height) - self.size.height / 2);
  CGPoint actualPosition = CGPointMake(x, y);
  CGPoint centerOfView = CGPointMake(self.size.width/2, self.size.height/2);
  CGPoint viewPoint = CGPointSubtract(centerOfView, actualPosition);
  self.map.position = viewPoint;
}

-(void)moveForward
{
    NSLog(@"THere is live");
}

-(void)resetHearts
{
  UIImageView *imageView=(UIImageView *)[self.view viewWithTag:1];
  [imageView setImage:[UIImage imageNamed:@"heartAlive"]];
  UIImageView *imageView1=(UIImageView *)[self.view viewWithTag:2];
  [imageView1 setImage:[UIImage imageNamed:@"heartAlive"]];
  UIImageView *imageView2=(UIImageView *)[self.view viewWithTag:3];
  [imageView2 setImage:[UIImage imageNamed:@"heartAlive"]];
}

-(void)shoot{
  SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
  projectile.position = self.player.position;
  // NSLog(@"Position: %@",NSStringFromCGPoint(self.player.position));
  //NSLog(@"Position1:%@",NSStringFromCGPoint(self.position));
  
  //projectile.position=100;
  
  CGPoint shootpoint;
  shootpoint.x=100;
  shootpoint.y=self.player.position.y;
  projectile.position=shootpoint;
  
  projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
  projectile.physicsBody.dynamic = YES;
  projectile.physicsBody.categoryBitMask = projectileCategory;
  projectile.physicsBody.contactTestBitMask = monsterCategory;
  projectile.physicsBody.collisionBitMask = 0;
  projectile.physicsBody.usesPreciseCollisionDetection = YES;
  
  // 3- Determine offset of location to projectile
  CGPoint offset ;//= rwSub(*location, projectile.position);
  // offset=(400
  // 4 - Bail out if you are shooting down or backwards
  if (offset.x <= 0) return;
  
  // NSLog(@"%@", NSStringFromCGPoint(offset));
  
  // 5 - OK to add now - we've double checked position
  [self addChild:projectile];
  offset.y=0;
  offset.x=400;
  
  // 6 - Get the direction of where to shoot
  CGPoint direction = rwNormalize(offset);
  
  // 7 - Make it shoot far enough to be guaranteed off screen
  CGPoint shootAmount = rwMult(direction, 1000);
  
  // 8 - Add the shoot amount to the current position
  CGPoint realDest = rwAdd(shootAmount, projectile.position);
  
  // 9 - Create the actions
  float velocity = 180.0/1.0;
  float realMoveDuration = self.size.width / velocity;
  SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
  SKAction * actionMoveDone = [SKAction removeFromParent];
  [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
  
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {
  NSLog(@"Hit");
  //[projectile removeFromParent];
  //[monster removeFromParent];
  //self.monstersDestroyed++;
  //if (self.monstersDestroyed > 1) {
   // SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
   // SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES];
   // [self.view presentScene:gameOverScene transition: reveal];
  //}
}

- (void)didBeginContact:(SKPhysicsContact *)contact{
  // 1
  SKPhysicsBody *firstBody, *secondBody;
  
  if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
  {
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
  }
  else
  {
    firstBody = contact.bodyB;
    secondBody = contact.bodyA;
  }
  
  // 2
  if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
      (secondBody.categoryBitMask & monsterCategory) != 0)
  {
    [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
  }
}
@end
