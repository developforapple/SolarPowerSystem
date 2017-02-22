

#import "YGMallCommoditySortView.h"

static YGMallCommoditySortView *_filterInstance = nil;

@interface YGMallCommoditySortView ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic,strong) NSArray *titleArray;
@property (nonatomic,strong) NSArray *iconArray;
@property (nonatomic) NSInteger selectIndex;
@property (nonatomic,assign) NSInteger redIndex;

@end

@implementation YGMallCommoditySortView

+ (YGMallCommoditySortView*)shareSortView:(CGRect)aFrame delegate:(id<YGMallCommoditySortViewDelegate>)aDelegate titles:(NSArray*)titles icons:(NSArray*)icons selectIndex:(NSInteger)aSelectIndex{
    if (_filterInstance) {
        _filterInstance = nil;
    }
    _filterInstance = [[self alloc] initWithFrame:aFrame delegate:aDelegate titles:titles icons:icons selectIndex:aSelectIndex];
    
    return _filterInstance;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<YGMallCommoditySortViewDelegate>)aDelegate titles:(NSArray*)titles icons:(NSArray*)icons selectIndex:(NSInteger)aSelectIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.selectIndex = aSelectIndex;
        self.delegate = aDelegate;
        
        self.titleArray = titles;
        self.iconArray = icons;
        
        _redIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RedDocIndex"] integerValue];
        
        CGFloat or_x = 18;
        if (frame.origin.x>(Device_Width-320)/2. + 130) {
            or_x = 116;
        }else if (frame.origin.x>(Device_Width-320)/2.+80){
            or_x = (frame.size.width-5)/2;
        }
        
        UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(or_x, 0, 11, 5)];
        topImageView.image = [UIImage imageNamed:@"sb_17.png"];
        topImageView.alpha = 0.98;
        [self addSubview:topImageView];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 5, frame.size.width, frame.size.height-5) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.rowHeight = 40.f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.alpha = 0.90;
        [self addSubview:_tableView];
        
        [Utilities drawView:_tableView radius:4 borderColor:[Utilities R:41 G:45 B:51]];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = [Utilities R:240 G:251 B:255];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row];
    if (self.iconArray.count > 0) {
        cell.imageView.image = [self.iconArray objectAtIndex:indexPath.row];
    }
    
    UIView *cellBgView = [[UIView alloc] initWithFrame:cell.frame];
    cellBgView.backgroundColor = [Utilities R:41 G:45 B:51];
    cellBgView.alpha = 0.9;
    cell.backgroundView = cellBgView;
    
    if (self.selectIndex == indexPath.row) {
        cellBgView.backgroundColor = [UIColor blackColor];
    }
    
    if (_redIndex > 0 && indexPath.row == _redIndex-1 && _fromTopic) {
        UIView *red = [[UIView alloc] initWithFrame:CGRectMake(100, 16, 8, 8)];
        red.backgroundColor = [UIColor redColor];
        [Utilities drawView:red radius:4 borderColor:[UIColor redColor]];
        [cell addSubview:red];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != self.selectIndex || (indexPath.row == self.selectIndex &&_redIndex > 0)) {
        self.selectIndex = indexPath.row;
        if (_fromTopic) {
            _redIndex = 0;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RedDocIndex"];
            [GolfAppDelegate shareAppDelegate].systemParamInfo.topicMemberFollow = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PushRedDocIndex" object:nil];
        }
        
        [tableView reloadData];
        if ([self.delegate respondsToSelector:@selector(sortView:tapIndex:)]) {
            [self.delegate sortView:self tapIndex:indexPath.row];
        }
    }
}

- (void)showInView:(UIView *)view coverFrame:(CGRect)frame
{
    UIControl *cover = [[UIControl alloc] initWithFrame:frame];
    [cover addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [cover addSubview:self];
    [view addSubview:cover];
}

- (void)dismiss:(UIControl *)ctrl
{
    [ctrl removeAllTargets];
    [ctrl removeFromSuperview];
}

@end

