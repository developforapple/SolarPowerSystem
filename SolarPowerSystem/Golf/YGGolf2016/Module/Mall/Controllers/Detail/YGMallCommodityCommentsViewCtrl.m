

#import "YGMallCommodityCommentsViewCtrl.h"
#import "YGMallCommodityCommentCell.h"
#import <UICountingLabel/UICountingLabel.h>
#import "YGUserRemarkCacheHelper.h"

@interface YGMallCommodityCommentsViewCtrl ()<UITableViewDelegate,UITableViewDataSource>{
    int _pageNo;
    NSInteger _currentLevel;
    int _goodTotal;
    int _midTotal;
    int _badTotal;
}

@property (weak, nonatomic) IBOutlet UICountingLabel *bigGoodCommentLabel;
@property (weak, nonatomic) IBOutlet UIButton *goodCommentBtn;
@property (weak, nonatomic) IBOutlet UIButton *midCommentBtn;
@property (weak, nonatomic) IBOutlet UIButton *badCommentBtn;
@property (weak, nonatomic) IBOutlet UIView *buttonView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *noCommentLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIProgressView *goodProgress;
@property (weak, nonatomic) IBOutlet UILabel *goodRankLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *midProgress;
@property (weak, nonatomic) IBOutlet UILabel *midRankLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *badProgress;
@property (weak, nonatomic) IBOutlet UILabel *badRankLabel;

@property (nonatomic,strong) NSMutableArray *commentList;

@end

@implementation YGMallCommodityCommentsViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    YGPostBuriedPoint(YGMallPointCommodityReviewList);
    
    _pageNo = 0;
    _goodTotal = 0;
    _midTotal = 0;
    _badTotal = 0;
    _currentLevel = 1;
    
    self.commentList = [NSMutableArray array];
    
    self.tableView.estimatedRowHeight = 120.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.contentInset = UIEdgeInsetsMake(155, 0, 0, 0);
    self.tableView.hidden = YES;
    
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        if (type == YGRefreshTypeHeader) {
            _pageNo = 0;
        }
        [self getDataFromServer];
    }];
    
    [self getDataFromServer];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
}

- (void)getDataFromServer{
    _pageNo ++;
    [[ServiceManager serviceManagerWithDelegate:self] getCommodityCommentList:self.commodityId level:[@(_currentLevel) intValue] pageNo:_pageNo];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array&&array.count > 0) {
        if (Equal(flag, @"commodity_comment_list")) {
            _goodTotal = 0;
            _midTotal = 0;
            _badTotal = 0;
            NSDictionary *dic = [array objectAtIndex:0];
            if (dic) {
                NSArray *totalList = [dic objectForKey:@"total_list"];
                if (totalList) {
                    for (NSDictionary *dic in totalList) {
                        int commentLevel = [[dic objectForKey:@"comment_level"] intValue];
                        int commentCount = [[dic objectForKey:@"comment_count"] intValue];
                        if (commentLevel == 1) {
                            _goodTotal = commentCount;
                        }else if (commentLevel == 2){
                            _midTotal = commentCount;
                        }else{
                            _badTotal = commentCount;
                        }
                    }
                }
                
                NSArray *dataList = [dic objectForKey:@"data_list"];
                if (_pageNo == 1) {
                    [self.commentList removeAllObjects];
                }
                
                [self.tableView.mj_header endRefreshing];
                if (dataList && dataList.count > 0) {
                    for (id obj in dataList) {
                        CommodityCommentModel *model = [[CommodityCommentModel alloc] initWithDic:obj];
                        NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                        if ([remarkName isNotBlank]) {
                            model.displayName = remarkName;
                        }
                        [self.commentList addObject:model];
                    }
                    [self.tableView.mj_footer resetNoMoreData];
                }else{
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self handleNibData];
            });
        }
    }
}


- (IBAction)buttonSelectedAction:(UIButton*)button{
    _currentLevel = button.tag;
    
    for (UIView *view in self.buttonView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)view;
            [btn setBackgroundImage:[UIImage imageNamed:@"sb_10.png"] forState:UIControlStateNormal];
            [btn setTitleColor:[Utilities R:138 G:138 B:138] forState:UIControlStateNormal];
        }
    }
    
    [button setBackgroundImage:[UIImage imageNamed:@"sb_11.png"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _pageNo = 0;
    
    [self getDataFromServer];
}

- (void)handleNibData{
    [self.goodCommentBtn setTitle:[NSString stringWithFormat:@"好评 %d",_goodTotal] forState:UIControlStateNormal];
    [self.midCommentBtn setTitle:[NSString stringWithFormat:@"中评 %d",_midTotal] forState:UIControlStateNormal];
    [self.badCommentBtn setTitle:[NSString stringWithFormat:@"差评 %d",_badTotal] forState:UIControlStateNormal];
    
    int total = _goodTotal + _midTotal + _badTotal;
    
    if (total == 0) {
        self.buttonView.hidden = YES;
        self.tableView.hidden = YES;
        self.noCommentLabel.hidden = NO;
        
        self.goodProgress.progress = 0;
        self.midProgress.progress = 0;
        self.badProgress.progress = 0;
        self.goodRankLabel.text = @"0%";
        self.midRankLabel.text = @"0%";
        self.badRankLabel.text = @"0%";
        
    }else{
        self.buttonView.hidden = NO;
        self.tableView.hidden = NO;
        self.noCommentLabel.hidden = YES;
        
        float goodRate = _goodTotal/(float)total;
        float midRate = _midTotal/(float)total;
        float badRate = _badTotal/(float)total;
        
        [self.goodProgress setProgress:goodRate animated:YES];
        [self.midProgress setProgress:midRate animated:YES];
        [self.badProgress setProgress:badRate animated:YES];
        NSString *gr = [NSString stringWithFormat:@"%d%%",(int)roundf(goodRate*100)];
        
        self.goodRankLabel.text = gr;
//        self.bigGoodCommentLabel.text = gr;
        self.midRankLabel.text = [NSString stringWithFormat:@"%d%%",(int)roundf(midRate*100)];
        self.badRankLabel.text = [NSString stringWithFormat:@"%d%%",(int)roundf(badRate*100)];
        
        self.bigGoodCommentLabel.method = UILabelCountingMethodEaseInOut;
        self.bigGoodCommentLabel.animationDuration = .8f;
        self.bigGoodCommentLabel.format = @"%02d%%";
        [self.bigGoodCommentLabel countFrom:0 to:(int)roundf(goodRate*100)];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YGMallCommodityCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGMallCommodityCommentCell" forIndexPath:indexPath];
    CommodityCommentModel *model = [self.commentList objectAtIndex:indexPath.row];
    
    cell.memberId = model.memberId;
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];
    cell.memberLevelImg.image = [Utilities imageOfUserType:model.memberLevel];
    cell.memberNameLabel.text = model.displayName;
    cell.commentDateLabel.text = [Utilities getDateStringFromString:model.commentDate WithAllFormatter:@"yyyy-MM-dd"];
    [cell cellAutoLayoutHeight:model.commentContent];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}


@end
