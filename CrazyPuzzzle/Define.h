//
//  Header.h
//  Social
//
//  Created by mobcent on 13-5-31.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#ifndef Define_h
#define Define_h





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




/**************    调试    ************************/

#define NEED_OUTPUT_LOG 1

#if NEED_OUTPUT_LOG

#define SLog(xx,...)	NSLog(xx,##__VA_ARGS__)
#define SLLog(xx,...)	NSLog(@"%s(%d):" xx,__PRETTY_FUNCTION__,__LINE__,##VA_ARGS__)
#else
#define SLog(xx,…)	((void)0)
#define SLLog(xx,…)	((void)0)
#endif


//SLLog(@"RobotCommands %@", RobotCommands);


/**************** 应用相关  ********************/
#define CP_Weixin_App_Id @"wxd32d6d3e8108ffcb" // demo: wxd930ea5d5a258f4f
#define CP_UMeng_App_Key @"529b291156240b5737148f50"
#define kFlurryAppId @"PQKG4KVJJNSMCMKTMFH9"

#define CP_Price_Key @"price"
#define CP_Value_Key @"value"

//flurry event
#define kFlurryShareBySNS @"ShareBySNS"
#define kFlurryLevel @"Level"

#define CP_Gift_Per_Idioms 3
#define CP_First_Prompt_Cost 10
#define CP_NoFirst_Prompt_Cost 20
#define CP_Gift_For_Share_To_FriendZone 20

#define CP_Lose_To_You 11

#define CP_Initial_Level 1
#define CP_Initial_Golden 220


#define CP_Gold_Table_List  @[@{CP_Price_Key:@"0.99",CP_Value_Key:NSLocalizedString(@"IAP_288", "")},\
    @{CP_Price_Key:@"1.99",CP_Value_Key:NSLocalizedString(@"IAP_666","")},\
    @{CP_Price_Key:@"2.99",CP_Value_Key:NSLocalizedString(@"IAP_1888","")},\
    @{CP_Price_Key:@"3.99",CP_Value_Key:NSLocalizedString(@"IAP_3999","")},\
    @{CP_Price_Key:@"4.99",CP_Value_Key:NSLocalizedString(@"IAP_11888","")}];

#define CP_Golden_ProductIDs @[@"com.idreems.288Coins",\
  @"com.idreems.666Coins",\
  @"com.idreems.1888Coins",\
  @"com.idreems.3999Coins",\
  @"com.idreems.11888Coins"]

#define CP_Golden_price(index) [@[@"0.99",@"1.99",@"2.99",@"3.99",@"4.99"] objectAtIndex:index]

#define CP_Golden_values @[@"288",@"666",@"1888",@"3999",@"11888"] 



#define kCPPaidForGoldsNotificatioin @"kCPPaidForGoldsNotificatioin"

#define CurrentLevelStringKey @"CurrentLevel"
#define CurrentGoldenStringKey @"CurrentGolden"
#define CurrentAudioStatusKey @"AudioStatus"
#define kBackgroundMusic @"bg0"
#define kClickSound @"mainclick"
#define kMp3Suffix @"mp3"


#endif
