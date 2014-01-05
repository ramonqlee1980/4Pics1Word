//
//  ChallengeViewController.h
//  用于猜单词游戏的界面及其逻辑处理
//
//  Created by Ramonqlee on 12/11/13.
//  Copyright (c) 2013 idreems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMGuessWordView.h"

@interface ChallengeController : UIViewController
{
}
@property(nonatomic,assign)id<GuessWordViewDelegate> delegate;
-(void)invalidate:(NSArray*)array;//更新数据
- (IBAction)backHome:(id)sender;
@end
