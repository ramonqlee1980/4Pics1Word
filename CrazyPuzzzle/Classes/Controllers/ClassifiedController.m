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

static NSString *CellIdentifier = @"ClassfiedCellIdentifier";
static NSString *CellNIBName = @"ClassifiedCell";

@interface ClassifiedController ()<TableViewCellDelegate>

@end

@implementation ClassifiedController

@synthesize currentCoinsLabel;
@synthesize currentTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassifiedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.delegate = self;

    // Configure the cell...
    cell.topLabel.text = [NSString stringWithFormat:@"label %d",indexPath.row];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

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
    if ([Utils currentCoins]<CP_Enable_Grade_Cost) {
        //积分不足
    }
    else
    {
        //扣减积分，并开启此关
    }
}
@end
