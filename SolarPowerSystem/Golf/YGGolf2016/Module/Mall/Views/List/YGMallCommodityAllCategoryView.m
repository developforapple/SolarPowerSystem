

#import "YGMallCommodityAllCategoryView.h"

@interface YGMallCommodityAllCategoryView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSArray *itemsList;
@end

@implementation YGMallCommodityAllCategoryView

+ (YGMallCommodityAllCategoryView *)moreViewWithFrame:(CGRect)frame items:(NSArray*)itemsArray delegate:(id<YGMallCommodityAllCategoryViewDelegate>)aDelegate{
    YGMallCommodityAllCategoryView *moreView = [[self alloc] initWithFrame:frame items:itemsArray delegate:aDelegate];
    return moreView;
}

- (id)initWithFrame:(CGRect)frame items:(NSArray*)itemsArray delegate:(id<YGMallCommodityAllCategoryViewDelegate>)aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {

        self.itemsList = itemsArray;
        
        self.delegate = aDelegate;
        
        self.backgroundColor = [UIColor clearColor];
        
        UIControl *coverView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        coverView.backgroundColor = [UIColor blackColor];
        coverView.alpha = 0.2;
        [coverView addTarget:self action:@selector(coverAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:coverView];
        
        if (Device_SysVersion<7.0) {
            self.moreTableView = [[UITableView alloc] initWithFrame:CGRectMake(frame.size.width, 0, 100, frame.size.height) style:UITableViewStylePlain];
        }else{
            self.moreTableView = [[UITableView alloc] initWithFrame:CGRectMake(frame.size.width, 0, 100, frame.size.height) style:UITableViewStyleGrouped];
        }
        self.moreTableView.delegate = self;
        self.moreTableView.dataSource = self;
        self.moreTableView.backgroundColor = [Utilities R:248 G:248 B:248];
        [self addSubview:self.moreTableView];
        
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.moreTableView.frame = CGRectMake(frame.size.width-100, 0, 100, frame.size.height);
        } completion:nil];
    }
    return self;
}

- (void)coverAction:(UIControl*)control{
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.moreTableView.frame = CGRectMake(self.frame.size.width, 0, 100, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self.moreTableView removeFromSuperview];
        self.moreTableView = nil;
        [self removeFromSuperview];
    }];
}

- (void)setSelectIndex:(NSInteger)selectIndex{
    _selectIndex = selectIndex;
    [self.moreTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemsList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [Utilities R:248 G:248 B:248];
    }
    if (indexPath.row == self.selectIndex) {
        cell.textLabel.textColor = [Utilities R:6 G:156 B:216];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    if (indexPath.row < self.itemsList.count && self.itemsList.count > 0) {
        cell.textLabel.text = [self.itemsList objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != self.selectIndex) {
        self.selectIndex = indexPath.row;
        [tableView reloadData];

        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.moreTableView.frame = CGRectMake(self.frame.size.width, 0, 100, self.frame.size.height);
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(ccMoreView:selectIndex:)]) {
                [self.delegate ccMoreView:self selectIndex:self.selectIndex];
            }
            
            [self.moreTableView removeFromSuperview];
            self.moreTableView = nil;
            [self removeFromSuperview];
        }];
    }
}

- (void)close{
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.moreTableView.frame = CGRectMake(self.frame.size.width, 0, 100, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self.moreTableView removeFromSuperview];
        self.moreTableView = nil;
        [self removeFromSuperview];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Device_SysVersion<7.0 ? 0 : 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return Device_SysVersion<7.0 ? 0 : 0.1;
}

@end
