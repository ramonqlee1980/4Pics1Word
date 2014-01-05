//
//  FreeGuessChallengeDelegate.m
//  4Imgs1Word
//
//  Created by Ramonqlee on 1/5/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import "CategoryGuessChallengeDelegate.h"
#import "Utils.h"

@implementation CategoryGuessChallengeDelegate
@synthesize category;

-(NSUInteger)startLevel
{
    return [Utils level:category];
}
-(void)willEnterLevel:(NSUInteger)index withCoins:(NSUInteger)count
{
}

-(void)didEnterLevel:(NSUInteger)index withCoins:(NSUInteger)totalCount
{
    //记录所闯关的序号
    [Utils setLevel:index forCategory:category];
}

-(void)coinsChanged:(NSUInteger)currentCoins
{
    
}
-(void)gameover
{
    [Utils setLevel:CP_Initial_Level_FROM_ZERO forCategory:category];
}
@end
