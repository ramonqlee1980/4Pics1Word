//
//  RMAnswersRequest.m
//  CrazyPuzzzle
//
//  Created by Ramonqlee on 12/1/13.
//  Copyright (c) 2013 xiaoran. All rights reserved.
//

#import "RMQuestionsRequest.h"
#import "ASIHTTPRequest.h"

#define HTTP_OK 200
#define CP_Words_Max_Length 16//允许的最大单词长度

#define kQuestionListUrl @"http://checknewversion.duapp.com/image/questionlist2.php"//请求问题列表url


@implementation RMQuestionsRequest
#pragma mark get image lists
Impl_Singleton(RMQuestionsRequest)

- (void)startAsynchronous
{
    if (self.questionsArray && self.questionsArray.count>0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:QUESTION_RESPONSE_NOTIFICATION object:self.questionsArray];
        return;
    }
    NSURL *url = [NSURL URLWithString:kQuestionListUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [ASIHTTPRequest setDefaultTimeOutSeconds:30];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    //    NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    
    //TODO::数据解析，及保存
    //服务器端数据打包，返回；
    //客户端解包，保存
    if (responseData) {
        NSError* error;
        id res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        
        NSArray* dataList = nil;
        
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* dict = (NSDictionary*)res;
            id temp = [dict objectForKey:@"initAwardCoins"];
            if (temp && [temp isKindOfClass:[NSNumber class]]) {
                self.initAwardCoins = ((NSNumber*)temp).integerValue;
            }
            
            temp = [dict objectForKey:@"awardCoinsPerWord"];
            if (temp && [temp isKindOfClass:[NSNumber class]]) {
                self.awardCoinsPerWord = ((NSNumber*)temp).integerValue;
            }
            
            temp = [dict objectForKey:@"coinsPerTip"];
            if (temp && [temp isKindOfClass:[NSNumber class]]) {
                self.coinsPerTip = ((NSNumber*)temp).integerValue;
            }
            
            temp = [dict objectForKey:@"coinsForUnlockCategory"];
            if (temp && [temp isKindOfClass:[NSNumber class]]) {
                self.coinsForUnlockCategory = ((NSNumber*)temp).integerValue;
            }
            
            dataList = [dict objectForKey:@"data"];
        }
        
        if (dataList) {
            if(!self.questionsArray)
            {
                _questionsArray = [[NSMutableArray alloc]init];
            }
            
            [self.questionsArray removeAllObjects];
            [self.questionsArray addObjectsFromArray:(NSArray*)dataList];
            [self postProcess];
            
            //bingo,now read image list
            [[NSNotificationCenter defaultCenter]postNotificationName:QUESTION_RESPONSE_NOTIFICATION object:self.questionsArray];
        }
    }
}
    //过滤超长的单词
-(void)postProcess
{
    for (int i= self.questionsArray.count-1; i>=0; i--) {
        if ([[self.questionsArray objectAtIndex:i]length]>CP_Words_Max_Length) {
            [self.questionsArray removeObjectAtIndex:i];
        }
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}
@end
