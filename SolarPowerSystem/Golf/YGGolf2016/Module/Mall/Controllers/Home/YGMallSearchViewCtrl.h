

#import <UIKit/UIKit.h>
#import "BaseNavController.h"

@interface YGMallSearchViewCtrl : BaseNavController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>{
    UISearchBar          *_searchBar;
    UITableView    *_tableView;
}

@property (nonatomic) int searchType; //只支持4！！！！

- (void)refreshList;

@end
