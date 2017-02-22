

#import "YGBindingListViewCtrl.h"
#import "YGBindingListWeChatCell.h"
#import "YGBindingListPhoneCell.h"

@interface YGBindingListViewCtrl ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,copy) NSString *phoneString;
@end

@implementation YGBindingListViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.phoneString = [LoginManager sharedManager].session.mobilePhone;
}

#pragma mark UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        YGBindingListWeChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGBindingListWeChatCell" forIndexPath:indexPath];
        cell.viewController = self;
        if ([cell respondsToSelector:@selector(preservesSuperviewLayoutMargins)]) {
            cell.preservesSuperviewLayoutMargins = NO;
        }
        if ([cell respondsToSelector:@selector(layoutMargins)]) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        cell.separatorInset = UIEdgeInsetsZero;
        return cell;
    }else{
        YGBindingListPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGBindingListPhoneCell" forIndexPath:indexPath];
        cell.controller = self;
        cell.mobil = _phoneString;
        if ([cell respondsToSelector:@selector(preservesSuperviewLayoutMargins)]) {
            cell.preservesSuperviewLayoutMargins = NO;
        }
        if ([cell respondsToSelector:@selector(layoutMargins)]) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        cell.separatorInset = UIEdgeInsetsZero;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
