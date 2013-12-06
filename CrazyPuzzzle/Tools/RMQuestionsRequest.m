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

#define kQuestionListUrl @"http://checknewversion.duapp.com/image/questionlist.php"//请求问题列表url


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
        if (res && [res isKindOfClass:[NSArray class]]) {
            if(!self.questionsArray)
            {
                _questionsArray = [[NSMutableArray alloc]init];
            }
            [self.questionsArray removeAllObjects];
            
            [self.questionsArray addObjectsFromArray:(NSArray*)res];
            
            //bingo,now read image list
            [[NSNotificationCenter defaultCenter]postNotificationName:QUESTION_RESPONSE_NOTIFICATION object:self.questionsArray];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}
@end
