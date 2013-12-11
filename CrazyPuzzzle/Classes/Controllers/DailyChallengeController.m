//
//  DailyChallengeViewController.m
//  4Imgs1Word
//
//  Created by Ramonqlee on 12/11/13.
//  Copyright (c) 2013 idreems. All rights reserved.
//

#import "DailyChallengeController.h"
#import "MainGuessViewController.h"
#import "RMGuessWordView.h"
#import "RMQuestionsRequest.h"

#define kBackButtonTag 1000
#define kCoinsLabelTag 1001
#define kGuesswordContainerTag 1002

@interface DailyChallengeController ()

@end

@implementation DailyChallengeController

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
    
    //请求网络数据
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(responseReceived:) name:QUESTION_RESPONSE_NOTIFICATION object:nil];
    [[RMQuestionsRequest sharedInstance]startAsynchronous];
    
}
#pragma mark 请求网络数据返回后的处理
-(void)responseReceived:(NSNotification*)notification
{
    //从服务器端请求数据
    NSMutableArray * array = [[NSMutableArray alloc]init];
    if([notification.object isKindOfClass:[NSArray class]])
    {
        [array addObjectsFromArray:(NSArray*)notification.object];
    }
    
    //TODO::暂时测试用
    UIView* view = [self guesswordView];
    if (view) {
        RMGuessWordView* guessView = ((RMGuessWordView*)view);
        guessView.delegate = self;
        guessView.dataset = array;
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
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    MainGuessViewController *homeVC = [sb instantiateViewControllerWithIdentifier:@"CPHomeViewController"];
    
    [self presentViewController:homeVC animated:YES
                     completion:nil];
}

#pragma mark GuessWordViewDelegate
-(void)willEnterNextGuess:(NSUInteger)currentCoins onCurrentStage:(NSUInteger)pos
{
    UIView* coinsLabel = [self.view viewWithTag:kCoinsLabelTag];
    if (coinsLabel && [coinsLabel isKindOfClass:[UILabel class]]) {
        [((UILabel*)coinsLabel) setText:[NSString stringWithFormat:@"%d",currentCoins]];
    }
}
-(void)coinsChanged:(NSUInteger)currentCoins
{
    UIView* coinsLabel = [self.view viewWithTag:kCoinsLabelTag];
    if (coinsLabel && [coinsLabel isKindOfClass:[UILabel class]]) {
        [((UILabel*)coinsLabel) setText:[NSString stringWithFormat:@"%d",currentCoins]];
    }
}
-(void)gameover
{
    [self backHome:nil];
}

@end