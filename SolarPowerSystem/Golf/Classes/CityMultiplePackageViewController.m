//
//  CityMultiplePackageViewController.m
//  Golf
//
//  Created by user on 12-12-13.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "CityMultiplePackageViewController.h"
#import "GolfService.h"
#import "UIImageView+WebCache.h"
#import "PackageCell.h"
#import "YGPackageDetailViewCtrl.h"

@interface CityMultiplePackageViewController ()

@end

@implementation CityMultiplePackageViewController
@synthesize clubId = _clubId;
@synthesize multipleList = _multipleList;

- (void)loadView{
    [super loadView];
    
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fontSize = 15;
    [_tableView reloadData];
}

# pragma tableview
# pragma tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _multipleList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellInditifier = @"PackageCell";
    PackageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellInditifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PackageCell" owner:self options:nil] lastObject];
    }
    
    PackageModel *model = [_multipleList objectAtIndex:[indexPath row]];
    cell.lblPackageName.numberOfLines = 0;
    
    [cell.logoView sd_setImageWithURL:[NSURL URLWithString:model.packageLogo] placeholderImage:self.defaultImage];
    
    cell.lblPackageName.text = model.packageName;
    cell.lblPrice.text = [NSString stringWithFormat:@"￥%d",model.currentPrice];
    if (model.agentId > 0) {
        cell.lblClubName.text = model.agentName;
    }
    else{
        cell.lblClubName.text = @"球会官方直销";
    }
    if (model.giveYunbi > 0) {
        cell.giveYunbiLabel.hidden = NO;
        cell.giveYunbiLabel.text = [NSString stringWithFormat:@"返%d", model.giveYunbi];
    } else {
        cell.giveYunbiLabel.hidden = YES;
    }
    [self getSizeWithIndexPath:indexPath text1:cell.lblPackageName.text text2:cell.lblPrice.text cell:cell];
    return cell;
}

- (void)getSizeWithIndexPath:(NSIndexPath *)indexPath text1:(NSString *)text1 text2:(NSString *)text2 cell:(PackageCell *)cell{
    CGSize size = [Utilities getSize:text1 withFont:[UIFont systemFontOfSize:15] withWidth:216];
    CGRect rect;
    int top1;
    int top2;
    if (size.height > 30) {
        top1 = 9;
        top2 = 47;
    }
    else{
        top1 = 16;
        top2 = 39;
    }
    rect = CGRectMake(102, top1, 216, size.height);
    cell.lblPackageName.frame = rect;
    
    size = [Utilities getSize:text2 withFont:[UIFont systemFontOfSize:18] withWidth:Device_Width];
   // rect = cell.lblPrice.frame;
    
    rect = CGRectMake(102, top2, size.width, 20);
    cell.lblPrice.frame = rect;
    
    //rect = cell.lblLabel.frame;
    rect = CGRectMake(102 + size.width+2, top2, 20, 20);
    cell.lblLabel.frame = rect;
    
    CGSize size1 = [cell.giveYunbiLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:11]}];
    cell.giveYunbiLabel.frame = CGRectMake(102 + size.width+2 + 20, top2 + 4, size1.width, size1.height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSelectorInBackground:@selector(getPackageDetail:) withObject:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)getPackageDetail:(id)sender{
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    PackageModel * model = [_multipleList objectAtIndex:indexPath.row];
    [[ServiceManager serviceManagerWithDelegate:self] getPackageDetail:model.packageId];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array&&array.count>0) {
        if (Equal(flag, @"package_detail")) {
            PackageDetailModel *model = [array objectAtIndex:0];
            YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
            vc.packageId = model.packageId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
@end
