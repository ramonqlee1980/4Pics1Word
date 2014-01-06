//
//  RMCategoryRequest.m
//  4Imgs1Word
//
//  Created by Ramonqlee on 1/6/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import "RMCategoryRequest.h"
#import "ASIHTTPRequest.h"
#import "RMCategory.h"
#import "Utility.h"

#define kCategoryListUrl @"http://checknewversion.duapp.com/image/refer.php?table=WordGuess"//请求分类列表

@interface RMCategoryRequest()
@property(nonatomic,retain)NSMutableArray* categoryArray;//返回的数组,元素为RMCategory
@end

@implementation RMCategoryRequest
Impl_Singleton(RMCategoryRequest)

- (void)startAsynchronous
{
    if (self.categoryArray && self.categoryArray.count>0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:CATEGORY_RESPONSE_NOTIFICATION object:self.categoryArray];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:kCategoryListUrl];
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
            dataList = [dict objectForKey:@"data"];
        }
        
        if (dataList) {
            if(!self.categoryArray)
            {
                _categoryArray = [[NSMutableArray alloc]init];
            }
            
            [self.categoryArray removeAllObjects];
            [self.categoryArray addObjectsFromArray:(NSArray*)dataList];
            [self postProcess];
            
            //bingo,now read image list
            [[NSNotificationCenter defaultCenter]postNotificationName:CATEGORY_RESPONSE_NOTIFICATION object:self.categoryArray];
        }
    }
}
//过滤超长的单词
-(void)postProcess
{
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

#pragma catory related
-(NSUInteger)count
{
    return self.categoryArray.count;
}

-(id)category:(NSUInteger)index
{
    if (index>=self.categoryArray.count) {
        return nil;
    }
    id obj = [self.categoryArray objectAtIndex:index];
    
    return [RMCategory categoryWithDict:obj];
}
@end
