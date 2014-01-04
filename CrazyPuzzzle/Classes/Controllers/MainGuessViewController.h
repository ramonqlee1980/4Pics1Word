//
//  MainGuessViewController
//  猜词主界面

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "coinView.h"
#import "UMSocialControllerService.h"

@interface MainGuessViewController : UIViewController<WXApiDelegate,coinViewDelegate,UMSocialUIDelegate>{

    __weak IBOutlet UILabel *_myGoldLable;
    __weak IBOutlet UILabel *_levelLable;
    __weak IBOutlet UIImageView *_mainQustionPicIV;
    __weak IBOutlet UILabel *_promptCostLabel; /// 30 or 90
    
    __weak IBOutlet UIButton *_backBtn;
    __weak IBOutlet UIButton *_goldBtn;
    
    __weak IBOutlet UIButton *_firstBtn;//deprecated
    __weak IBOutlet UIButton *_sencondBtn;//deprecated
    __weak IBOutlet UIButton *_thirdBtn;//deprecated
    __weak IBOutlet UIButton *_fouthBtn;//deprecated
    
    UIView *_answerContainerView;//答案面板
    __weak IBOutlet UIView *_wordsContainerView;//文字面板
    
    __weak IBOutlet UIView *_prompView;
    __weak IBOutlet UIView *_prompMaskView;
    __weak IBOutlet UIImageView *_prompBgIV;
    __weak IBOutlet UILabel *_prompTitleLabel;
    __weak IBOutlet UILabel *_prompContentLabel;
    __weak IBOutlet UIButton *_confirmLabel;
    __weak IBOutlet UIButton *_cancelLabel;
    
    __weak IBOutlet UIView *_shareView;
    __weak IBOutlet UIView *_shareMaskView;
    __weak IBOutlet UIImageView *_shareBgIV;
    __weak IBOutlet UILabel *_shareTitleLabel;
    __weak IBOutlet UILabel *_shareContentLabel;
    
    NSInteger _currentLevel;  // 当前level
    NSString *_currentAnswer; // 答案
    
    BOOL _isWrong;
    BOOL _answerBtnSelectWhenWrong;
    BOOL _firstPrompt;
}

@property (strong,nonatomic) NSArray *dataSource;
@property (strong,nonatomic) NSMutableString *wordsString; //所有备选字母
@property (strong,nonatomic) NSString *currentPreparedString;// 随机后，顺序显示的串
@property (strong,nonatomic) NSMutableDictionary *maps;//记录答案view tag和备选view tag的对应关系（用于恢复备选view用）
@property (strong, nonatomic) coinView *coinEffectView;
@property (nonatomic,strong) UIImage *homeScreenShot;

- (IBAction)promptClicked:(id)sender;
- (IBAction)promptCancle:(id)sender;
- (IBAction)needPrompt:(id)sender;

- (IBAction)back:(id)sender; // back to home

- (IBAction)shareClicked:(id)sender;
- (IBAction)shareCancle:(id)sender;


- (IBAction)next:(id)sender;
- (IBAction)answerButtonSelected:(id)sender;
@end
