//
//  HomeViewController.h
//  Modified:初始进入的界面，用于选择进入猜词的那个环节

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UMFeedback.h"

@interface HomeViewController : UIViewController<UMFeedbackDataDelegate>{

    __weak IBOutlet UIButton *_musicOnBtn;
    __weak IBOutlet UIButton *_musicOffBtn;
    
    __weak IBOutlet UIButton *_shopCarBtn;
    __weak IBOutlet UIImageView *_fengChe;
    
    __weak IBOutlet UIButton *_startGameBtn;
    __weak IBOutlet UIButton *_dailyChallengeBtn;
    __weak IBOutlet UILabel *_dailyChallengeLabel;
    
    BOOL _audioStatus; // 1 播放 0 停止
}

@property (nonatomic,strong) UIImage *homeScreenShot;

- (IBAction)startGame:(id)sender;
- (IBAction)EnterGradeView:(id)sender;
- (IBAction)openMusic:(id)sender;
- (IBAction)closeMusic:(id)sender;

- (IBAction)feedBack:(id)sender;

@end
