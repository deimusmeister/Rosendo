//
//  GameScene.m
//  Rosendoator
//
//  Created by Rainer Häuslinger on 22/12/15.
//  Copyright (c) 2015 Levon Poghosyan. All rights reserved.
//

#import "GameScene.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation GameScene
{
    SKLabelNode*    mTimerLabel;
    NSTimer*        mTimer;
    BOOL            mRunning;
    
    // Background
    SKSpriteNode*   mField;
    
    // Rosendo
    SKSpriteNode*   mRosendo;
    NSArray*        mRosendoWalkingFrames;
    
    // Player
    SKSpriteNode*   mPlayer;
    NSArray*        mPlayerWalkingFrames;
    
    // Dialogues
    UIView*         mLooserDialogue;
    UIView*         mWinnerDialogue;
    UIView*         mStartupDialogue;
    
    UIButton*       pbutton;
    
    // UI
    UILabel*        startlabel;
    SKLabelNode*    powerLabel;
    
    NSTimer*        mStartTimer;
    NSInteger       mStartupCounter;
    NSDate*         mStartDate;
    NSTimer*        mRosendoTimer;
    
    NSInteger       mLevel;
    UIImage*        mScreeshot;
}

-(void)didMoveToView:(SKView *)view
{
    // Initialize dialuges
    [self startCounter];
    [self youLooser];
    [self youWinner];
    mLooserDialogue.hidden = YES;
    mWinnerDialogue.hidden = YES;
    
    // Background color
    self.backgroundColor = [UIColor whiteColor];
    
    // Add spotwatch
    mTimerLabel = [SKLabelNode labelNodeWithFontNamed:@"Verdana"];
    mTimerLabel.text = @"00.00.00.000";
    mTimerLabel.fontColor = [UIColor blackColor];
    mTimerLabel.fontSize = 35;
    mTimerLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 146);
    [self addChild:mTimerLabel];
    mRunning = FALSE;
    
    // Add power label
    powerLabel = [SKLabelNode labelNodeWithFontNamed:@"Verdana"];
    powerLabel.text = @"POWER !";
    powerLabel.fontColor = [UIColor blackColor];
    powerLabel.fontSize = 35;
    powerLabel.position = CGPointMake(100, self.frame.size.height - 146);
    [self addChild:powerLabel];
    
    // Ice field
    mField = [SKSpriteNode spriteNodeWithImageNamed:@"Field"];
    mField.position = CGPointMake(CGRectGetMidX(self.frame),
                                  CGRectGetMidY(self.frame));
    CGFloat scaleFactor = self.frame.size.width / mField.size.width;
    mField.xScale = scaleFactor;
    mField.yScale = scaleFactor;
    mField.zPosition = -1;
    [self addChild:mField];
    
    // Rosendoator
    [self initRosendo];
    
    // Player
    [self initPlayer];
}

-(void)initRosendo
{
    NSMutableArray *walkFrames = [NSMutableArray array];
    SKTextureAtlas *RosendoAnimatedAtlas = [SKTextureAtlas atlasNamed:@"player"];
    NSUInteger numImages = RosendoAnimatedAtlas.textureNames.count;
    for (NSUInteger i= 1; i <= numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"frame-%d", (int)i];
        SKTexture *temp = [RosendoAnimatedAtlas textureNamed:textureName];
        [walkFrames addObject:temp];
    }
    mRosendoWalkingFrames = walkFrames;
    
    SKTexture *temp = mRosendoWalkingFrames[0];
    mRosendo = [SKSpriteNode spriteNodeWithTexture:temp];
    mRosendo.xScale = 1.25f;
    mRosendo.yScale = 1.25f;
    mRosendo.position = CGPointMake(120, 500);
    [self addChild:mRosendo];
}

-(void)walkingRosendo
{
    //This is our general runAction method to make our bear walk.
    [mRosendo runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:mRosendoWalkingFrames
                                       timePerFrame:0.05f
                                             resize:NO
                                            restore:YES]] withKey:@"walkingRosendo"];
    return;
}

-(void)initPlayer
{
    // Player
    NSMutableArray *pwalkFrames = [NSMutableArray array];
    SKTextureAtlas *palyerAnimatedAtlas = [SKTextureAtlas atlasNamed:@"rosendo"];
    NSUInteger pnumImages = palyerAnimatedAtlas.textureNames.count;
    for (NSUInteger i= 1; i <= pnumImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"frame-%d", (int)i];
        SKTexture *temp = [palyerAnimatedAtlas textureNamed:textureName];
        [pwalkFrames addObject:temp];
    }
    mPlayerWalkingFrames = pwalkFrames;
    
    SKTexture *ptemp = mPlayerWalkingFrames[0];
    mPlayer = [SKSpriteNode spriteNodeWithTexture:ptemp];
    mPlayer.xScale = 1.25f;
    mPlayer.yScale = 1.25f;
    mPlayer.position = CGPointMake(120, 275);
    [self addChild:mPlayer];
}

-(void)walkingPlayer
{
    //This is our general runAction method to make our bear walk.
    [mPlayer runAction:[SKAction repeatActionForever:
                        [SKAction animateWithTextures:mPlayerWalkingFrames
                                         timePerFrame:0.05f
                                               resize:NO
                                              restore:YES]] withKey:@"walkingPlayer"];
    return;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (mRunning)
    {
        CGPoint newPostion = CGPointMake(mPlayer.position.x + 30, mPlayer.position.y);
        [mPlayer runAction:[SKAction moveTo:newPostion duration:0.25]];
        
        powerLabel.fontColor = [UIColor redColor];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    powerLabel.fontColor = [UIColor blackColor];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(void)play:(NSInteger)level {
    // Moved to starting position
    [mRosendo   runAction:[SKAction moveTo:CGPointMake(120, 500) duration:0.0]];
    [mPlayer runAction:[SKAction moveTo:CGPointMake(120, 275) duration:0.0]];
    
    mLevel = level;
    mTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                              target:self
                                            selector:@selector(timerCalled)
                                            userInfo:nil
                                             repeats:YES];
    mRunning = YES;
    mStartDate = [NSDate date];
    
    mRosendoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(RosendoPushed)
                                                userInfo:nil
                                                 repeats:YES];
    [self walkingRosendo];
    [self walkingPlayer];
}

-(void)RosendoPushed
{
    NSTimeInterval timeInterval = 1.f / mLevel;
    
    //[mRosendo removeAllActions];
    if ([mRosendo actionForKey:@"OPushing"] == nil)
    {
        CGPoint newPostion = CGPointMake(mRosendo.position.x + 30, mRosendo.position.y);
        SKAction *action = [SKAction moveTo:newPostion duration:timeInterval];
        [mRosendo runAction:action withKey:@"OPushing"];
    }
}

-(void)timerCalled
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:mStartDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    mTimerLabel.text = [NSString stringWithFormat:@"Lvl %ld - %@", mLevel, timeString ];
    
    // Check if someone has won
    CGFloat oPosition = mRosendo.position.x;
    CGFloat pPosition = mPlayer.position.x;
    BOOL playerWon = FALSE;
    if (pPosition >= oPosition && pPosition > 700)
    {
        playerWon = TRUE;
        mRunning = FALSE;
    }
    else if (oPosition >= pPosition && oPosition > 700)
    {
        playerWon = FALSE;
        mRunning = FALSE;
    }
    
    if (mRunning == FALSE)
    {
        [mTimer invalidate];
        [mRosendoTimer invalidate];
        [mRosendo removeAllActions];
        [mPlayer removeAllActions];
        
        // If the user has won proceed to next lvl
        if (playerWon == TRUE)
        {
            // Make a screenshot
            [self takeScreenshot];
            
            // Show the winner's dialuge
            mWinnerDialogue.hidden = NO;
            
            // YOOHOO sound
            [self playYOOHOO];
        }
        else
        {
            // Show looser's dialogue
            mLooserDialogue.hidden = NO;
            
            // HAHA sound
            [self playHAHA];
            
            if (mLevel > 1)
                pbutton.hidden = NO;
            else
                pbutton.hidden = YES;
        }
    }
}

-(void)playHAHA
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"haha" ofType:@"m4a"];
                       SystemSoundID soundID;
                       AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
                       AudioServicesPlaySystemSound (soundID);
                   });
}

-(void)playYOOHOO
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"yoohoo" ofType:@"m4a"];
                       SystemSoundID soundID;
                       AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
                       AudioServicesPlaySystemSound (soundID);
                   });
}

-(void)startCounter
{
    mStartupDialogue = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 150,25,300,300)];
    mStartupDialogue.layer.borderColor = [UIColor blackColor].CGColor;
    mStartupDialogue.layer.cornerRadius = 10.0f;
    mStartupDialogue.layer.borderWidth = 3.0f;
    mStartupDialogue.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mStartupDialogue];
    
    startlabel = [[UILabel alloc] init];
    [startlabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    startlabel.text = @"The Match\nStarts in\n 5 seconds\nKeep tapping !";
    startlabel.numberOfLines = 4;
    startlabel.textAlignment = NSTextAlignmentCenter;
    startlabel.font = [UIFont boldSystemFontOfSize:35];
    startlabel.tintColor = [UIColor blackColor];
    [mStartupDialogue addSubview:startlabel];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(startlabel);
    
    NSArray *lhorizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[startlabel]-20-|" options:0 metrics:nil views:views];
    NSArray *verticalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[startlabel]-20-|" options:0 metrics:nil views:views];
    
    [mStartupDialogue addConstraints:verticalConstraints];
    [mStartupDialogue addConstraints:lhorizontalConstraints];
    
    mStartTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                   target:self
                                                 selector:@selector(startupTimer)
                                                 userInfo:nil
                                                  repeats:YES];
    mStartupCounter = 5;
}

-(void)startupTimer
{
    mStartupCounter = mStartupCounter - 1;
    startlabel.text = [NSString stringWithFormat:@"The Match\nStarts in\n %ld seconds\nKeep tapping !", mStartupCounter];
    if (mStartupCounter == 0)
    {
        [mStartTimer invalidate];
        mStartupDialogue.hidden = YES;
        // Start with level 1
        [self play:1];
    }
}

-(void)youLooser
{
    mLooserDialogue = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 150,25,300,300)];
    mLooserDialogue.layer.borderColor = [UIColor blackColor].CGColor;
    mLooserDialogue.layer.cornerRadius = 10.0f;
    mLooserDialogue.layer.borderWidth = 3.0f;
    mLooserDialogue.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mLooserDialogue];
    
    UILabel* label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    label.text = @"HAHA ! Looser !";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:35];
    label.tintColor = [UIColor blackColor];
    [mLooserDialogue addSubview:label];
    
    UIButton* button =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setTitle:@"Replay!" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont: [button.titleLabel.font fontWithSize:30]];
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 2.f;
    button.layer.cornerRadius = 20.f;
    [button addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
    [mLooserDialogue addSubview:button];
    
    pbutton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pbutton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [pbutton setTitle:@"Previous lvl ;-(" forState:UIControlStateNormal];
    [pbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pbutton.titleLabel setFont: [button.titleLabel.font fontWithSize:30]];
    pbutton.layer.borderColor = [UIColor blackColor].CGColor;
    pbutton.layer.borderWidth = 2.f;
    pbutton.layer.cornerRadius = 20.f;
    [pbutton addTarget:self action:@selector(previousPlay) forControlEvents:UIControlEventTouchUpInside];
    [mLooserDialogue addSubview:pbutton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(label, pbutton, button);
    
    NSArray *lhorizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[label]-20-|" options:0 metrics:nil views:views];
    NSArray *bhorizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[button]-20-|" options:0 metrics:nil views:views];
    NSArray *phorizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[pbutton]-20-|" options:0 metrics:nil views:views];
    NSArray *verticalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[label]-20-[pbutton]-20-[button]-20-|" options:0 metrics:nil views:views];
    
    [mLooserDialogue addConstraints:verticalConstraints];
    [mLooserDialogue addConstraints:bhorizontalConstraints];
    [mLooserDialogue addConstraints:phorizontalConstraints];
    [mLooserDialogue addConstraints:lhorizontalConstraints];
}

-(void)youWinner
{
    mWinnerDialogue = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 150,25,300,300)];
    mWinnerDialogue.layer.borderColor = [UIColor blackColor].CGColor;
    mWinnerDialogue.layer.cornerRadius = 10.0f;
    mWinnerDialogue.layer.borderWidth = 3.0f;
    mWinnerDialogue.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mWinnerDialogue];
    
    UILabel* label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    label.text = @"You Won !";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:35];
    label.tintColor = [UIColor blackColor];
    [mWinnerDialogue addSubview:label];
    
    UIButton* nbutton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [nbutton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [nbutton setTitle:@"Next lvl!" forState:UIControlStateNormal];
    [nbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nbutton.titleLabel setFont: [nbutton.titleLabel.font fontWithSize:30]];
    nbutton.layer.borderColor = [UIColor blackColor].CGColor;
    nbutton.layer.borderWidth = 2.f;
    nbutton.layer.cornerRadius = 20.f;
    [nbutton addTarget:self action:@selector(nextPlay) forControlEvents:UIControlEventTouchUpInside];
    [mWinnerDialogue addSubview:nbutton];
    
    UIButton* rbutton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rbutton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rbutton setTitle:@"Replay" forState:UIControlStateNormal];
    [rbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rbutton.titleLabel setFont: [rbutton.titleLabel.font fontWithSize:30]];
    rbutton.layer.borderColor = [UIColor blackColor].CGColor;
    rbutton.layer.borderWidth = 2.f;
    rbutton.layer.cornerRadius = 20.f;
    [rbutton addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
    [mWinnerDialogue addSubview:rbutton];
    
    UIButton* sbutton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sbutton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sbutton setTitle:@"Share" forState:UIControlStateNormal];
    [sbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sbutton.titleLabel setFont: [rbutton.titleLabel.font fontWithSize:30]];
    sbutton.layer.borderColor = [UIColor blackColor].CGColor;
    sbutton.layer.borderWidth = 2.f;
    sbutton.layer.cornerRadius = 20.f;
    [sbutton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [mWinnerDialogue addSubview:sbutton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(label, nbutton, rbutton, sbutton);
    
    NSArray *lhorizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[label]-20-|" options:0 metrics:nil views:views];
    NSArray *bhorizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[nbutton]-20-|" options:0 metrics:nil views:views];
    NSArray *rhorizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[rbutton]-20-|" options:0 metrics:nil views:views];
    NSArray *shorizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[sbutton]-20-|" options:0 metrics:nil views:views];
    NSArray *verticalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[label]-20-[nbutton]-20-[rbutton]-20-[sbutton]-20-|" options:0 metrics:nil views:views];
    
    [mWinnerDialogue addConstraints:verticalConstraints];
    [mWinnerDialogue addConstraints:bhorizontalConstraints];
    [mWinnerDialogue addConstraints:rhorizontalConstraints];
    [mWinnerDialogue addConstraints:shorizontalConstraints];
    [mWinnerDialogue addConstraints:lhorizontalConstraints];
}

-(void)share
{
    // Facebook share
    NSString* text= [NSString stringWithFormat:@"I won Rosendoator in %ld lvl", mLevel];
    //NSURL *myWebsite = [NSURL URLWithString:@"http://www.website.com/"];
    //  UIImage * myImage =[UIImage imageNamed:@"myImage.png"];
    NSArray* sharedObjects=@[text, mScreeshot];
    UIActivityViewController * activityViewController=[[UIActivityViewController alloc]initWithActivityItems:sharedObjects applicationActivities:nil];
    
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self.view.window.rootViewController presentViewController:activityViewController animated:YES completion:nil];
}

-(void)takeScreenshot
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 1);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    mScreeshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)replay
{
    // Hide the dialogues
    mLooserDialogue.hidden = YES;
    mWinnerDialogue.hidden = YES;
    // Replay with the current level
    [self play:mLevel];
}

-(void)nextPlay
{
    // Hide the dilogues
    mWinnerDialogue.hidden = YES;
    mLooserDialogue.hidden = YES;
    
    // Increase the difficulty level
    [self play:mLevel + 1];
}

-(void)previousPlay
{
    // Hide the dilogues
    mWinnerDialogue.hidden = YES;
    mLooserDialogue.hidden = YES;
    
    if (mLevel > 1)
    {
        // Decrease the difficulty level
        mLevel = mLevel - 1;
    }
    [self play:mLevel];
}

@end
