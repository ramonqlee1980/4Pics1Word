//
//  Utils.h
//  CrazyPuzzzle
//
//  Created by Ramonqlee on 12/1/13.
//  Copyright (c) 2013 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CP_Initial_Level 1

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
+(void)setCurrentLevel:(NSInteger)level;
+(NSUInteger)currentLevel;
    
    
+(id)objectForKey:(NSString *)defaultName;
+(void)setValue:(id)value forKey:(NSString *)defaultName;


+(void)setDailyChallengeOff;//关闭每日挑战
+(BOOL)dailyChallengeOn;//是否可以进入每日挑战
@end
