//
//  FreeGuessChallengeDelegate.h
//  4Imgs1Word
//  供用户积累积分的猜单词回调，此部分不分类，后续单词表也不再更新
//  Created by Ramonqlee on 1/5/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMGuessWordView.h"

@interface CategoryGuessChallengeDelegate : NSObject<GuessWordViewDelegate>

@property(nonatomic,copy)NSString* category;

@end
