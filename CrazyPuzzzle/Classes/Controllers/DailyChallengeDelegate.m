//
//  DailyChallengeDelegate.m
//  4Imgs1Word
//
//  Created by Ramonqlee on 1/5/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import "DailyChallengeDelegate.h"
#import "Utils.h"
#import "Flurry.h"

@implementation DailyChallengeDelegate
-(NSUInteger)startLevel
{
    return [Utils level:kDailyGuessGame];
}
-(void)willEnterLevel:(NSUInteger)index withCoins:(NSUInteger)totalCount
{
    [super willEnterLevel:index withCoins:totalCount];
}
-(void)didEnterLevel:(NSUInteger)index withCoins:(NSUInteger)totalCount
{
    [super didEnterLevel:index withCoins:totalCount];
    //记录所闯关的序号
    [Utils setLevel:index forCategory:kDailyGuessGame];
}

-(void)gameover
{
    [Utils setLevel:CP_Initial_Level_FROM_ZERO forCategory:kDailyGuessGame];
    
    [Utils setDailyChallengeOff];
}
@end
