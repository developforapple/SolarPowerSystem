//
//  MyScheduleTableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/6/4.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "MyScheduleTableViewController.h"
#import "SubscribeTimeTableViewController.h"

@interface MyScheduleTableViewController ()

@end

@implementation MyScheduleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
   
    UIButton *navLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    navLeftButton.frame = CGRectMake(0, 0, 50, 30);
    UIImage *img = [UIImage imageNamed:@"back_icon.png"];
    [navLeftButton setBackgroundImage:img forState:UIControlStateNormal];
    [navLeftButton setBackgroundImage:img forState:UIControlStateHighlighted];
    [navLeftButton addTarget:self action:@selector(doLeftNavAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
}


- (void)doLeftNavAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnPressed:(id)sender {
    if (_timeSet && _timeSet.count > 0) {
        self.title = @"";
        [self performSegueWithIdentifier:@"SubscribeTimeTableViewController" sender:self withBlock:^(id sender, id destinationVC) {
            SubscribeTimeTableViewController *vc = (SubscribeTimeTableViewController *)destinationVC;
            vc.blockReturnRoot = self.blockReturn;
            vc.timeSet = _timeSet;
            vc.coachId = _coachId;
        }];
    }
}

@end
