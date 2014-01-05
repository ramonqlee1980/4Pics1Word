//
//  DailyChallengeViewController.m
//  4Imgs1Word
//
//  Created by Ramonqlee on 12/11/13.
//  Copyright (c) 2013 idreems. All rights reserved.
//

#import "ChallengeController.h"
#import "RMGuessWordView.h"
#import "RMQuestionsRequest.h"

#define kBackButtonTag  1000
#define kCoinsButtonTag 1001
#define kGuesswordContainerTag 1002
#define kCoinsLabelTag  1003
#define kLevelLabelTag  1004

@interface ChallengeController ()<GuessWordViewDelegate>
{
    UILabel* coinsLabel;
}
- (IBAction)backHome:(id)sender; // back to home
@end

@implementation ChallengeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    UIView* backButton = [self.view viewWithTag:kBackButtonTag];
    if (backButton && [backButton isKindOfClass:[UIButton class]]) {
        [((UIButton*)backButton)addTarget:self action:@selector(backHome:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    coinsLabel = (UILabel*)[self.view viewWithTag:kCoinsLabelTag];
    [self setCoinsLabelText:[NSString stringWithFormat:@"%d",[Utils currentCoins]]];
    
    //load views
    if (![self guesswordView]) {
        UIView* guesswordContainer = [self.view viewWithTag:kGuesswordContainerTag];
        if (guesswordContainer ) {
            CGRect frame = guesswordContainer.frame;
            frame.origin = CGPointZero;
            UIView* guesswordView = [[RMGuessWordView alloc]initWithFrame:frame];
            [guesswordContainer addSubview:guesswordView];
        }
    }
}

#pragma 更新显示的关数
-(void)setLevelView:(NSUInteger)level
{
    UIView* view = [self guesswordView];
    NSUInteger levelCount = level;
    if (view) {
        RMGuessWordView* guessView = ((RMGuessWordView*)view);
        levelCount = guessView.dataset.count;
    }
    UILabel* label = (UILabel*)[self.view viewWithTag:kLevelLabelTag];
    if (label) {
        [label setText:[NSString stringWithFormat:@"%d/%d",level,levelCount]];
    }
}

-(void)invalidate:(NSArray*)array
{
    //TODO::暂时测试用
    UIView* view = [self guesswordView];
    if (view) {
        RMGuessWordView* guessView = ((RMGuessWordView*)view);
        guessView.delegate = self;
        [guessView updateDataset:array];
        guessView.controller = self;
        guessView.coins = [Utils currentCoins];
        
        [self setLevelView:1];//1代表第一关
    }
}

-(UIView*)guesswordView
{
    UIView* guesswordContainer = [self.view viewWithTag:kGuesswordContainerTag];
    if (guesswordContainer) {
        NSArray* views = [guesswordContainer subviews];
        if (views && views.count) {
            return [views objectAtIndex:0];
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backHome:(id)sender
{
    [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma set methods
-(void)setCoinsLabelText:(NSString*)value
{
    if (coinsLabel) {
        [((UILabel*)coinsLabel) setText:value];
    }
}

#pragma mark GuessWordViewDelegate
-(void)willEnterNextGuess:(NSUInteger)currentCoins onCurrentStage:(NSUInteger)pos
{
    //更新本地数据和ui显示数据
    [Utils setCurrentCoins:currentCoins];
    [self setCoinsLabelText:[NSString stringWithFormat:@"%d",currentCoins]];
    
    if (self.delegate) {
        [self.delegate willEnterNextGuess:currentCoins onCurrentStage:pos];
    }
    
    [self setLevelView:++pos];
}

-(void)coinsChanged:(NSUInteger)currentCoins
{
    //更新本地数据和ui显示数据
    [Utils setCurrentCoins:currentCoins];
    [self setCoinsLabelText:[NSString stringWithFormat:@"%d",currentCoins]];
    
    if(self.delegate)
    {
        [self.delegate coinsChanged:currentCoins];
    }
}

-(void)gameover
{
    //TODO今日挑战结束，明日再来
    [self backHome:nil];
    
    if (self.delegate) {
        [self.delegate gameover];
    }
    
    //TODO:: 每日挑战相关，待移走
//    [Utils setDailyChallengeOff];
}
@end
