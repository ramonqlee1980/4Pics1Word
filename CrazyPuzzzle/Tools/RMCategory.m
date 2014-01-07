//
//  RMCategory.m
//  4Imgs1Word
//
//  Created by Ramonqlee on 1/6/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import "RMCategory.h"

@implementation RMCategory
@synthesize iconUrl;
@synthesize  name;
@synthesize  identifier;//该category的标示
@synthesize  description;//optional
@synthesize category;

-(id)init
{
    self = [super init];
    if(self)
    {
    }
    
    return self;
}
+(id)categoryWithDict:(NSDictionary*)item
{
    RMCategory* temp = [RMCategory new];
    
    id obj = [item objectForKey:@"iconUrl"];
    if (obj&&[obj isKindOfClass:[NSString class]]) {
        temp.iconUrl = (NSString*)obj;
    }
    
    obj = [item objectForKey:@"name"];
    if (obj&&[obj isKindOfClass:[NSString class]]) {
        temp.name = (NSString*)obj;
    }
    
    obj = [item objectForKey:@"description"];
    if (obj&&[obj isKindOfClass:[NSString class]]) {
        temp.description = (NSString*)obj;
    }
    
    obj = [item objectForKey:@"identifier"];
    if (obj&&[obj isKindOfClass:[NSNumber class]]) {
        temp.identifier = ((NSNumber*)obj).integerValue;
    }
    
    obj = [item objectForKey:@"category"];
    if (obj&&[obj isKindOfClass:[NSString class]]) {
        temp.category = (NSString*)obj;
    }
    
    obj = [item objectForKey:@"Coins"];
    if (obj&&[obj isKindOfClass:[NSNumber class]]) {
        temp.coins = ((NSNumber*)obj).integerValue;
    }

    
    return temp;
}
@end
