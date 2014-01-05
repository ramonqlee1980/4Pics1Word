//
//  FreeGuessChallengeDelegate.m
//  4Imgs1Word
//
//  Created by Ramonqlee on 1/5/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import "FreeGuessChallengeDelegate.h"
#import "Utils.h"

@implementation FreeGuessChallengeDelegate
-(NSUInteger)startLevel
{
    return [Utils level:kFreeGuessGame];
}
-(void)willEnterNewLevel:(NSUInteger)currentCoins onCurrentStage:(NSUInteger)pos
{
}

-(void)didEnterNewLevel:(NSUInteger)currentCoins onCurrentStage:(NSUInteger)pos
{
    //记录所闯关的序号
    [Utils setLevel:pos forCategory:kFreeGuessGame];
}
-(void)coinsChanged:(NSUInteger)currentCoins
{
    
}
-(void)gameover
{
    [Utils setLevel:CP_Initial_Level_FROM_ZERO forCategory:kFreeGuessGame];
}
@end
