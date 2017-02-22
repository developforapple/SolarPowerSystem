//
//  YGMallBrandListViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/10/18.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallBrandListViewCtrl.h"
#import "YGMallBrandCell.h"

@interface YGMallBrandListViewCtrl ()
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableDictionary *brandData;
@property (nonatomic,strong) NSMutableArray *keyList;
@end

@implementation YGMallBrandListViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    YGPostBuriedPoint(YGMallPointBrandList);
    self.navigationItem.title = @"品牌列表";
    self.brandData = [NSMutableDictionary dictionary];
    self.keyList = [NSMutableArray array];
    [self getBrandList];
}

// 获取品牌列表
- (void)getBrandList{
    [[ServiceManager serviceManagerWithDelegate:self] commodityBrandList];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    NSMutableArray *tempHot = [NSMutableArray array];
    NSMutableArray *tempChar = [NSMutableArray array];
    NSMutableArray *tempOther = [NSMutableArray array];
    if (array.count>0) {
        BOOL over = NO;
        for (YGMallBrandModel *brand in array) {
            if (brand.display_order > 0) {// hot
                [tempHot addObject:brand];
            }else{
                over = YES;
            }
            if (over) {
                break;
            }
        }
        
        NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(YGMallBrandModel *brand1, YGMallBrandModel *brand2) {
            return [brand1.brand_name compare:brand2.brand_name options:NSCaseInsensitiveSearch];
        }];
        NSString *lastString = @"";
        NSString *charSttring = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        for (YGMallBrandModel *brand in sortArray) {
            NSString *firstChar = [self getFirstChar:brand.brand_name];
            NSRange range = [charSttring rangeOfString:firstChar];
            if (range.location != NSNotFound) {// 有就为字母
                if (!Equal(firstChar, lastString) && lastString.length>0) { //存储上个字母的数据
                    NSArray *arr = [NSArray arrayWithArray:tempChar];
                    [self.brandData setObject:arr forKey:lastString];
                    [tempChar removeAllObjects];
                }
                [tempChar addObject:brand];
                lastString = firstChar;
            }else{ // 没有就是汉字
                [tempOther addObject:brand];
            }
        }
        
        if (lastString.length>0 && tempChar.count>0) {
            [self.brandData setObject:tempChar forKey:lastString];
        }
        
        if (tempOther.count>0) {
            [self.brandData setObject:tempOther forKey:@"其它"];
        }
        
        NSArray *keyArray = [[self.brandData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        [self.keyList addObjectsFromArray:keyArray];
        if (tempHot.count>0) {
            [self.brandData setObject:tempHot forKey:@"热"];
            [self.keyList insertObject:@"热" atIndex:0];
        }
        [_tableView reloadData];
    }
}

- (NSString*)getFirstChar:(NSString*)string{
    if (!string||string.length == 0) {
        return @"";
    }
    return [[string substringWithRange:NSMakeRange(0, 1)] uppercaseString];
}

#pragma mark - UITableView dataSource && delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_brandData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = _brandData[_keyList[section]];
    return arr.count%3==0?arr.count/3:arr.count/3+1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = indexPath.row==0?kYGMallBrandCell:kYGMallBrandCell1;
    YGMallBrandCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    NSArray *arr = _brandData[_keyList[indexPath.section]];
    NSArray *brands = [arr subarrayWithRange:NSMakeRange(indexPath.row*3, (indexPath.row+1)*3>arr.count?arr.count%3:3)];
    [cell configureWithBrands:brands];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (IS_4_7_INCH_SCREEN) {
        height = indexPath.row == 0 ? 50+40*375/320. : 35+40*375/320.;
    }else if (IS_5_5_INCH_SCREEN){
        height = indexPath.row == 0 ? 50+40*414/320. : 35+40*414/320.;
    }else{
        height = indexPath.row == 0 ? 90 : 75;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor colorWithHexString:@"f1f0f6"];
    ((UITableViewHeaderFooterView *)view).textLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    ((UITableViewHeaderFooterView *)view).textLabel.font = [UIFont systemFontOfSize:12];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.keyList;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = _keyList[section];
    return Equal(title, @"热")? @"热门品牌":title;
}

@end
