//
//  InformationScene.m
//  Not Mario
//
//  By Aidan McCarthy
//  Based on The Ray Wenderlick tutorial
//

#import "InformationScene.h"
#import "GameLevelScene.h"

@implementation InformationScene

-initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        
        NSString * message;
        
        NSString * message2;
        message = @"Reach the end before the timer runs out";
        message2=@"Collect the boxes to get more time!!";

        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        SKLabelNode *label2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 20;
        
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];

        label2.fontSize = 20;
        label2.fontColor = [SKColor blackColor];
        label2.position=CGPointMake(self.size.width/2, self.size.height/(1.5));
        label2.text=message2;
        [self addChild:label2];
        
        
        [self runAction:[SKAction sequence:@[[SKAction waitForDuration:3.0],
        [SKAction runBlock:^{
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene * myScene = [[GameLevelScene alloc] initWithSize:self.size];
            [self.view presentScene:myScene transition: reveal];}]]]];}
        return self;
}

@end
