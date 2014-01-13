//
//  ChallengeBaseDelegate.m
//  WordGuess
//
//  Created by Ramonqlee on 1/14/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import "ChallengeBaseDelegate.h"
#import "Utils.h"
#import "Flurry.h"

@implementation ChallengeBaseDelegate
-(NSUInteger)startLevel
{
    return 0;
}
-(void)willEnterLevel:(NSUInteger)index withCoins:(NSUInteger)totalCount
{
}
-(void)didEnterLevel:(NSUInteger)index withCoins:(NSUInteger)totalCount
{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:index],kFlurryLevelEvent,[NSNumber numberWithInteger:totalCount],kCoinsAmountKey, nil];
    [Flurry logEvent:kFlurryLevelEvent withParameters:dict];
}

-(void)coinsChanged:(NSUInteger)currentCoins fromCoins:(NSUInteger)originalCoins
{
    NSNumber* originalCoinsNumber = [NSNumber numberWithInteger:originalCoins];
    NSNumber* currentCoinsNumber = [NSNumber numberWithInteger:currentCoins];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:originalCoinsNumber,kOriginalCoinsKey,currentCoinsNumber,kCurrentCoinsKey, nil];
    [Flurry logEvent:kCoinsChangeEvent withParameters:dict];
}

- (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters
{
    if (!eventName || eventName.length==0) {
        return;
    }
    
    if (parameters) {
        [Flurry logEvent:eventName withParameters:parameters];
    }
    else
    {
        [Flurry logEvent:eventName];
    }
}

-(void)gameover
{
}
-(void)share2FriendBySNS:(NSString*)name
{
}
@end
