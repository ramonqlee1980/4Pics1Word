//
//  RMAnswersRequest.h
//  CrazyPuzzzle
//
//  Created by Ramonqlee on 12/1/13.
//  Copyright (c) 2013 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

#define QUESTION_RESPONSE_NOTIFICATION @"QUESTION_RESPONSE_NOTIFICATION"
#define CP_Words_Max_Length 16//允许的最大单词长度

@interface RMQuestionsRequest : NSObject

@property(atomic,strong)NSMutableArray* questionsArray;
@property(atomic,assign)NSInteger initAwardCoins;//初始奖励的金币
@property(atomic,assign)NSInteger awardCoinsPerWord;//猜中一个单词的奖励金币
@property(atomic,assign)NSInteger coinsPerTip;//提示一个单词所需金币
@property(atomic,assign)NSInteger coinsForUnlockCategory;//开启一个新的种类所需的积分

Decl_Singleton(RMQuestionsRequest);

- (void)startAsynchronous;//请求问题列表，数据将通过通知的方式异步返回，通知名：QUESTION_RESPONSE_NOTIFICATION

@end
