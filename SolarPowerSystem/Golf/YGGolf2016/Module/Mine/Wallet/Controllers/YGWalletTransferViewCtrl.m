//
//  YGWalletTransferViewCtrl.m
//  Golf
//
//  Created by zhengxi on 15/12/14.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGWalletTransferViewCtrl.h"
#import <AddressBook/AddressBook.h>
#import "PersonInAddressList.h"
#import "PersonGolfInAddressBookFriendsTableViewCell.h"
#import "YGWalletTransferUserCell.h"
#import "YGWalletTransferConfirmViewCtrl.h"
#import "SelectParnerTableViewCell.h"
#import "BeginScoringViewController.h"
#import "YGUserRemarkCacheHelper.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface YGWalletTransferViewCtrl ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) ABAddressBookRef addressBook;
@property (strong, nonatomic) NSArray *addressBookArray;
@property (strong, nonatomic) NSMutableArray *personAddressArray;
@property (strong, nonatomic) NSMutableArray *personGolfArray;
@property (strong, nonatomic) NSMutableArray *resultsFromFriendsArray;
@property (strong, nonatomic) NSMutableArray *resultsFromAddressArray;
@property (strong, nonatomic) NSMutableString *phoneNumbersString;
@property (nonatomic,strong) NSMutableArray *allFriendsList;
@property (strong, nonatomic) NSArray *titleForHeaderArray;
@property (strong, nonatomic) NSMutableArray *resultsArray;
@property (nonatomic) int page;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property BOOL hasMore;
@property (nonatomic) int pageSize;
@property BOOL searchHasMore;
@property (nonatomic) NSInteger searchPageNo;
@property (nonatomic) NSInteger searchPageSize;
@property (nonatomic) NSInteger searchTag;
@property (strong, nonatomic) NoResultView *noResultView;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@end

@implementation YGWalletTransferViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeTableView];
    [self initializeData];
    [GolfAppDelegate shareAppDelegate].currentController = self;
}

- (void)doRightNavAction {
    if (_addGolferBlock) {
        _addGolferBlock(_selectedArray);
    }
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *v in array){
        if ([v isMemberOfClass:[BeginScoringViewController class]]) {
            [self.navigationController popToViewController:v animated:YES];
        }
    }
}

- (void)initializeTableView {
    if (_isAddGolfer) {
        [self rightButtonAction:@"完成"];
        self.selectedArray = [_selectedCopyArray mutableCopy];
    }
    self.hasMore = YES;
    self.searchHasMore = YES;
    self.pageSize = 20;
    self.searchPageSize = 20;
    self.page = 0;
    self.searchPageNo = 0;
    self.titleForHeaderArray = @[@"通讯录好友", @"全部好友"];
    self.resultsArray = [NSMutableArray array];
    self.allFriendsList = [NSMutableArray array];
    self.resultsFromAddressArray = [NSMutableArray array];
    self.resultsFromFriendsArray = [NSMutableArray array];
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithHexString:@"#F0EFF5"];
    [_refreshControl addTarget:self action:@selector(initializeData) forControlEvents:(UIControlEventValueChanged)];
    [self.tableView addSubview:_refreshControl];
}

- (void)initializeData {
    if (!_isAddGolfer) {
        [self initAddressBook];
    }
    [self getFirstPage];
}

- (void)getFirstPage {
    _page = 1;
    [[ServiceManager serviceManagerWithDelegate:self] userFollowList:[[LoginManager sharedManager] getSessionId] followType:1 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude pageNo:_page pageSize:_pageSize];
}

- (void)getfollewedList {
    _page++;
    [[ServiceManager serviceManagerWithDelegate:self] userFollowList:[[LoginManager sharedManager] getSessionId] followType:1 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude pageNo:_page pageSize:_pageSize];
}

- (void)initAddressBook {
    self.addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                NSLog(@"not allow");
            } else {
                [self getList];
            }
        });
    });
}

- (void)getList {
    if (ABAddressBookGetPersonCount(_addressBook) == 0) {
        NSLog(@"count = 0");
    } else {
        self.addressBookArray = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(_addressBook));
    }
    self.personGolfArray = [NSMutableArray array];
    self.personAddressArray = [NSMutableArray array];
    self.phoneNumbersString = [NSMutableString string];
    for (int i = 0; i < _addressBookArray.count; i++) {
        ABRecordRef record = (__bridge ABRecordRef)(_addressBookArray[i]);
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(record, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phoneNumbers); k++)
        {
            CFStringRef personPhone = ABMultiValueCopyValueAtIndex(phoneNumbers, k);
            
            NSString *phoneStr = [Utilities formatPhoneNum:(__bridge NSString*)personPhone];
            
            if (phoneStr && phoneStr.length>10) {
                PersonInAddressList *person = [[PersonInAddressList alloc] init];
                person.mobilePhone = phoneStr;
                if ([Utilities phoneNumMatch:phoneStr] && ![phoneStr isEqual:[LoginManager sharedManager].session.mobilePhone])
                    [self.phoneNumbersString appendFormat:@"%@,",phoneStr];
                NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonFirstNameProperty));
                NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonLastNameProperty));
                
                if (firstName.length>0 && lastName.length>0) {
                    person.addressName = [NSString stringWithFormat:@"%@ %@",lastName,firstName];
                }else if (lastName.length>0){
                    person.addressName = [NSString stringWithFormat:@"%@",lastName];
                }else if (firstName.length){
                    person.addressName = [NSString stringWithFormat:@"%@",firstName];
                }
                [self.personAddressArray addObject:person];

                break;
            }
        }
    }
    
    if (_phoneNumbersString.length>0) {
        [[ServiceManager serviceManagerWithDelegate:self] userFindContracts:[[LoginManager sharedManager] getSessionId] phoneNum:_phoneNumbersString];
    } else {
        [_tableView reloadData];
    }
}


#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return nil;
    } else {
        return _titleForHeaderArray[section];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        if (_resultsArray.count > 0) {
            if (_resultsArray.count >= _searchPageSize) {
                return _resultsArray.count + 1;
            }
            return _resultsArray.count;
        } else {
            return 1;
        }
    } else {
        if (section == 0) {
            return _personGolfArray.count;
        } else {
            if (_allFriendsList.count >= _pageSize) {
                return _allFriendsList.count + 1;
            }
            return _allFriendsList.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        if (_resultsArray.count <= 0) {
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoResultsCellInAddressBookFriends"];
            return cell;
        }
        if (_isAddGolfer) {
            SelectParnerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectParnerTableViewCell"];
            Parner *parner = [self parnerFromePerson:_resultsArray[indexPath.row]];
            cell.model = parner;
            cell.isSelected = [self isSelectedArrayContains:parner];
            return cell;
        }
        if (_resultsArray.count == indexPath.row && indexPath.row >= _searchPageSize) {
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_searchHasMore ? @"LoadingCell" : @"EndMessageCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_searchHasMore ? @"LoadingCell" : @"EndMessageCell"];
            }
            return cell;
        }
        if ([_resultsArray[indexPath.row] isKindOfClass:[PersonInAddressList class]]) {
            PersonGolfInAddressBookFriendsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PersonGolfInAddressBookFriendsTableViewCell"];
            if (!cell) {
                cell = [[PersonGolfInAddressBookFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PersonGolfInAddressBookFriendsTableViewCell"];
            }
            cell.delegate = self;
            cell.isSearchResults = YES;
            cell.person = _resultsArray[indexPath.row];
            return cell;
        } else {
            YGWalletTransferUserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"YGWalletTransferUserCell"];
            if (!cell) {
                cell = [[YGWalletTransferUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YGWalletTransferUserCell"];
            }
            cell.isSearchResults = YES;
            cell.delegate = self;
            cell.model = _resultsArray[indexPath.row];
            return cell;
        }
    } else {
        if (indexPath.section == 0) {
            PersonGolfInAddressBookFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonGolfInAddressBookFriendsTableViewCell" forIndexPath:indexPath];
            cell.person = _personGolfArray[indexPath.row];
            return cell;
        } else {
            if (_allFriendsList.count == indexPath.row && indexPath.row >= _pageSize) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_hasMore ? @"LoadingCell" : @"EndMessageCell" forIndexPath:indexPath];
                return cell;
            }
            if (_isAddGolfer) {
                SelectParnerTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SelectParnerTableViewCell"];
                Parner *parner = [self parnerFromePerson:_allFriendsList[indexPath.row]];
                cell.model = parner;
                cell.isSelected = [self isSelectedArrayContains:parner];
                return cell;
            }
            YGWalletTransferUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGWalletTransferUserCell" forIndexPath:indexPath];
            cell.isSearchResults = NO;
            cell.delegate = self;
            cell.model = _allFriendsList[indexPath.row];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        return 0;
    } else {
        if (_isAddGolfer) {
            return 0;
        }
        if (section == 0) {
            if (_personGolfArray.count > 0) {
                return 28;
            } else {
                return 0;
            }
        } else {
            if (_allFriendsList.count > 0) {
                return 28;
            } else {
                return 0;
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor colorWithHexString:@"#F0EFF5"];
    ((UITableViewHeaderFooterView *)view).textLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    ((UITableViewHeaderFooterView *)view).textLabel.font = [UIFont systemFontOfSize:12];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_isAddGolfer) {//添加打球队友
        SelectParnerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.isSelected) {
            [self selectArrayRemoveParner:cell.model];
        } else {
            if (_selectedArray.count >= 3) {
                [SVProgressHUD showInfoWithStatus:@"最多选择三位球友"];
                return;
            }
            [self.selectedArray addObject:cell.model];
        }
        if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
        [_tableView reloadData];
        return;
    }
    
    YGWalletTransferConfirmViewCtrl *transferConfirmedVC = [YGWalletTransferConfirmViewCtrl instanceFromStoryboard];
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        if ([_resultsArray[indexPath.row] isKindOfClass:[PersonInAddressList class]]) {
            transferConfirmedVC.person = _resultsArray[indexPath.row];
        } else {
            transferConfirmedVC.model = _resultsArray[indexPath.row];
        }

    } else {
        if (indexPath.section == 0) {
            transferConfirmedVC.person = _personGolfArray[indexPath.row];
        } else {
            transferConfirmedVC.model = _allFriendsList[indexPath.row];
        }
    }

    [self pushViewController:transferConfirmedVC title:@"确认转账" hide:YES];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        if (_searchHasMore && indexPath.row == _resultsArray.count && indexPath.row >= _searchPageSize) {
            [self loadSearchData];
        }
    } else {
        if (_hasMore && indexPath.section == 1 && indexPath.row == _allFriendsList.count && indexPath.row >= _pageSize) {
            [self getfollewedList];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

- (BOOL)isSelectedArrayContains:(Parner *)parner {
    for (Parner *p in _selectedArray) {
        if ([p.mobilePhone isEqualToString:parner.mobilePhone]) {
            return YES;
        }
    }
    return NO;
}

- (Parner *)parnerFromePerson:(PersonInAddressList *)model {
    Parner *parner = [Parner new];
    parner.memberId = model.memberId;
    parner.headurl = model.headImage;
    parner.mobilePhone = model.mobilePhone;
    parner.nick = model.displayName;
    return parner;
}

- (void)selectArrayRemoveParner:(Parner *)parner {
    int i = 0;
    for (Parner *p in _selectedArray){
        if ([p.mobilePhone isEqualToString:parner.mobilePhone]) {
            break;
        }
        i++;
    }
    if (i < _selectedArray.count) {
        [_selectedArray removeObjectAtIndex:i];
    }
}
#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    self.searchDisplayController.searchBar.placeholder = _isAddGolfer ? @"搜索昵称/手机号码" : @"搜索姓名/昵称/手机号码";
    self.searchTag = 1;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    self.searchDisplayController.searchBar.placeholder = @"搜索";
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    self.searchTag = 1;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    if (_searchTag == 1) {//lyf 注 UISearchDisplayController本身有bug
        _searchTag = 0;
        [self.searchDisplayController.searchResultsTableView setContentInset:UIEdgeInsetsZero];
        [self.searchDisplayController.searchResultsTableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    }
    
    NSString *string = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (string.length <= 0) {
        return NO;
    }
    [self filterContentForSearchText:string scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles]
      objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    if (_searchTag == 1) {//lyf 注 UISearchDisplayController本身有bug
        _searchTag = 0;
        [self.searchDisplayController.searchResultsTableView setContentInset:UIEdgeInsetsZero];
        [self.searchDisplayController.searchResultsTableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    }
    
    NSString *string = [[self.searchDisplayController.searchBar text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (string.length <= 0) {
        return NO;
    }
    [self filterContentForSearchText:string scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles]
      objectAtIndex:searchOption]];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    [self.resultsArray removeAllObjects];
    self.searchPageNo = 0;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"addressName CONTAINS[cd] %@ OR mobilePhone CONTAINS[cd] %@ OR displayName CONTAINS[cd] %@", searchText, searchText, searchText];
    self.resultsFromAddressArray = [NSMutableArray arrayWithArray:[_personGolfArray filteredArrayUsingPredicate:predicate]];
    self.resultsArray = [NSMutableArray arrayWithArray:[_resultsArray arrayByAddingObjectsFromArray:_resultsFromAddressArray]];
    if (!_hasMore) {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"displayName CONTAINS[cd] %@ OR mobilePhone CONTAINS[cd] %@ OR originalName CONTAINS[cd] %@", searchText, searchText, searchText];
        self.resultsFromFriendsArray = [NSMutableArray arrayWithArray:[_allFriendsList filteredArrayUsingPredicate:predicate1]];
        NSMutableArray *array = [self filterResultsFromFriendsArrayWithResultsFromAddressArray:[NSMutableArray arrayWithArray:_resultsFromFriendsArray]];
        self.resultsArray = [NSMutableArray arrayWithArray:[_resultsArray arrayByAddingObjectsFromArray:array]];
        [self.searchDisplayController.searchResultsTableView reloadData];
    } else {
        self.searchPageNo = 0;
        [self loadSearchData];
    }
}

- (void)loadSearchData {
    _searchPageNo++;
    [ServerService userFollowListWithSessionId:[[LoginManager sharedManager] getSessionId] followType:1 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude pageNo:(int)_searchPageNo pageSize:(int)_searchPageSize keyword:_searchBar.text success:^(NSArray *list) {
        if (list.count > 0) {
            self.searchHasMore = YES;
        }else{
            self.searchHasMore = NO;
        }
        NSMutableArray *array = [self filterResultsFromFriendsArrayWithResultsFromAddressArray:[NSMutableArray arrayWithArray:list]];
        self.resultsArray = [NSMutableArray arrayWithArray:[_resultsArray arrayByAddingObjectsFromArray:array]];
        [self.searchDisplayController.searchResultsTableView reloadData];
    } failure:^(id error) {
        
    }];
}

- (NSMutableArray *)filterResultsFromFriendsArrayWithResultsFromAddressArray:(NSMutableArray *)array {
    int i = 0;
    NSMutableIndexSet *set=[NSMutableIndexSet indexSet];
    for (UserFollowModel *model in _resultsFromFriendsArray ) {
        for (PersonInAddressList *person in _resultsFromAddressArray) {
            if ([model.mobilePhone isEqualToString:person.mobilePhone]) {
                [set addIndex:i];
                break;
            }
        }
        i++;
    }
    [array removeObjectsAtIndexes:set];
    return array;
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    [_refreshControl endRefreshing];
        if (Equal(flag, @"user_find_contacts")) {
            if (array && array.count > 0) {
                for (PersonInAddressList *personR in array) {
                    if (personR.isFollowed == 1 || personR.isFollowed == 4) {
                        for (NSInteger j = 0; j < _personAddressArray.count; j ++) {
                            PersonInAddressList *person = [_personAddressArray objectAtIndex:j];
                            if (Equal(personR.mobilePhone, person.mobilePhone)) {
                                person.memberId = personR.memberId;
                                person.isFollowed = personR.isFollowed;
                                person.displayName = personR.displayName;
                                person.headImage = personR.headImage;
                                [_personGolfArray addObject:person];
                            }
                        }
                    }
                }
            }
        }
    if (Equal(flag, @"user_follow_list")) {
        if (serviceManager.success) {
            if (array && array.count > 0) {
                NSDictionary *dic = [array objectAtIndex:0];
                NSArray *array1 = dic[@"follow_list"];
                if (_page == 1) {
                    self.hasMore = YES;
                    [self.allFriendsList removeAllObjects];
                }
                
                if (array1 && array1.count>0) {
                    for (id obj in array1) {
                        UserFollowModel *model = [[UserFollowModel alloc] initWithDic:obj];
                        NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                        if ([remarkName isNotBlank]) {
                            model.displayName = remarkName;
                        }
                        [self.allFriendsList addObject:model];
                    }
                    
                    [_tableView reloadData];
                    _hasMore = YES;
                }else{
                    _hasMore = NO;
                }
            }
            if (_allFriendsList.count <= 0) {
                [self addNoView];
            }
        }
    }
    [_tableView reloadData];
}
- (void)addNoView{
    _noResultView = [NoResultView text:@"暂无好友" type:NoResultTypeList superView:self.view show:^{
        self.tableView.hidden = YES;
    } hide:^{
        self.tableView.hidden = NO;
    }];
    [_noResultView show:YES];
}

#pragma mark - YGLoginViewCtrlDelegate
- (void)loginButtonPressed:(id)sender {
    [self initializeTableView];
    [self initializeData];
}

#pragma clang diagnostic pop

@end
