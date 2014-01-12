//
//  ClassifedController.m
//  4Imgs1Word
//
//  Created by Ramonqlee on 1/3/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import "ClassifiedController.h"
#import "ClassifiedCell.h"
#import "Utils.h"
#import "UIImageView+WebCache.h"
#import "RMQuestionsRequest.h"
#import "RMCategoryRequest.h"
#import "RMCategory.h"
#import "ChallengeController.h"
#import "CategoryGuessChallengeDelegate.h"
#import "Flurry.h"

//标示：用于区别当前的提示是何种类型
#define kAlertViewForShopping 0
#define kAlertViewForPlay 1

static NSString *CellIdentifier = @"ClassfiedCellIdentifier";
static NSString *CellNIBName = @"ClassifiedCell";

@interface ClassifiedController ()<TableViewCellDelegate>
    {
        NSMutableArray* categoryArray;
        ChallengeController* challengeController;
        RMCategory* selectedCategory;
    }
    @end

@implementation ClassifiedController
    
    @synthesize currentCoinsLabel;
    @synthesize currentTableView;
    
- (void)viewDidLoad
    {
        [super viewDidLoad];
        
        if(!categoryArray)
        {
            categoryArray = [NSMutableArray new];
        }
        
        //update current coins
        if(currentCoinsLabel)
        {
            currentCoinsLabel.text = [NSString stringWithFormat:@"%d",[Utils currentCoins]];
        }
        
        //tableview's cell
        UINib *nib = [UINib nibWithNibName:CellNIBName bundle:nil];
        [self.currentTableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        self.currentTableView.dataSource = self;
        self.currentTableView.delegate = self;
        
        //right and left button
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                          target:self action:@selector(shopButtonClicked:)];
        self.navigationItem.rightBarButtonItem = refreshButton;
        
        UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [a1 setFrame:CGRectMake(0.0f, 0.0f, 35.0f, 25.0f)];
        [a1 addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [a1 setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
        refreshButton = [[UIBarButtonItem alloc] initWithCustomView:a1];
        
        self.navigationItem.leftBarButtonItem = refreshButton;
        
        //请求网络数据
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(categoryResponseReceived:) name:CATEGORY_RESPONSE_NOTIFICATION object:nil];
        [[RMCategoryRequest sharedInstance]startAsynchronous];
    }
#pragma mark 请求网络数据返回后的处理
-(void)categoryResponseReceived:(NSNotification*)notification
    {
        //从服务器端请求数据
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        if([notification.object isKindOfClass:[NSArray class]])
        {
            [categoryArray removeAllObjects];
            [categoryArray addObjectsFromArray:(NSArray*)notification.object];
            [currentTableView reloadData];
        }
    }
- (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }
    
#pragma mark - Table view data source
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
    {
        // Return the number of sections.
        return 1;
    }
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        // Return the number of rows in the section.
        return categoryArray?categoryArray.count:0;
    }
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        ClassifiedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        
        id obj = [categoryArray objectAtIndex:indexPath.row];
        RMCategory* item = [RMCategory categoryWithDict:obj];
        
        if (item) {
            // Configure the cell...
            cell.topLabel.text = item.name;
            
            if (!item.description || item.description.length==0) {
                cell.bottomLabel.text = [NSString stringWithFormat:@"%d Coins",item.coins];
            }
            else
            {
                cell.bottomLabel.text = item.description;
            }
            
            [cell.imageView setImageWithURL:[NSURL URLWithString:item.iconUrl]];
            //需要传递当前level的编号，用于解锁时记录用
            cell.extra = item;
        }
        
        return cell;
    }
    
#pragma mark left&right button responder
-(IBAction)back:(id)sender
    {
        [self dismissModalViewControllerAnimated:YES];
    }
- (IBAction)shopButtonClicked:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    [self presentViewController:[storyBoard instantiateViewControllerWithIdentifier:@"CPPropStoreViewController"] animated:NO completion:nil];
}
    
#pragma mark tableviewcell's button selector
- (void)TableViewCell:(UITableViewCell *)cell buttonPressed:(id)sender
    {
        //TODO::积分兑换可以进入此关，否则提示积分不足，需要购买，并可以跳转到购买界面
        if([cell isKindOfClass:[ClassifiedCell class]])
        {
            selectedCategory = ((ClassifiedCell*)cell).extra;
        }
        
        //category unlocked?
        BOOL unlocked = [Utils categoryUnlocked:[NSString stringWithFormat:@"%d",selectedCategory.identifier]];
        NSString* body = NSLocalizedString(@"Dlg_Body_No_Enough_Coins_Text","");//积分不足
        NSUInteger coins2Unlock = selectedCategory.coins;
        if (unlocked || coins2Unlock==0) {//no coins needed,just enter
            [self startGame:0 withCategory:selectedCategory.identifier];
            return;
        }
        
        NSInteger alertViewTag = kAlertViewForShopping;
        if ([Utils currentCoins]>=coins2Unlock) {
            body = [NSString stringWithFormat:NSLocalizedString(@"Dlg_Body_Unlock_Text",""),coins2Unlock];
            alertViewTag = kAlertViewForPlay;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:body delegate:self cancelButtonTitle:NSLocalizedString(@"OK", "")otherButtonTitles:NSLocalizedString(@"Cancel", ""), nil];
        alert.tag = alertViewTag;
        [alert show];
    }
    
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==kAlertViewForShopping)
    {
        switch (buttonIndex) {
            case 0:
            [self shopButtonClicked:nil];
            break;
            case 1:
            NSLog(@"Button 1 Pressed");
            break;
            default:
            break;
        }
    }
    else
    {
        switch (buttonIndex) {
            case 0:
            {
                NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:selectedCategory.coins],selectedCategory.category, nil];
                [Flurry logEvent:kUnlockCategory withParameters:dict];
                [self startGame:selectedCategory.coins withCategory:selectedCategory.identifier];
            }
            break;
            case 1:
            NSLog(@"Button 1 Pressed");
            break;
            default:
            break;
        }
        
    }
}
-(void)startGame:(NSUInteger)coins withCategory:(NSUInteger)identifier
    {
        //TODO::积分足够，直接扣减后，进入当前关
        //记录下当前关已经激活了
        NSUInteger totalCoins = [Utils currentCoins];
        [Utils setCurrentCoins:(totalCoins-coins)];
        [Utils unlockCategory:[NSString stringWithFormat:@"%d",identifier]];
        
        //TODO::缺少首次进入的动画
        challengeController = [[ChallengeController alloc]initWithNibName:@"ChallengeController" bundle:nil];
        [self presentModalViewController:challengeController animated:YES];
        CategoryGuessChallengeDelegate* delegate = [CategoryGuessChallengeDelegate new];
        delegate.category = selectedCategory.category;
        
        challengeController.delegate = delegate;
        
        //请求网络数据
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dailyResponseReceived:) name:QUESTION_RESPONSE_NOTIFICATION object:nil];
        [[RMQuestionsRequest sharedInstance]startAsynchronous:selectedCategory.category];
        
    }
    
#pragma mark 请求网络数据返回后的处理
-(void)dailyResponseReceived:(NSNotification*)notification
    {
        //从服务器端请求数据
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        if([notification.object isKindOfClass:[NSArray class]])
        {
            [challengeController invalidate:(NSArray*)notification.object withLevel:[challengeController.delegate startLevel]];
        }
        
    }
    @end
