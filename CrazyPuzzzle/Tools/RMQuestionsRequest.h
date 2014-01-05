//
//  RMAnswersRequest.h
//  CrazyPuzzzle
//
//  Created by Ramonqlee on 12/1/13.
//  Copyright (c) 2013 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"


/**************** constants for game ********************/
#define Coins_Init_Award [RMQuestionsRequest sharedInstance].initAwardCoins
#define Coins_Awarded_Per_Word [RMQuestionsRequest sharedInstance].awardCoinsPerWord
#define Coins_Cost_Per_Tip [RMQuestionsRequest sharedInstance].coinsPerTip
#define NonFirst_Coins_Cost_Per_Tip Coins_Cost_Per_Tip
#define Coins_Cost_For_Unlock_Category [RMQuestionsRequest sharedInstance].coinsForUnlockCategory//开启某一关需要的积分数


#define QUESTION_RESPONSE_NOTIFICATION @"QUESTION_RESPONSE_NOTIFICATION"


@interface RMQuestionsRequest : NSObject

@property(atomic,strong)NSMutableArray* questionsArray;
@property(atomic,assign)NSInteger initAwardCoins;//初始奖励的金币
@property(atomic,assign)NSInteger awardCoinsPerWord;//猜中一个单词的奖励金币
@property(atomic,assign)NSInteger coinsPerTip;//提示一个单词所需金币
@property(atomic,assign)NSInteger coinsForUnlockCategory;//开启一个新的种类所需的积分

Decl_Singleton(RMQuestionsRequest);

- (void)startAsynchronous;//请求问题列表，数据将通过通知的方式异步返回，通知名：QUESTION_RESPONSE_NOTIFICATION

@end
