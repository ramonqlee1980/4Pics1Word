//
//  RMCategoryRequest.h
//  4Imgs1Word
//  获取不同类别的请求
//  Created by Ramonqlee on 1/6/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

#define CATEGORY_RESPONSE_NOTIFICATION @"CATEGORY_RESPONSE_NOTIFICATION"

@interface RMCategoryRequest : NSObject


Decl_Singleton(RMCategoryRequest);

- (void)startAsynchronous;//请求问题列表，数据将通过通知的方式异步返回，通知名：CATEGORY_RESPONSE_NOTIFICATION

//catory related
-(NSUInteger)count;
-(id)category:(NSUInteger)index;
@end
