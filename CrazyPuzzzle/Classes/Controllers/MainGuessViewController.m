//
//  CPMainViewController.m
//  CrazyPuzzzle
//
//  Created by mac on 13-8-11.
//  Copyright (c) 2013年 xiaoran. All rights reserved.
//

#import "MainGuessViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageAdditions.h"
#import "ASIHTTPRequest.h"
#include "UIImageView+WebCache.h"
#import "Utils.h"
#import "RMQuestionsRequest.h"
#import "UMSocial.h"
#import "Flurry.h"
#import "Utils.h"

#define kQuestionImageUrlFormatter @"http://checknewversion.duapp.com/image/image-search.php?q=%@"
#define kQuestionImageColumnCount 2
#define kQuestionImageViewCount 4
#define kRetryMaxCount 3

#define kAnswerTextFontSize 20

#define CP_Question_Key @"question"
#define CP_Explain_Key @"explain"
#define CP_OriginOfIdioms @"originOfIdioms"

#define CP_Words_Container_Width 300
#define CP_Words_Container_Margin 5
#define CP_Words_Container_Columns 8
#define CP_Words_Container_Rows 2
#define CP_Word_Cell_Margin 4
#define CP_Word_Cell_Size (CP_Words_Container_Width-CP_Words_Container_Margin*2-CP_Word_Cell_Margin*(CP_Words_Container_Columns-1))/CP_Words_Container_Columns
#define CP_Scale_Factor 1.2
#define CP_Words_Container_Height  CP_Words_Container_Margin*2 + CP_Word_Cell_Margin*(CP_Words_Container_Rows-1)+CP_Word_Cell_Size*CP_Words_Container_Rows

#define CP_Answer_Button_Tag_Offset 1000
#define CP_Word_Button_Tag_Offset 10000

#define CP_Up_Imageview_Tag 222
#define CP_Down_Imageview_Tag 333


#define degree(x) x * M_PI / 180


#define CP_ShareView_Animation_Duration 0.6

//string key
#define ThumbnailStringKey @"tbUrl"

#define ResponseStatusStringKey @"responseStatus"
#define ResponseDataStringKey @"responseData"
#define ResultsStringKey @"results"


//答案区的背景图
#define kAnswerViewBackgroundNormalImage @"answer.png"
#define kAnswerViewBackgroundHighlightedImage @"answer_press.png"

//待选字符区的背景
#define kCandidateViewBackgroundNormalImage @"word.png"
#define kCandidateViewBackgroundHighlightedImage @"word_press.png"

#define kGuess_MsgBox_Bg @"guess_msgbox_bg"

//需要随机加入26个字母中的几个字母
static NSString *_globalWordsString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";

@interface MainGuessViewController ()
{
    NSMutableArray* questionImageResultArray;//图片描述信息数组
    CGRect questionImageRect;
    NSInteger retryCount;
}
- (void)showPrompView;
- (void)hidePrompView;
//- (void)hideShareView;
- (void)showShareView;

- (UIImage *)getSharedImage;

@end

@implementation MainGuessViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadLocalSettings];
    //请求网络数据
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(responseReceived:) name:QUESTION_RESPONSE_NOTIFICATION object:nil];
    [[RMQuestionsRequest sharedInstance]startAsynchronous];
    
    UIEdgeInsets edge = UIEdgeInsetsMake(48, 20, 30, 20);
    [self initPromptView:edge];
    [self initShareView:edge];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//进入下一关
- (IBAction)next:(id)sender
{
    [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
    
    [Utils setCurrentLevel:++_currentLevel];
    if (_currentLevel > [self.dataSource count]) {
        SLog(@"这已经是最后一关！");
        [self back:nil];//返回主界面了
        return;
    }
    
    [self startNewLevel];
}

//进行新一关的准备工作
-(void)startNewLevel
{
    _isWrong = NO;
    _answerBtnSelectWhenWrong = NO;
    _firstPrompt = YES;
    
    self.maps = [NSMutableDictionary dictionary];
    [self setPromptCostLabel];
    
    if (_currentLevel >= self.dataSource.count) {
        _currentLevel = CP_Initial_Level;
    }
    _currentAnswer = self.dataSource[_currentLevel-1];
    NSLog(@"currentAnswer: %@",_currentAnswer);
    assert(_currentAnswer != nil);
    _currentAnswer = [_currentAnswer uppercaseString];
    
    NSArray* questionsArray = [RMQuestionsRequest sharedInstance].questionsArray;
    int totalLevel = questionsArray?questionsArray.count:0;
    _levelLable.text = [NSString stringWithFormat:@"%d/%d",_currentLevel,totalLevel];
    _myGoldLable.text = [NSString stringWithFormat:@"%d",[Utils currentCoins]];
    
    //replace with four images
    questionImageRect = _mainQustionPicIV.frame;
    [self grabImagesInBackground:_currentAnswer];
    
    CGRect rc = CGRectMake(0, _firstBtn.frame.origin.y, APP_SCREEN_WIDTH, _firstBtn.frame.size.height);
    [self setupAnswerViews:rc];
    [self setupCandidateContainerView];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_currentLevel],[NSNumber numberWithInt:totalLevel],kCoinsAmount, [NSNumber numberWithInt:[Utils currentCoins]],nil];
    [Flurry logEvent:kFlurryLevel withParameters:dict];
}


#pragma mark 首次进入的动画
- (void)startGame
{
    NSArray *twoParts = [UIImage splitImageIntoTwoParts:self.homeScreenShot orientations:0];
    
    UIImageView *upIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_CONTENT_HEIGHT/2)];
    //upIV.backgroundColor = [UIColor yellowColor];
    upIV.image = twoParts[0];
    upIV.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    upIV.tag = CP_Up_Imageview_Tag;
    [self.view addSubview:upIV];
    
    UIImageView *downIV = [[UIImageView alloc] initWithFrame:CGRectMake(0,APP_SCREEN_CONTENT_HEIGHT/2 , APP_SCREEN_WIDTH, APP_SCREEN_CONTENT_HEIGHT/2)];
    downIV.image = twoParts[1];
    //downIV.backgroundColor = [UIColor redColor];
    downIV.tag = CP_Down_Imageview_Tag;
    downIV.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:downIV];
    
    [UIView animateWithDuration:0.75 animations:^{
        
        [upIV setFrame:CGRectMake(0,-(APP_SCREEN_CONTENT_HEIGHT/2) , APP_SCREEN_WIDTH, APP_SCREEN_CONTENT_HEIGHT/2)];
        upIV.alpha = 0.0;
        [downIV setFrame:CGRectMake(0, (APP_SCREEN_CONTENT_HEIGHT/2)*2, APP_SCREEN_WIDTH, APP_SCREEN_CONTENT_HEIGHT/2)];
        downIV.alpha = 0.0;
        
        
    } completion:^(BOOL finished){
        
    }];
    
}

#pragma mark 答案区的view布局
-(void)setupAnswerViews:(CGRect)frame
{
    _firstBtn.hidden = YES;
    _sencondBtn.hidden = YES;
    _thirdBtn.hidden = YES;
    _fouthBtn.hidden = YES;
    
    //clear children views first
    if (!_answerContainerView) {
        _answerContainerView = [[UIView alloc]initWithFrame:frame];
        [self.view addSubview:_answerContainerView];
    }
    [Utils removeSubviews:_answerContainerView];
    
    
    
    //将answer居中显示
    CGFloat offset = (frame.size.width-(_currentAnswer.length-1)*(CP_Word_Cell_Size+CP_Words_Container_Margin)-CP_Word_Cell_Size)/2;
    
    for(int  i=0; i< _currentAnswer.length ; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:kAnswerTextFontSize];
        
        [btn setBackgroundImage:[UIImage imageNamed:kAnswerViewBackgroundNormalImage] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:kAnswerViewBackgroundHighlightedImage] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.tag = i+CP_Answer_Button_Tag_Offset;
        [btn addTarget:self action:@selector(answerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat x = i%CP_Words_Container_Columns*(CP_Word_Cell_Size+CP_Word_Cell_Margin) +CP_Words_Container_Margin;
        CGFloat y = (i/CP_Words_Container_Columns)*(CP_Word_Cell_Size+CP_Word_Cell_Margin) + CP_Words_Container_Margin;
        
        [btn setFrame:CGRectMake(x+offset, y, CP_Word_Cell_Size, CP_Word_Cell_Size)];
        [_answerContainerView addSubview:btn];
    }
}


#pragma mark 建立文字面板，把答案混淆在里面 CP_Words_Container_Columns*CP_Words_Container_Rows
- (void)setupCandidateContainerView
{
    [_wordsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 设置混淆文字self.words
    [self setupWordsString];
    
    int count = CP_Words_Container_Columns*CP_Words_Container_Rows;
    
    //prepare the  words(count)
    //remove duplicate alphabet
    for (int j=0; j< _currentAnswer.length; j++){
        [self.wordsString replaceOccurrencesOfString:[_currentAnswer substringWithRange:NSMakeRange(j, 1)] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, self.wordsString.length-1)];
    }
    NSInteger totalWordsCount = [self.wordsString length];
    NSMutableString *prepareWords = [NSMutableString string];
    for (int j=0; j< count - _currentAnswer.length; j++) {
        NSString *aWord = [self.wordsString substringWithRange:NSMakeRange(rand()%totalWordsCount, 1)];
        [prepareWords appendString:aWord];
    }
    [prepareWords appendString:_currentAnswer]; // 这样一共24个汉字
    
    
    NSMutableString *str = [NSMutableString stringWithString:prepareWords];
    NSMutableString *s = [NSMutableString string];
    for(int i=0; i< count ; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setBackgroundImage:[UIImage imageNamed:kCandidateViewBackgroundNormalImage] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:kCandidateViewBackgroundHighlightedImage] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = i+CP_Word_Button_Tag_Offset;
        [btn addTarget:self action:@selector(wordButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        NSRange selectedRange = NSMakeRange(rand()%[str length], 1);
        NSString *aWord = [str substringWithRange:selectedRange];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:kAnswerTextFontSize];
        [btn setTitle:aWord forState:UIControlStateNormal];
        [str replaceCharactersInRange:selectedRange withString:@""];
        
        [s appendString:aWord];
        
        // set btn frame
        CGFloat x = i%CP_Words_Container_Columns*(CP_Word_Cell_Size+CP_Word_Cell_Margin) +CP_Words_Container_Margin;
        CGFloat y = (i/CP_Words_Container_Columns)*(CP_Word_Cell_Size+CP_Word_Cell_Margin) + CP_Words_Container_Margin;
        
        [btn setFrame:CGRectMake(-CP_Word_Cell_Size, y, CP_Word_Cell_Size, CP_Word_Cell_Size)];
        [_wordsContainerView addSubview:btn];
        [_wordsContainerView setFrame:CGRectMake(_wordsContainerView.frame.origin.x, _wordsContainerView.frame.origin.y, _wordsContainerView.frame.size.width, CP_Words_Container_Height)];
        
        [UIView animateWithDuration:1.0 animations:^{
            [btn setFrame:CGRectMake(x, y, CP_Word_Cell_Size*CP_Scale_Factor, CP_Word_Cell_Size*CP_Scale_Factor)];
        } completion:^(BOOL finished){
            
            if (finished) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    [btn setFrame:CGRectMake(x, y, CP_Word_Cell_Size, CP_Word_Cell_Size)];
                    
                } completion:^(BOOL finished){
                    
                }];
            }
        }];
    }
    
    // record this round of wordsStirng
    self.currentPreparedString = s;
}


//初始化可用的字母
- (void)setupWordsString{
    NSMutableString *words = [NSMutableString stringWithString:_globalWordsString];
    [words replaceOccurrencesOfString:@" " withString:@"" options:1 range:NSMakeRange(0, [words length]-1)];//过滤空格
    
    self.wordsString = words;
}



//检查答案是否正确
- (BOOL)checkAnswer
{
    NSMutableString *yourAnswer = [NSMutableString string];
    for (int i=0; i<_currentAnswer.length; i++) {
        UIButton *btn = (UIButton *)[_answerContainerView viewWithTag:(i+CP_Answer_Button_Tag_Offset)];
        assert(btn.titleLabel.text);
        [yourAnswer appendString:btn.titleLabel.text];
    }
    
    
    if([self checkAnswerWithYourAnswer:yourAnswer]){
        [self youAreRight];
    }else{
        [self youAreWrong];
    }
    
    return YES;
}

- (BOOL)checkAnswerWithYourAnswer:(NSString *)yourAnswer{
    return [_currentAnswer isEqualToString:yourAnswer];
}

- (void)youAreWrong
{
    //    SLog(@"you are wrong");
    _isWrong = YES;
    
    for (int i=0; i<_currentAnswer.length; i++) {
        UIButton *btn = (UIButton *)[_answerContainerView viewWithTag:(i+CP_Answer_Button_Tag_Offset)];
        
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z" ];
        animation.duration = 0.25;
        animation.repeatCount = 4;
        
        float rand = (float)random();
        [animation setBeginTime:CACurrentMediaTime() + rand * .0000000001];
        
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:[NSNumber numberWithFloat:degree(-4)]];
        [values addObject:[NSNumber numberWithFloat:degree(4)]];
        [values addObject:[NSNumber numberWithFloat:degree(-4)]];
        
        animation.values=values;
        [btn.layer addAnimation:animation forKey:nil];
        
        
        [UIView animateWithDuration:0.75 animations:^{
            
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
        } completion:^(BOOL finished){
            
        }];
    }
}

- (void)youAreRight
{
    //    SLog(@"you are right");
    
    [self.maps removeAllObjects];
    
    // 奖励玩家
    NSUInteger coins = [Utils currentCoins]+CP_Gift_Per_Idioms;
    [Utils setCurrentCoins:coins];
    
    _myGoldLable.text = [NSString stringWithFormat:@"%d",coins];
    
    [self showPassedView];
}

- (UIImage *)getSharedImage{
    
    NSString *oldStr = _levelLable.text;
    
    _levelLable.text = NSLocalizedString(@"Share_Image_Title", "");
    
    _myGoldLable.hidden = YES;
    _backBtn.hidden = YES;
    _goldBtn.hidden = YES;
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //还原self.view
    _levelLable.text = oldStr;
    _myGoldLable.hidden = NO;
    _backBtn.hidden = NO;
    _goldBtn.hidden = NO;
    
    return aImage;
}



#pragma mark actions


- (IBAction)back:(id)sender
{
    [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
    
    /// 先完成动画，再back to home
    
    UIImageView *upIV = (UIImageView *)[self.view viewWithTag:CP_Up_Imageview_Tag];
    UIImageView *downIV = (UIImageView *)[self.view viewWithTag:CP_Down_Imageview_Tag];
    
    
    [UIView animateWithDuration:0.75 animations:^{
        
        [upIV setFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_CONTENT_HEIGHT/2)];
        upIV.alpha = 1.0;
        [downIV setFrame:CGRectMake(0,APP_SCREEN_CONTENT_HEIGHT/2 , APP_SCREEN_WIDTH, APP_SCREEN_CONTENT_HEIGHT/2)];
        downIV.alpha = 1.0;
        
        
    } completion:^(BOOL finished){
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        MainGuessViewController *homeVC = [sb instantiateViewControllerWithIdentifier:@"CPHomeViewController"];
        
        [self presentModalViewController:homeVC animated:NO];
        
    }];
    
}



// golden 够就提示，不够就去商店
- (IBAction)needPrompt:(id)sender
{
    [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
    
    //是否已经都填充了
    if([self allAnswered])
    {
        return;
    }
    [Flurry logEvent:kRevealLetterEvent];
    if([Utils currentCoins]>=[_promptCostLabel.text intValue]){
        //把还没有填词的btn 的tag装入array（)
        //需要考虑已经填充过一些的情况
        NSMutableArray *array = [NSMutableArray array];
        for (int i=0; i<_currentAnswer.length; i++) {
            UIButton *answerBtn = (UIButton *)[_answerContainerView viewWithTag:(i+CP_Answer_Button_Tag_Offset)];
            if ([answerBtn.titleLabel.text length] == 0) {
                [array addObject:[NSNumber numberWithInt:answerBtn.tag]];
            }
        }
        
        assert([array count] != 0);
        NSUInteger i = rand()%[array count];//([array count]==1)?0:rand()%[array count];
        //通过i确定需要提示的单词(需要考虑已经的填充的可能为错误的字母)
        int r = [array[i] intValue];
        NSString *prompt = [_currentAnswer substringWithRange:NSMakeRange(r-CP_Answer_Button_Tag_Offset, 1)];
        UIView *unknown = [_answerContainerView viewWithTag:r];
        if ([unknown isKindOfClass:[UIButton class]]) {
            UIButton *answerBtn = (UIButton *)unknown;
            [answerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [answerBtn setTitle:prompt forState:UIControlStateNormal];
        }
        
        // 通过这个 prompt 单词 找到在container view 的位置，隐藏word btn， 设置maps
        NSRange range = [self.currentPreparedString rangeOfString:prompt];
        NSUInteger candidateViewTag = range.location + CP_Word_Button_Tag_Offset;
        UIButton *wordBtn = (UIButton *)[_wordsContainerView viewWithTag:candidateViewTag];
        wordBtn.hidden = YES;
        
        self.maps[[NSNumber numberWithInt:r]]=[NSNumber numberWithInt:candidateViewTag];
        
        
        if ([self allAnswered]) { // 本轮提示后，成语完成，需要进入check模式
            [self checkAnswer];
        }
        
        NSInteger _currentCoins = [Utils currentCoins];
        if (_firstPrompt) {
            _currentCoins-=CP_First_Prompt_Cost;
            _firstPrompt = NO;
            
            [self setPromptCostLabel];
        }else{// 这是第二次提示了
            _currentCoins-=CP_NoFirst_Prompt_Cost;
        }
        
        _myGoldLable.text = [NSString stringWithFormat:@"%d",_currentCoins];
        [Utils setCurrentCoins:_currentCoins];
        [self hidePrompView];
    }else{// 跳到商店
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        [self presentViewController:[storyBoard instantiateViewControllerWithIdentifier:@"CPPropStoreViewController"] animated:NO completion:nil];
        
    }
    
}


#pragma mark 分享view
-(void)initShareView:(UIEdgeInsets) edge
{
//    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideShareView)];
//    [_shareMaskView addGestureRecognizer:tap2];
//    
    _shareBgIV.image = [[UIImage imageNamed:kGuess_MsgBox_Bg] resizableImageWithCapInsets:edge];
    _shareTitleLabel.text = NSLocalizedString(@"SNS_Help_Title_Weixin", "");
    _shareContentLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SNS_Share_Award_Text", ""),CP_Gift_For_Share_To_FriendZone];
    _shareView.hidden = YES;
    [_shareView setFrame:CGRectMake(0, _shareView.frame.origin.y+APP_SCREEN_CONTENT_HEIGHT, _shareView.frame.size.width, _shareView.frame.size.height)];
}

- (void)showShareView{
    //如果需要分享回调，请将delegate对象设置self，并实现下面的回调方法
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:CP_UMeng_App_Key
                                      shareText:NSLocalizedString(@"SNS_Help", "")
                                     shareImage:[self getSharedImage]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToFacebook,UMShareToTwitter,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToEmail,UMShareToSina,UMShareToTencent,UMShareToRenren,nil]
                                       delegate:self];
}
-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    [Flurry logEvent:kSNSShareEvent withParameters:[NSDictionary dictionaryWithObjectsAndKeys:platformName,kSNSPlatform, nil]];
    //weixin
    if ([platformName isEqualToString:UMShareToWechatSession] ||
        [platformName isEqualToString:UMShareToWechatTimeline] ) {
        socialData.extConfig.wxMessageType = UMSocialWXMessageTypeApp;
        socialData.extConfig.appUrl = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8",kAppleId];
    }
}


#pragma mark umeng sns delegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[[response.data allKeys] objectAtIndex:0],kShareBySNSResponse, nil];
        [Flurry logEvent:kShareBySNSResponse withParameters:dict];
    }
}


- (IBAction)promptClicked:(id)sender
{
    [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
    
    _prompView.hidden = NO;
    [self showPrompView];
}

- (IBAction)promptCancle:(id)sender
{
    [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
    
    [self hidePrompView];
}


- (IBAction)shareClicked:(id)sender
{
    [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
    
    [self showShareView];
}

- (IBAction)shareCancle:(id)sender
{
    [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
    
//    [self hideShareView];
    
}

//答案区view事件的处理
- (IBAction)answerButtonSelected:(id)sender
{
    [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
    
    UIButton *answerBtn = (UIButton *)sender;
    
    if (_isWrong) {
        for (int i=0; i<_currentAnswer.length; i++) {
            UIButton *btn = (UIButton *)[_answerContainerView viewWithTag:(i+CP_Answer_Button_Tag_Offset)];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        _answerBtnSelectWhenWrong = YES;
    }
    
    if([answerBtn.titleLabel.text length]>0){
        [answerBtn setTitle:nil forState:UIControlStateNormal];
        answerBtn.titleLabel.text = nil;
        
        //清除map关系
        NSNumber* key = [NSNumber numberWithInt:answerBtn.tag];
        int targetTag = [[self.maps objectForKey:key] intValue];
        [self.maps removeObjectForKey:key];
        
        // 原来的字母显示出来
        UIButton *wordBtn = (UIButton *)[_wordsContainerView viewWithTag:targetTag];
        wordBtn.hidden = NO;
    }
    
}

//候选区view事件的处理
- (void)wordButtonSelected:(id)sender
{
    [AudioSoundHelper playSoundWithFileName:kClickSound ofType:kMp3Suffix];
    
    //
    if (_isWrong) {
        if (!_answerBtnSelectWhenWrong) {
            for (int i=0; i<_currentAnswer.length; i++) {
                UIButton *btn = (UIButton *)[_answerContainerView viewWithTag:(i+CP_Answer_Button_Tag_Offset)];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitle:nil forState:UIControlStateNormal];
                btn.titleLabel.text = nil; //加这一句
                
                //对应的 word button 显示出来
                int targetTag = [[self.maps objectForKey:[NSNumber numberWithInt:btn.tag]] intValue];
                [_wordsContainerView viewWithTag:targetTag].hidden = NO;
                
            }
            
        }
        _answerBtnSelectWhenWrong = NO;
        _isWrong = NO;
    }
    
    UIButton *candidateBtn = (UIButton *)sender;
    NSString *text = candidateBtn.titleLabel.text;
    
    
    // set answer button
    int answerTag = CP_Answer_Button_Tag_Offset;
    UIView *unkonw = [_answerContainerView viewWithTag:([self nextAnswerViewPosition]+CP_Answer_Button_Tag_Offset)];
    if ([unkonw isKindOfClass:[UIButton class]]) {
        UIButton *answerBtn = (UIButton *)unkonw;
        [answerBtn setTitle:text forState:UIControlStateNormal];
        answerTag= answerBtn.tag;
    }
    
    
    // remove the selected word button
    
    // word 选中后就从contain中消失,但要记得点 answer btn 时还要放回来
    // 要记录每个字从哪个word btn来,通过tag来标记：如{0:1,1:3,2:12,3:21}
    // 因此，使用字典来记录就行了(self.maps)
    //
    candidateBtn.hidden = YES;
    [self.maps setObject:[NSNumber numberWithInt:candidateBtn.tag] forKey:[NSNumber numberWithInt:answerTag]];
    
    // 这是揭晓答案的时刻
    if([self allAnswered]){
        [self checkAnswer];
        return;
    }
}



#pragma mark 提示图片区的view布局
-(void)setupQuestionImageViews:(CGRect)rc
{
    //position view
    CGFloat margin = 4;
    CGFloat width = 2*rc.size.width/kQuestionImageViewCount;
    CGFloat height = 2*rc.size.height/kQuestionImageViewCount;
    CGRect frame = rc;
    frame.origin = CGPointZero;
    frame.size = CGSizeMake(width, height);
    
    //clear view container first
    [Utils removeSubviews:_mainQustionPicIV];
    
    for (NSInteger i=0; i<kQuestionImageViewCount; ++i) {
        //reset when new row begins
        //increment x by width
        if (i!=0 && i%kQuestionImageColumnCount==0) {
            frame.origin.x = 0;//rc.origin.x;
            frame.origin.y += height + margin;
        }
        else if(i!=0)
        {
            frame.origin.x += width + margin;
        }
        
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:frame];
        [_mainQustionPicIV addSubview:imageView];
        
        //set url for imageview
        if(questionImageResultArray && questionImageResultArray.count>i)
        {
            if ([imageView respondsToSelector:@selector(setImageWithURL:)]) {
                NSDictionary* dict = [questionImageResultArray objectAtIndex:i];
                NSMutableString* url = [NSMutableString stringWithString:[dict objectForKey:ThumbnailStringKey]];
                
                //有时需要对google返回的字符串做进一步的处理
                [url replaceOccurrencesOfString:@"qu003dtbn" withString:@"q=tbn" options:NSCaseInsensitiveSearch range:NSMakeRange(0, url.length-1)];
                [imageView setImageWithURL:[NSURL URLWithString:url]];
            }
        }
    }
}

#pragma mark get image lists
- (void)grabImagesInBackground:(NSString*)imageKeyword
{
    NSString* wordUrl = [NSString stringWithFormat:kQuestionImageUrlFormatter,imageKeyword];
    NSURL *url = [NSURL URLWithString:wordUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [ASIHTTPRequest setDefaultTimeOutSeconds:30];
    [request setDelegate:self];
    [request startAsynchronous];
}
#define HTTP_OK 200
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    
    //TODO::json decoding
    if (responseData) {
        NSError* error;
        id res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        if (res && [res isKindOfClass:[NSDictionary class]]) {
            id rootDict = (NSDictionary*)res;
            
            //get image list
            rootDict = [rootDict objectForKey:ResponseDataStringKey];
            if (!rootDict || ![rootDict isKindOfClass:[NSDictionary class]]) {
                return;
            }
            
            rootDict = [rootDict objectForKey:ResultsStringKey];
            if (!rootDict || ![rootDict isKindOfClass:[NSArray class]]) {
                return;
            }
            
            //bingo,now read image list
            if (!questionImageResultArray) {
                questionImageResultArray = [[NSMutableArray alloc]init];
            }
            [questionImageResultArray removeAllObjects];
            
            [questionImageResultArray addObjectsFromArray:(NSArray*)rootDict];
            //初始化图片显示用view，并进行定位，显示图片用
            [self setupQuestionImageViews:questionImageRect];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
    if (++retryCount>kRetryMaxCount) {
        return;
    }
    NSLog(@"retry to get images");
    //once again
    [self grabImagesInBackground:_currentAnswer];
}

#pragma mark 答题成功后弹出或消失提示框
/**
 答题成功时，弹出提示
 */
-(void)showPassedView
{
    _coinEffectView = [[coinView alloc]initWithFrame:[self.view bounds] withNum:CP_Gift_Per_Idioms];
    _coinEffectView.coindelegate = self;
    [self.view addSubview:_coinEffectView];
}
-(void)coinAnimationFinished
{
    [_coinEffectView removeFromSuperview];
    _coinEffectView = nil;
    
    //进入下一关
    [self next:nil];
}

#pragma mark 积分换提示
-(void)initPromptView:(UIEdgeInsets)edge
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePrompView)];
    [_prompMaskView addGestureRecognizer:tap];
    
    _prompBgIV.image = [[UIImage imageNamed:kGuess_MsgBox_Bg] resizableImageWithCapInsets:edge];
    _prompTitleLabel.text = NSLocalizedString(@"Dlg_Tip_Title", "");//@"提示";
    
    [_confirmLabel setTitle:NSLocalizedString(@"OK", "") forState:UIControlStateNormal];
    [_cancelLabel setTitle:NSLocalizedString(@"Cancel", "") forState:UIControlStateNormal];
    
    
    _prompView.hidden = YES;
}
- (void)setPromptCostLabel
{
    _promptCostLabel.text = [NSString stringWithFormat:@"%d",_firstPrompt?CP_First_Prompt_Cost:CP_NoFirst_Prompt_Cost];
}


- (void)showPrompView{
    [self.view bringSubviewToFront:_prompView];
    _prompContentLabel.text = [Utils currentCoins]>=[_promptCostLabel.text intValue]? [NSString stringWithFormat:NSLocalizedString(@"Dlg_Body_Exchange_Text", ""),_firstPrompt?CP_First_Prompt_Cost:CP_NoFirst_Prompt_Cost] : NSLocalizedString(@"Dlg_Body_No_Enough_Coins_Text", "");
    
}

- (void)hidePrompView{
    [self.view sendSubviewToBack:_prompView];
    _prompView.hidden = YES;
}
#pragma mark  加载本地数据，比如关数，金币等
-(void)loadLocalSettings
{
    _currentLevel = [Utils currentLevel];
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
    
    self.dataSource = array;
    
    [self startNewLevel];
    
    // 动画打开
    [self startGame];
}

#pragma mark next answer view pos
//返回下一个待填充的answer view的索引,如果没有找到的话，则返回NSNotFound
-(NSInteger)nextAnswerViewPosition
{
    //已经填充完毕
    if ([self allAnswered]) {
        return NSNotFound;
    }
    
    for (int i = 0; i<_currentAnswer.length; ++i) {
        if (nil==[self.maps objectForKey:[NSNumber numberWithInt:(i+CP_Answer_Button_Tag_Offset)]]) {
            return i;
        }
    }
    return NSNotFound;
}

//已经填充完毕
-(BOOL)allAnswered
{
    return (self.maps.count==_currentAnswer.length);
}
@end
