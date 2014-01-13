#ifndef __CONSTANTS__
#define __CONSTANTS__
/**************    调试    ************************/

#define NEED_OUTPUT_LOG 0

#if NEED_OUTPUT_LOG
#define SLog(xx,...)	NSLog(xx,##__VA_ARGS__)
#define SLLog(xx,...)	NSLog(@"%s(%d):" xx,__PRETTY_FUNCTION__,__LINE__,##VA_ARGS__)
#else
#define NSLog(xx,...)
#define SLog(xx,...)
#define SLLog(xx,...)
#endif

/**************** 应用采用的id  ********************/
#define CP_Weixin_App_Id @"wxd32d6d3e8108ffcb"
#define CP_UMeng_App_Key @"529b291156240b5737148f50"
#define kFlurryAppId @"PQKG4KVJJNSMCMKTMFH9"
#define kAppleId @"776660126"


/**************** flurry event ********************/
#define kShareBySNSResponseEvent @"ShareBySNSResponse"
#define kFlurryLevelEvent @"Level"
#define kCoinsAmountKey @"Coins"
#define kRevealLetterEvent @"RevealLetterEvent"
#define kSNSShareEvent @"SNSShareEvent"
#define kSNSPlatformKey @"SNSPlatform"
#define kEnterIAPViewEvent @"EnterIAPViewEvent"
#define kUnlockCategoryEvent @"UnlockCategory"

//金币变更事件，将记录变更前后的金币数量
#define kCoinsChangeEvent @"CoinsChangeEvent"
#define kCurrentCoinsKey @"CurrentCoins"
#define kOriginalCoinsKey @"OriginalCoins"

/***********  系统通用设置  *********************/
#define kColorManagerFileName @""
#define Degrees_To_Radians(x) (x * M_PI / 180)

/*************  系统通用宏  **********************/
#define USER_DEFAULT [NSUserDefaults standardUserDefaults] 
#define MAIN_BUDDLE [NSBundle mainBundle]

#define APP_CACHES_PATH [NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define COLOR_FILE_PATH [[NSBundle mainBundle] pathForResource:@"colors" ofType:@"plist"] //colors.plist

#define APP_SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define APP_SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height
#define APP_SCREEN_CONTENT_HEIGHT   ([UIScreen mainScreen].bounds.size.height-20.0)




/**************** IAP相关 ********************/
#define CP_Gold_Table_List  @[@{CP_Price_Key:@"0.99",CP_Value_Key:NSLocalizedString(@"IAP_288", "")},\
    @{CP_Price_Key:@"1.99",CP_Value_Key:NSLocalizedString(@"IAP_666","")},\
    @{CP_Price_Key:@"2.99",CP_Value_Key:NSLocalizedString(@"IAP_1888","")},\
    @{CP_Price_Key:@"3.99",CP_Value_Key:NSLocalizedString(@"IAP_3999","")},\
    @{CP_Price_Key:@"4.99",CP_Value_Key:NSLocalizedString(@"IAP_11888","")}];

#define CP_Golden_ProductIDs @[@"com.idreems.Coins288",\
  @"com.idreems.Coins666",\
  @"com.idreems.Coins1888",\
  @"com.idreems.Coins3999",\
  @"com.idreems.Coins11888"]

#define CP_Golden_price(index) [@[@"0.99",@"1.99",@"2.99",@"3.99",@"4.99"] objectAtIndex:index]
#define CP_Golden_values @[@"288",@"666",@"1888",@"3999",@"11888"]
#define kCPPaidForGoldsNotificatioin @"kCPPaidForGoldsNotificatioin"

//iap event during purchasing
#define kInAppPurchaseEvent @"InAppPurchaseEvent"
#define kRequestIAPProductData @"RequestIAPProductData"
#define kCompleteIAPTransaction @"CompleteIAPTransaction"
#define kFailedIAPTransaction @"FailedIAPTransaction"
#define kRestoreIAPTransaction @"RestoreIAPTransaction"
#define kReceiveIAPProducts @"ReceiveIAPProducts"
#define kFailtoReceiveIAPProducts @"FailtoReceiveIAPProducts"


/**************** 相关设置 ********************/
#define CurrentAudioStatusKey @"AudioStatus"
#define kBackgroundMusic @"bg0"
#define kClickSound @"mainclick"
#define kMp3Suffix @"mp3"

#define CP_Price_Key @"price"
#define CP_Value_Key @"value"

#define HTTP_OK 200
#endif//__CONSTANTS__
