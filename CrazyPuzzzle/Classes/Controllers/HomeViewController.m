//
//  CPHomeViewController.m
//  CrazyPuzzzle
//
//  Created by mac on 13-8-11.
//  Copyright (c) 2013年 xiaoran. All rights reserved.
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageAdditions.h"
#import "ChallengeController.h"
#import "RMQuestionsRequest.h"
#import "ClassifiedController.h"

@interface HomeViewController ()
    {
        ChallengeController *dailyChallengeController;
        ChallengeController* freeGuessChallengeController;
    }
- (void)musicPlay;
- (void)musicStop;
    
- (void) startAnimation;
    
    @end


static AVAudioPlayer *_audioPlayer = nil;

@implementation HomeViewController
    
    
    
    //- (id)initWithCoder:(NSCoder *)aDecoder
    //{
    //    self = [super initWithCoder:aDecoder];
    //    if (self) {
    //        //
    //        _audioStatus = YES;
    //    }
    //
    //    return self;
    //
    //}
    //
    
- (void)viewDidLoad
    {
        [super viewDidLoad];
        // Do any additional setup after loading the view
        if(![[NSUserDefaults standardUserDefaults] objectForKey:CurrentAudioStatusKey]){
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CurrentAudioStatusKey];
        }
        
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:CurrentAudioStatusKey] boolValue]) {
            [self musicPlay];
        }
        
        [self internationalize];
        [self startAnimation];
        [self monitorDataLoading];
    }
    
    
- (void)viewDidAppear:(BOOL)animated
    {
        [super viewDidAppear:animated];
        
        //daily challenged??
        _dailyChallengeBtn.enabled =[Utils dailyChallengeOn];
        
        //截屏，留作动画用
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        self.homeScreenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
- (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }
    
#pragma mark private
    
- (void)musicPlay
    {
        _musicOnBtn.hidden = YES;
        _musicOffBtn.hidden = NO;
        
        
        if (!_audioPlayer) {
            
            NSString *mfp = [[NSBundle mainBundle] pathForResource:kBackgroundMusic ofType:kMp3Suffix];
            NSURL *url = [[NSURL alloc] initFileURLWithPath:mfp];
            _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
            
        }
        
        if (![_audioPlayer isPlaying]) {
            [_audioPlayer prepareToPlay];
            [_audioPlayer setVolume:0.75];
            _audioPlayer.numberOfLoops = -1;
            
            [_audioPlayer play];
        }
        
        
    }
    
- (void)musicStop
    {
        _musicOnBtn.hidden = NO;
        _musicOffBtn.hidden = YES;
        
        
        [_audioPlayer stop];
    }
    
#pragma mark action
    
- (IBAction)startGame:(id)sender
    {
        [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
        
        freeGuessChallengeController = [[ChallengeController alloc]initWithNibName:@"ChallengeController" bundle:nil];
        [self presentModalViewController:freeGuessChallengeController animated:YES];
        
        //请求网络数据
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(freeGuessResponseReceived:) name:QUESTION_RESPONSE_NOTIFICATION object:nil];
        [[RMQuestionsRequest sharedInstance]startAsynchronous];
        
    }
- (IBAction)EnterGradeView:(id)sender
    {
        [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
        
        //TODO::缺少首次进入的动画
        ClassifiedController *vc = [[ClassifiedController alloc]initWithNibName:@"ClassifiedController" bundle:nil];
        [self presentModalViewController:vc animated:YES];
    }
-(IBAction)startDailyChallenge:(id)sender
    {
        [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
        
        //TODO::缺少首次进入的动画
        dailyChallengeController = [[ChallengeController alloc]initWithNibName:@"ChallengeController" bundle:nil];
        [self presentModalViewController:dailyChallengeController animated:YES];
        
        //请求网络数据
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dailyResponseReceived:) name:QUESTION_RESPONSE_NOTIFICATION object:nil];
        [[RMQuestionsRequest sharedInstance]startAsynchronous];
    }
#pragma mark 请求网络数据返回后的处理
-(void)dailyResponseReceived:(NSNotification*)notification
    {
        //从服务器端请求数据
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        NSMutableArray * array = [[NSMutableArray alloc]init];
        if([notification.object isKindOfClass:[NSArray class]])
        {
            //TODO::随机一项作为每日挑战的题目，后续待改进
            NSArray* obj = (NSArray*)notification.object;
            [array addObject: [obj objectAtIndex:rand()%[obj count]]];
        }
        [dailyChallengeController invalidate:array];
    }
-(void)freeGuessResponseReceived:(NSNotification*)notification
{
    //从服务器端请求数据
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if([notification.object isKindOfClass:[NSArray class]])
    {
        [freeGuessChallengeController invalidate:(NSArray*)notification.object];
    }
}

- (IBAction)openMusic:(id)sender
    {
        [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
        
        [self musicPlay];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CurrentAudioStatusKey];
    }
    
- (IBAction)closeMusic:(id)sender;
    {
        [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
        
        [self musicStop];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CurrentAudioStatusKey];
    }
    
- (IBAction)feedBack:(id)sender
    {
        [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
        
        [UMFeedback showFeedback:self withAppkey:CP_UMeng_App_Key];
        
    }
    
    
#pragma mark anmimation( timer )
    
- (void) startAnimation
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
        animation.duration = 3;
        animation.repeatCount = 99999;
        
        [_fengChe.layer addAnimation:animation forKey:@"animation1"];
        
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(shopCarFly) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        
    }
    
    
- (void)shopCarFly
    {
        CAKeyframeAnimation *animation2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation2.duration=5;
        animation2.repeatCount = 3;
        animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        NSMutableArray *values = [NSMutableArray array];
        //[values addObject:[NSNumber numberWithFloat:Degrees_To_Radians(0)]];
        [values addObject:[NSNumber numberWithFloat:Degrees_To_Radians(45)]];
        [values addObject:[NSNumber numberWithFloat:Degrees_To_Radians(0)]];
        [values addObject:[NSNumber numberWithFloat:Degrees_To_Radians(-45)]];
        [values addObject:[NSNumber numberWithFloat:Degrees_To_Radians(0)]];
        [values addObject:[NSNumber numberWithFloat:Degrees_To_Radians(45)]];
        animation2.values = values;
        
        
        CGPoint oldAnchorPoint = _shopCarBtn.layer.anchorPoint;
        [_shopCarBtn.layer setAnchorPoint:CGPointMake(0.5, 0)];
        [_shopCarBtn.layer setPosition:CGPointMake(_shopCarBtn.layer.position.x + _shopCarBtn.layer.bounds.size.width * (_shopCarBtn.layer.anchorPoint.x - oldAnchorPoint.x), _shopCarBtn.layer.position.y + _shopCarBtn.layer.bounds.size.height * (_shopCarBtn.layer.anchorPoint.y - oldAnchorPoint.y))];
        
        [_shopCarBtn.layer addAnimation:animation2 forKey:@"animation"];
        
    }
    
#pragma mark internationalize
-(void)internationalize
    {
        if (_startGameBtn) {
            [_startGameBtn setTitle:NSLocalizedString(@"Start_Game", "") forState:UIControlStateNormal];
        }
        if (_dailyChallengeBtn) {
            [_dailyChallengeBtn setTitle:NSLocalizedString(@"Start_Game", "") forState:UIControlStateNormal];
        }
        if (_dailyChallengeLabel) {
            [_dailyChallengeLabel setText:NSLocalizedString(@"Daily_Challenge", "")];
        }
    }
    
#pragma mark dataloading
-(void) monitorDataLoading
    {
        if(![RMQuestionsRequest sharedInstance].questionsArray)
        {
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(responseReceived:) name:QUESTION_RESPONSE_NOTIFICATION object:nil];
            
            if (_startGameBtn) {
                _startGameBtn.userInteractionEnabled = NO;
                [_startGameBtn setTitle:NSLocalizedString(@"Load_Game", "") forState:UIControlStateNormal];
            }
        }
        
        //请求数据
        [[RMQuestionsRequest sharedInstance]startAsynchronous];
    }
#pragma mark 请求网络数据返回后的处理
-(void)responseReceived:(NSNotification*)notification
    {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:QUESTION_RESPONSE_NOTIFICATION object:nil];
        
        if([notification.object isKindOfClass:[NSArray class]])
        {
            if (_startGameBtn) {
                _startGameBtn.userInteractionEnabled = YES;
                [_startGameBtn setTitle:NSLocalizedString(@"Start_Game", "") forState:UIControlStateNormal];
            }
        }
        else
        {
            if (_startGameBtn) {
                [_startGameBtn setTitle:NSLocalizedString(@"Load_Fail", "") forState:UIControlStateNormal];
            }
        }
    }
    @end
