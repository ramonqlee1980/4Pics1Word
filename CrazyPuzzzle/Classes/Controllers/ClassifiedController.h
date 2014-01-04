//
//  ClassifedController.h
//  4Imgs1Word
//
//  Created by Ramonqlee on 1/3/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassifiedController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UILabel* currentCoinsLabel;
    UITableView* currentTableView;
}

@property(nonatomic,retain)IBOutlet UILabel* currentCoinsLabel;
@property(nonatomic,retain)IBOutlet UITableView* currentTableView;

-(IBAction)back:(id)sender;
- (IBAction)shopButtonClicked:(id)sender;
@end
