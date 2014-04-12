//
//  GameLevelScene.m
//  Not Mario
//
//  By Aidan McCarthy
//  Based on The Ray Wenderlick tutorial
//

#import "GameLevelScene.h"
#import "JSTileMap.h"
#import "Player.h"
#import "SKTAudio.h"
#import "SKTUtils.h"
#import "InformationScene.h"

@interface GameLevelScene()<SKPhysicsContactDelegate>


@property (nonatomic, strong) JSTileMap *map;//current map
@property (nonatomic, strong) Player *player;//player
@property (nonatomic, assign) NSTimeInterval previousUpdateTime;//last update time
@property (nonatomic, strong) TMXLayer *walls;//wall layer
@property (nonatomic, strong) TMXLayer *hazards;//hazard layer
@property (nonatomic, assign) BOOL gameOver;//is game over
@property (nonatomic) BOOL marker1;//is first box hit
@property (nonatomic) BOOL marker2;//is second box hit
@property (nonatomic) BOOL marker3;//is third box hit
//@property (nonatomic) int numberOfLives;//number of lives
@property (nonatomic) bool firstTimePlay;//game started
@property (nonatomic)int timer;
@property (nonatomic) NSArray *marioWalkTextures;//mario walking images array
@property (nonatomic) NSArray *marioStandingTextures;//mario standing images array

@end

@implementation GameLevelScene
int currentLevel=0;//sets first level on startup
int numberOfLives=3;//set number of lives at startup
bool firstTimePlay=true;//is it the first time the game is being played


-(id)initWithSize:(CGSize)size {
  _timer=30;//set timer

  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];//hides status bar
  [self startTimer];//starts timer
  
  if (self = [super initWithSize:size]) {
    
    [self LoadLevel];//load a level
    
    
    //loads images for animations
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"mario"];
    SKTexture *f1 = [atlas textureNamed:@"mario-walk1.png"];
    SKTexture *f2 = [atlas textureNamed:@"mario-walk2.png"];
    SKTexture *f3 = [atlas textureNamed:@"mario-walk3.png"];
    SKTexture *f4 = [atlas textureNamed:@"mario-walk4.png"];
    SKTexture *f5 = [atlas textureNamed:@"mario-walk5.png"];
    _marioWalkTextures = @[f1,f2,f3,f4];//sets walking textures
    _marioStandingTextures=@[f5];//sets standing textures

  }
  return self;
}


/*
 loads a specific level and sound
 */
-(void)LoadLevel{
  
  
  //sets markers to true
  _marker1=YES;
  _marker2=YES;
  _marker3=YES;
  
  
  if(currentLevel==1)//second level
  {
    self.map = [JSTileMap mapNamed:@"level2.tmx"];//loads map
    [self addChild:self.map];//adds map to self
    
    [[SKTAudio sharedInstance] playBackgroundMusic:@"level2.mp3"];//plays sound
  }
  else if (currentLevel==2)//third level
  {
    self.map = [JSTileMap mapNamed:@"level3.tmx"];//loads map
    [self addChild:self.map];//adds map to self
    
    [[SKTAudio sharedInstance] playBackgroundMusic:@"level3.mp3"];//plays sound
  }
  else//first level
  {
    self.map = [JSTileMap mapNamed:@"level1.tmx"];//loads map
    [self addChild:self.map];//adds map to self
    
    [[SKTAudio sharedInstance] playBackgroundMusic:@"level1.mp3"];//plays sounds
  }
  
  self.backgroundColor = [SKColor colorWithRed:.4 green:.4 blue:.95 alpha:1.0];//sets background
  self.walls = [self.map layerNamed:@"walls"];//sets walls
  self.hazards = [self.map layerNamed:@"hazards"];//sets hazards
  
  self.player = [[Player alloc] initWithImageNamed:@"mario-walk5"];//inits player with image
  self.player.position = CGPointMake(100, 80);//sets position
  self.player.zPosition = 15;
  [self.map addChild:self.player];//adds player to map
  self.userInteractionEnabled = YES;//enables interactions
}

/*
 updated every frame
 */
- (void)update:(NSTimeInterval)currentTime
{
  UILabel *label=(UILabel *)[self.view viewWithTag:5];//sets label
  NSString *str = [NSString stringWithFormat:@"%d", _timer];//creates string from timer
  [label setText:str];//sets label text
  [label setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:40.0]];
  [label sizeToFit];//scale label
  
  if(_timer==0)//timer ran out
  {
    [self gameOver:0];//game over
  }
  
  if (self.gameOver) return;//
  
  NSTimeInterval delta = currentTime - self.previousUpdateTime;//change in time
  
  
  if (delta > 0.02)//if changle <0.2
  {
    delta = 0.02;
  }
  
  self.previousUpdateTime = currentTime;//set previousUpdateTime
  
  [self.player update:delta];//update player
  
  [self checkForAndResolveCollisionsForPlayer:self.player forLayer:self.walls];//check collsions
  [self handleHazardCollisions:self.player];//if collinding with hazard
  [self checkForWin];//check if win
  [self checkForMark];//check if colliding with box
  [self setViewpointCenter:self.player.position];
}

/*
 finds the pixel origin coordinate by multiplying the tile coordinate by the tile size.
 */
-(CGRect)tileRectFromTileCoords:(CGPoint)tileCoords
{
  float levelHeightInPixels = self.map.mapSize.height * self.map.tileSize.height;
  CGPoint origin = CGPointMake(tileCoords.x * self.map.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1) * self.map.tileSize.height));
  return CGRectMake(origin.x, origin.y, self.map.tileSize.width, self.map.tileSize.height);
}

/*
 TMXLayerInfo object property of the layer object
 */
- (NSInteger)tileGIDAtTileCoord:(CGPoint)coord forLayer:(TMXLayer *)layer
{
  TMXLayerInfo *layerInfo = layer.layerInfo;
  return [layerInfo tileGidAtCoord:coord];
}


/*
 check if colliding
 */
- (void)checkForAndResolveCollisionsForPlayer:(Player *)player forLayer:(TMXLayer *)layer
{
  NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};//create an array of indices that represent the positions of the tiles
  player.onGround = NO;
  for (NSUInteger i = 0; i < 8; i++) {
    NSInteger tileIndex = indices[i];
    
    CGRect playerRect = [player collisionBoundingBox];//box around player
    CGPoint playerCoord = [layer coordForPoint:player.desiredPosition];//gets coordinates
    
    if (playerCoord.y >= self.map.mapSize.height - 1)//fall through map
    {
      [self gameOver:0];//game over
      return;
    }
    
    NSInteger tileColumn = tileIndex % 3;
    NSInteger tileRow = tileIndex / 3;
    CGPoint tileCoord = CGPointMake(playerCoord.x + (tileColumn - 1), playerCoord.y + (tileRow - 1));
    
    NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:layer];
    if (gid != 0)
    {
      CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
      if (CGRectIntersectsRect(playerRect, tileRect))
      {
        CGRect intersection = CGRectIntersection(playerRect, tileRect);//collision
        if (tileIndex == 7)
        {
          //tile is directly below Mario
          player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height);
          player.velocity = CGPointMake(player.velocity.x, 0.0);
          player.onGround = YES;
        }
        else if (tileIndex == 1)
        {
          //tile is directly above Mario
          player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y - intersection.size.height);
        }
        else if (tileIndex == 3)
        {
          //tile is left of Mario
          player.desiredPosition = CGPointMake(player.desiredPosition.x + intersection.size.width, player.desiredPosition.y);
        }
        else if (tileIndex == 5)
        {
          //tile is right of Mario
          player.desiredPosition = CGPointMake(player.desiredPosition.x - intersection.size.width, player.desiredPosition.y);
        }
        else
        {
          if (intersection.size.width > intersection.size.height) {
            //tile is diagonal, but resolving collision vertically
            float intersectionHeight;
            if (tileIndex > 4)
            {
              intersectionHeight = intersection.size.height;
              player.onGround = YES;
            }
            else
            {
              intersectionHeight = -intersection.size.height;
            }
            player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height );
          }
          else
          {
            //tile is diagonal, but resolving horizontally
            float intersectionWidth;
            if (tileIndex == 6 || tileIndex == 0)
            {
              intersectionWidth = intersection.size.width;
            }
            else
            {
              intersectionWidth = -intersection.size.width;
            }
            player.desiredPosition = CGPointMake(player.desiredPosition.x  + intersectionWidth, player.desiredPosition.y);
          }
        }
      }
    }
  }
  player.position = player.desiredPosition;//sets position
}

/*
 handles what happens when colliding with hazards
 similar to checkForAndResolveCollisionsForPlayer:forLayer
 */
- (void)handleHazardCollisions:(Player *)player
{
  if (self.gameOver) return;
  
  NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};
  
  for (NSUInteger i = 0; i < 8; i++)
  {
    NSInteger tileIndex = indices[i];
    
    CGRect playerRect = [player collisionBoundingBox];
    CGPoint playerCoord = [self.hazards coordForPoint:player.desiredPosition];
    
    NSInteger tileColumn = tileIndex % 3;
    NSInteger tileRow = tileIndex / 3;
    CGPoint tileCoord = CGPointMake(playerCoord.x + (tileColumn - 1), playerCoord.y + (tileRow - 1));
    
    NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:self.hazards];
    if (gid != 0) {
      CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
      if (CGRectIntersectsRect(playerRect, tileRect))
      {
        [self gameOver:0];
      }
    }
  }
}

/*
 check if player won
 */
-(void)checkForWin {
  if (self.player.position.x > 3130.0)//reached end of track
  {
    [self gameOver:1];
  }
}

/*
 check if player is colliding on the box
 */
-(void)checkForMark{
  if (self.player.position.y >250)//once you are above 250
  {
    if(currentLevel==0)//level one location
    {
      if(self.player.position.x<312&&self.player.position.x>308)//box 1
      {
        if (_marker1)//if _marker1 is active
        {
          _timer+=30;//increase
          _marker1=false;//inactivate
          
          [self playCollectionSound];//play sound
        }
      }
      if(self.player.position.x<960&&self.player.position.x>945)//box 2
      {
        if (_marker2)//if _marker2 is active
        {
          _timer+=30;//increase
          _marker2=false;//inactivate
  
          [self playCollectionSound];//play sound
        }
      }
      if (self.player.position.x<1650&&self.player.position.x>1635)//box 3
      {
        if (_marker3)//if _marker3 is active
        {
          _timer+=30;//increase
          _marker3=false;//inactivate
          
          [self playCollectionSound];//play sound
        }
      }
    }
    if (currentLevel==1)//level two location
    {
      if(self.player.position.x<675&&self.player.position.x>650)//box 1
      {
        if (_marker1)//if _marker1 is active
        {
          _timer+=30;//increase
          _marker1=false;//inactivate
          
          [self playCollectionSound];//play sound
        }
      }
      if(self.player.position.x<1740&&self.player.position.x>1725)//box 2
      {
        if (_marker2)//if _marker2 is active
        {
          _timer+=30;//increase
          _marker2=false;//inactivate
          
          [self playCollectionSound];//play sound
        }
      }
      if (self.player.position.x<2305&&self.player.position.x>2285)//box 3
      {
        if (_marker3)//if _marker3 is active
        {
          _timer+=30;//increase
          _marker3=false;//inactivate
          
          [self playCollectionSound];//play sound
        }
      }
    }
    if (currentLevel==2)//level three location
    {
      if(self.player.position.x<430&&self.player.position.x>400)//box 1
      {
        if (_marker1)//if _marker1 is active
        {
          _timer+=30;//increase
          _marker1=false;//inactivate
          
          [self playCollectionSound];//play sound
        }
      }
      if(self.player.position.x<1310&&self.player.position.x>1295)//box 2
      {
        if (_marker2) //if _marker2 is active
        {
          _timer+=30;//increase
          _marker2=false;//inactivate
          
          [self playCollectionSound];//play sound
        }
      }
      if (self.player.position.x<2640&&self.player.position.x>2625)//box 3
      {
        if (_marker3)//if _marker3 is active
        {
          _timer+=30;//increase
          _marker3=false;//inactivate
          [self playCollectionSound];//play sound
        }
      }
    }
  }
}


/*
 play sound when timer is increased
 */
-(void)playCollectionSound{
   [self runAction:[SKAction playSoundFileNamed:@"timer.mp3" waitForCompletion:NO]];
}


/*
 game over won/lost
 */
-(void)gameOver:(BOOL)won
{
  self.gameOver = YES;//game over
  [self runAction:[SKAction playSoundFileNamed:@"hurt.wav" waitForCompletion:NO]];//sound when game over
  
  NSString *gameText;//text for label
  
  if (won && currentLevel==2)//finished the game
  {
    gameText=@"You beat the game!!";
    currentLevel=0;//reset
    [self resetHearts];//reset hearts
  }
  else if (won)//beat level
  {
    gameText = @"You Won!";
    currentLevel++;//next level
  }
  
  else if (_timer==0&&!won)//timer ran out
  {
    
    gameText = @"Time ran out!";
    numberOfLives--;//decrease lives
    
    UIImageView *imageView=(UIImageView *)[self.view viewWithTag:numberOfLives+1];//gets imageView
    [imageView setImage:[UIImage imageNamed:@"heartDead"]];//sets imageView
    _timer=-1;//sets timer to below 0 to prevent crashing
    
  }
  else//died
  {
    gameText = @"You have Died!";
    numberOfLives--;//decrease lives
    
    UIImageView *imageView=(UIImageView *)[self.view viewWithTag:numberOfLives+1];//gets imageView
    [imageView setImage:[UIImage imageNamed:@"heartDead"]];//sets imageView
  }
  
  if(numberOfLives==0)//game beat u
  {
    [self resetHearts];//resets hearts
  }
	
  //creates label and sets text
  SKLabelNode *endGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
  endGameLabel.text = gameText;
  endGameLabel.fontSize = 40;
  endGameLabel.position = CGPointMake(self.size.width / 2.0, self.size.height / 1.7);
  [self addChild:endGameLabel];
  
  //create button
  UIButton *replay = [UIButton buttonWithType:UIButtonTypeCustom];
  replay.tag = 321;
  UIImage *replayImage = [UIImage imageNamed:@"replay"];//sets image
  [replay setImage:replayImage forState:UIControlStateNormal];
  [replay addTarget:self action:@selector(replay:) forControlEvents:UIControlEventTouchUpInside];
  replay.frame = CGRectMake(self.size.width / 2.0 - replayImage.size.width / 2.0, self.size.height / 2.0 - replayImage.size.height / 2.0, replayImage.size.width, replayImage.size.height);
  [self.view addSubview:replay];
}

//reset level
- (void)replay:(id)sender
{
  [[self.view viewWithTag:321] removeFromSuperview];
  [self.view presentScene:[[GameLevelScene alloc] initWithSize:self.size]];
  
}

/*
 touch begins
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  
  for (UITouch *touch in touches) {
    CGPoint touchLocation = [touch locationInNode:self];
    if(touchLocation.y<60)//lower than the level of the game
    {
      if (touchLocation.x >=368 &&touchLocation.x<=544)//jump
      {
        self.player.mightAsWellJump = YES;
      }
      else if (touchLocation.x<(210)&&touchLocation.x>(122))//right
      {
        //sets animation and repeats it
        SKAction *walkAnimation = [SKAction animateWithTextures:_marioWalkTextures timePerFrame:0.1];
         SKAction *spinForever = [SKAction repeatActionForever:walkAnimation];
        [self.player runAction:spinForever];
        self.player.forwardMarch=YES;
      }
      else if (touchLocation.x >=26 &&touchLocation.x<=111)
      {
        //sets animation and repeats it
        SKAction *walkAnimation = [SKAction animateWithTextures:_marioWalkTextures timePerFrame:0.1];
        SKAction *spinForever = [SKAction repeatActionForever:walkAnimation];
        [self.player runAction:spinForever];
        self.player.backwardMarch = YES;
      }
      
    }
  }
}

/*
 displays scene with information about beating the game
 */
-(void)info
{
  if(firstTimePlay)//first time played
  {
  firstTimePlay=false;//toggles
  SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];//setup transition
  SKScene * info = [[InformationScene alloc] initWithSize:self.size];//creates instance of infromationscene
  [self.view presentScene:info transition: reveal];//transition to scene
  }
}

/*
 if the player moves without lifting their fingers
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  for (UITouch *touch in touches) {
    
    CGPoint touchLocation = [touch locationInNode:self];//sets point of press
    
    //get previous touch and convert it to node space
    CGPoint previousTouchLocation = [touch previousLocationInNode:self];
    
    if(touchLocation.y<60)//below level of ground
    {
      if (touchLocation.x > 368 &&touchLocation.x<544 && previousTouchLocation.x <= 368&&previousTouchLocation.x>=544)//jump
      {
        self.player.forwardMarch = NO;
        self.player.backwardMarch=NO;
        self.player.mightAsWellJump = YES;
      }
      else if (touchLocation.x <= 210 && touchLocation.x>=122 &&previousTouchLocation.x<122 &&previousTouchLocation.x>210)//forward
      {
        self.player.forwardMarch = YES;
        self.player.mightAsWellJump = NO;
        self.player.backwardMarch=NO;
      }
      else if (touchLocation.x<111 && touchLocation.x>26 && previousTouchLocation.x>=111)//backward
      {
        self.player.forwardMarch=NO;
        self.player.mightAsWellJump=NO;
        self.player.backwardMarch=YES;
      }
    }
  }
  
  
}

/*
 finger lefted off screen
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  
  for (UITouch *touch in touches)
  {
    CGPoint touchLocation = [touch locationInNode:self];
    if(touchLocation.y<60)//below level of ground
    {
      if (touchLocation.x < 111 &&touchLocation.x>26)//stop backward
      {
        self.player.backwardMarch=NO;
        
        SKAction *standingAnimation = [SKAction animateWithTextures:_marioStandingTextures timePerFrame:0.1];
        SKAction *spinForever = [SKAction repeatActionForever:standingAnimation];
        [self.player runAction:spinForever];
      }
      else if(touchLocation.x<210&&touchLocation.x>122)//stop forward
      {
        self.player.forwardMarch = NO;
        
        SKAction *standingAnimation = [SKAction animateWithTextures:_marioStandingTextures timePerFrame:0.1];
        SKAction *spinForever = [SKAction repeatActionForever:standingAnimation];
        [self.player runAction:spinForever];
        
      }
      else if(touchLocation.x<544&&touchLocation.x>368)//stop jump
      {
        self.player.mightAsWellJump = NO;
        
        SKAction *standingAnimation = [SKAction animateWithTextures:_marioStandingTextures timePerFrame:0.1];
        SKAction *spinForever = [SKAction repeatActionForever:standingAnimation];
        [self.player runAction:spinForever];
      }
      
      //standing animation
    }
  }
}

/*
 centers view on player
 */
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

/*
 resets images
 */
-(void)resetHearts
{
  UIImageView *imageView=(UIImageView *)[self.view viewWithTag:1];
  [imageView setImage:[UIImage imageNamed:@"heartAlive"]];
  UIImageView *imageView1=(UIImageView *)[self.view viewWithTag:2];
  [imageView1 setImage:[UIImage imageNamed:@"heartAlive"]];
  UIImageView *imageView2=(UIImageView *)[self.view viewWithTag:3];
  [imageView2 setImage:[UIImage imageNamed:@"heartAlive"]];
  currentLevel=0;
  
  numberOfLives=3;//resets number of lives
}

/*
 starts timer
 */
-(void)startTimer{
  timer1=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES ];
  
}

/*
 counts down
 */
-(void)countDown
{
  if(_timer==30 && firstTimePlay==true)//first time
  {
    _timer-=1;
    [self info];
  }
  else
    _timer-=1;
  
}

@end
