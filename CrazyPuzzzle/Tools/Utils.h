//
//  Utils.h
//  CrazyPuzzzle
//
//  Created by Ramonqlee on 12/1/13.
//  Copyright (c) 2013 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

//挑战的种类
#define kFreeGuessGame @"ImageWords"//初始的自由猜单词
#define kDailyGuessGame @"DailyGuessGame"//每日挑战


#define CP_Initial_Level_FROM_ZERO 0
#define CP_Initial_Level_FROM_ONE 1

#define Decl_Singleton(className) +(className*)sharedInstance;

#define Impl_Singleton(className) static className* s##className;\
+(className*)sharedInstance\
{\
if(!s##className)\
{\
s##className = [[className alloc]init];\
}\
return s##className;\
}

@interface Utils : NSObject
+ (NSString *)getIPAddress;

+ (NSString *)encodeToPercentEscapeString: (NSString *) input;
+ (NSString *)decodeFromPercentEscapeString: (NSString *) input;

+(void)removeSubviews:(UIView*)view;

//coins access
+(void)setCurrentCoins:(NSInteger)coins;
+(NSUInteger)currentCoins;

//level access
+(void)setLevel:(NSInteger)level forCategory:(NSString*)name;
+(NSUInteger)level:(NSString*)name;
    
    
+(id)objectForKey:(NSString *)defaultName;
+(void)setValue:(id)value forKey:(NSString *)defaultName;

+(void)setDailyChallengeOff;//关闭每日挑战
+(BOOL)dailyChallengeOn;//是否可以进入每日挑战

//关卡相关
+(void)unlockCategory:(NSString*)levelName;
+(BOOL)categoryUnlocked:(NSString*)levelName;

//和每日有关的开关
+(void)setDailySwitch:(NSString*)key switchOn:(BOOL)on;//设置今日和key相关的开关
+(BOOL)dailySwitch:(NSString*)key;//和key相关的开关是否开启
@end

