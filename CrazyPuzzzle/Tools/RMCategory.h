//
//  RMCategory.h
//  4Imgs1Word
//
//  Created by Ramonqlee on 1/6/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMCategory : NSObject

@property(nonatomic,copy)NSString* iconUrl;
@property(nonatomic,copy)NSString* name;
@property(nonatomic,assign)NSInteger identifier;//该category的标示
@property(nonatomic,copy)NSString* description;//optional
@property(nonatomic,copy)NSString* category;//用于请求category时的参数
@property(nonatomic,retain)NSMutableArray* wordArray;//deprecated

+(id)categoryWithDict:(NSDictionary*)item;
@end
