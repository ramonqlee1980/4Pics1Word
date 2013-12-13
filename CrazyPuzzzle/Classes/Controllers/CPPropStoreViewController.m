//
//  CPPropStoreViewController.m
//  CrazyPuzzzle
//
//  Created by mac on 13-8-11.
//  Copyright (c) 2013年 xiaoran. All rights reserved.
//

#import "CPPropStoreViewController.h"
#import "MyTableViewController.h"
#import "MBProgressHUD.h"
#import "Flurry.h"
#import <StoreKit/StoreKit.h>
#import "Utils.h"

#define CP_Number_Of_Rows 5
#define CP_Height_Of_Row  88
#define CP_Width_Of_Cell _tableView.frame.size.width

#define CP_Cell_Tag_Offset 100

#define CP_Price_Key @"price"
#define CP_Value_Key @"value"


#define Shop_Button_Open_PNG @"shop_button_open.png"
#define Shop_Button_Close_PNG @"shop_button_close.png"

@interface CPPropStoreViewController ()

@end

@implementation CPPropStoreViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.dataSourceOfGold = CP_Gold_Table_List;
    
    self.dataSourceOfTask = @[];
    
//    _promptLabel.text = [NSString stringWithFormat:@""];
//    _promptLabel.hidden = YES;
    
    _coinLeftLbl.text = [NSString stringWithFormat:NSLocalizedString(@"Gold_Left", "")];
    _myCoinLbl.text = [NSString stringWithFormat:@"%@",[USER_DEFAULT objectForKey:@"CurrentGolden"]];
    
    _currentSelected = 1;
//    [_tasksBtn setTitle:@"任务" forState:UIControlStateNormal];
//    _tasksBtn.hidden = YES;
//    [_goldenBtn setTitle:@"金币" forState:UIControlStateNormal];
    

    [self setupTable];
    [self setupBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePaidForGoldNotification:) name:kCPPaidForGoldsNotificatioin object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHudView:) name:kInAppPurchaseEvent object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark handle notification

- (void)handlePaidForGoldNotification:(NSNotification *)notification
{
    if (notification && [notification.object isKindOfClass:[SKPaymentTransaction class]]) {
        SKPaymentTransaction* transaction = (SKPaymentTransaction*)notification.object;
        
        //处理订购完毕的信息
        NSString *productID = transaction.payment.productIdentifier;
        NSArray *IDs = CP_Golden_ProductIDs;
        int index = [IDs indexOfObject:productID];
        
        NSArray *values = CP_Golden_values;
        int value = [[values objectAtIndex:index] intValue];
        
        int currentGold = [Utils currentCoins];
        currentGold+= value;
        
        [Utils setCurrentCoins:currentGold];
        
        
        //更新UI
        _myCoinLbl.text = [NSString stringWithFormat:@"%d",currentGold];
        
        //flurry
        NSString* price = CP_Golden_price(index);
        [Flurry logEvent:kCompleteIAPTransaction withParameters:[NSDictionary dictionaryWithObjectsAndKeys:price,productID, nil]];
    }
}

- (void)handleHudView:(NSNotification *)notification
{
    if (notification.object && [notification.object isKindOfClass:[NSString class]]) {
        NSString* event = (NSString*)notification.object;
        if([event isEqualToString:kCompleteIAPTransaction] || [event isEqualToString:kFailedIAPTransaction])//hide
        {
            [CPPropStoreViewController hideHudView:self.view];
        }
        else
        {
            [CPPropStoreViewController showHudView:self.view];
        }
    }
}

#pragma mark actions

- (IBAction)closeClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (IBAction)openGoldenBox:(id)sender
{
    if (_currentSelected == 2) {
        _currentSelected = 1;
        [self setupBtn];
        [self setupTable];

    }
}

- (IBAction)openTasksBox:(id)sender
{
    if (_currentSelected ==1) {
        _currentSelected = 2;
        [self setupBtn];
        [self setupTable];
    }
    
}


/// 购买 金币
- (void)buyGoldClicked:(id)sender{
    
//    UIButton *btn = (UIButton *)sender;
//    NSInteger tag = btn.tag;
    
    

}


#pragma table view data sources

- (UIView *)cellForRow:(NSInteger)row{

    
    CGRect rect = CGRectMake(0, row*CP_Height_Of_Row, CP_Width_Of_Cell,  CP_Height_Of_Row);
    UIView *cell = [[UIView alloc] initWithFrame:rect];
    
    UIImageView *coinIV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    coinIV.tag = row*10 + CP_Cell_Tag_Offset + 1;
    coinIV.image = [UIImage imageNamed:@"shop_board_down.png"];
    [cell addSubview:coinIV];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 200, 30)];
    lbl.tag = row*10 + CP_Cell_Tag_Offset + 2;
    [cell addSubview:lbl];
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(230, 10, 64, 40)];
    btn.tag = row*10 + CP_Cell_Tag_Offset + 3;
    [btn setBackgroundImage:[UIImage imageNamed:@"shop_buy_bg.png"] forState:UIControlStateNormal];
    //[btn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buyGoldClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btn];
    
    
    UIImageView * IV = [[UIImageView alloc] initWithFrame:CGRectMake(0,44,280,44)];
    IV.image = [UIImage imageNamed:@"guestcoin.png"];
    [cell addSubview:IV];
    
    
    return cell;

}


- (void)setupTable{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    MyTableViewController *tableVC = [sb instantiateViewControllerWithIdentifier:@"MyTableViewController"];
    tableVC.dataSource = _currentSelected==1?_dataSourceOfGold:_dataSourceOfTask;
    
    [self addChildViewController:tableVC];
    [tableVC.view setFrame:[_tableView bounds]];
    [_tableView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_tableView addSubview:[tableVC view]];

//    for (int i=0;i<[_dataSource count] ; i++) {
//        
//        UIView *cell = [self cellForRow:i];
//        
//        NSDictionary *dic = _dataSource[i];
//        
//        UILabel *titleLbl = (UILabel *)[cell viewWithTag:i*10 + CP_Cell_Tag_Offset + 2];
//        titleLbl.text = dic[CP_Value_Key];
//        
//        UIButton *priceBtn = (UIButton *)[cell viewWithTag:i*10 + CP_Cell_Tag_Offset + 3];
//        [priceBtn setTitle:[NSString stringWithFormat:@"￥%@",dic[CP_Price_Key]] forState:UIControlStateNormal];
//        
//
//        [_tableView addSubview:cell];
//        
//    }

}


- (void)setupBtn{


    
    if (_currentSelected == 1) {
        [_goldenBtn setBackgroundImage:[UIImage imageNamed:Shop_Button_Open_PNG] forState:UIControlStateNormal];
        [_tasksBtn setBackgroundImage:[UIImage imageNamed:Shop_Button_Close_PNG] forState:UIControlStateNormal];
    }else if(_currentSelected == 2){
    
        [_goldenBtn setBackgroundImage:[UIImage imageNamed:Shop_Button_Close_PNG] forState:UIControlStateNormal];
        [_tasksBtn setBackgroundImage:[UIImage imageNamed:Shop_Button_Open_PNG] forState:UIControlStateNormal];
    
    }
    
    

}



#pragma hud view
+(void)showHudView:(UIView*)containerView
{
    [MBProgressHUD showHUDAddedTo:containerView animated:YES];
}
+(void)hideHudView:(UIView*)containerView
{
    [MBProgressHUD hideHUDForView:containerView animated:YES];
}


@end
