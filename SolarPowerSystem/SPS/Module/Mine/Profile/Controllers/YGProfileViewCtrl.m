//
//  YGProfileViewCtrl.m
//  Golf
//
//  Created by 廖瀚卿 on 15/12/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGProfileViewCtrl.h"
#import "TrendsTableViewCell.h"
#import "TrendsPraiseListController.h"
#import "ImageBrowser.h"
#import "BaseVideoPlayController.h"
#import "TrendsModel.h"
#import "TrendsViewController.h"
#import "CCActionSheet.h"
#import "TrendsDetailsViewController.h"
#import "OpenUDID.h"
#import "YGInputViewCtrl.h"
#import "YGTagsTableCell.h"
#import "SimpleContentTableViewCell.h"
#import "TopicDetailsViewController.h"
#import "CoachDetailsViewController.h"
#import "FootPrintMapController.h"
#import "YGProfileEditingViewCtrl.h"
#import "YGProfileFootprintHeaderCell.h"
#import "FootprintTableViewCell.h"
#import "WKDChatViewController.h"
#import "YGSystemImagePicker.h"
#import "TabbarChangeView.h"
#import "TopicHelp.h"
#import "HCStatusBarHud.h"
#import "SelectClubViewController.h"
#import "Person.h"
#import "FootprintDetialsViewController.h"
#import "CourseRecordViewController.h"
#import "IMCore.h"
#import "ReactiveCocoa.h"
#import "JZNavigationExtension.h"
#import "YGPublishViewCtrl.h"
#import "YGUserRemarkCacheHelper.h"
#import "SharePackage.h"

#import "YGUserPictureListViewCtrl.h"

dispatch_semaphore_t semaphore4;

@interface YGProfileViewCtrl ()<UITableViewDataSource,UITableViewDelegate,SharePackageDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *imageBg;
@property (weak, nonatomic) IBOutlet UIImageView *imageHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPicture;
@property (weak, nonatomic) IBOutlet UIImageView *imageSex;
@property (weak, nonatomic) IBOutlet UILabel *labelAge;
@property (weak, nonatomic) IBOutlet UILabel *labelInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelFans;
@property (weak, nonatomic) IBOutlet UILabel *labelAttion;
@property (weak, nonatomic) IBOutlet UIView *viewToolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infomationConstraint;

@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnAttation;
@property (weak, nonatomic) IBOutlet UIButton *btnLevel;
@property (weak, nonatomic) IBOutlet UIView *line;

@property (nonatomic,assign) int defaultMemberId;
@property (nonatomic,assign) int sharedTopicID;
@property (nonatomic) int isAttentionOrComment;
@property (nonatomic, strong) TopicModel *currentCellModel;
@property (nonatomic) int operationAboutFollow;
@property (nonatomic) BOOL isOneDetailList,isSendMessage,willAttentionMustRemove;
@property (nonatomic, strong) ArticleCommentModel *articleCommentModel;
@property (nonatomic,copy) NSString *loginHandleTag;

@property (strong, nonatomic) MediaBean *tempMediaBean;
@property (strong, nonatomic) Location *tempLocation;

@property (strong, nonatomic) NSMutableArray *section0Arr,*datas1,*datas2;//_datas是动态的数组，_datas2是足迹的数组,section0Arr存储的是用户头像下面所包含的数据，最多三行，分别是签名，标签和教练


@property (assign, nonatomic) BOOL refresh;//刷新列表;

@property (strong, nonatomic) TopicModel *topicModel_;
@property (strong, nonatomic) SharePackage *share;

@property (assign, nonatomic) BOOL loading,loading2;
@property (assign, nonatomic) BOOL hasMore,hasMore2;

@property (assign, nonatomic) int pageSize;
@property (assign, nonatomic) int page1,page2; //page1是动态的分页，page2是足迹的分页

@end

@implementation YGProfileViewCtrl{
    
    NSString *replyContent;
    
    TabbarChangeView *sectionView;
    
    CGFloat tagHeight;
    int _operation;
    UIImage *imgLock,*imgForm;
    CGFloat signatureHeight;
    CGFloat academyHeight;
}

- (void)updateNaviTitle
{
    if (self.jz_navigationBarBackgroundHidden) {
        self.navigationItem.title = @"";
    }else{
        self.navigationItem.title = self.userDetail.displayName;
    }
}

#pragma mark - 视图控制
- (BOOL)iamLogined{ //当前帐号已经登录并且是我自己的个人主页
    return ([LoginManager sharedManager].loginState == YES && _defaultMemberId == [LoginManager sharedManager].session.memberId);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    YGPostBuriedPoint(YGUserProfilePoint_Home);
    semaphore4 = dispatch_semaphore_create(1);

    _defaultMemberId = self.memberId;
    
    sectionView = [[[NSBundle mainBundle] loadNibNamed:@"TabbarChangeView" owner:nil options:0] firstObject];
    [sectionView.btn1 setTitle:@"动态" forState:(UIControlStateNormal)];
    [sectionView.btn1 setTitle:@"动态" forState:(UIControlStateHighlighted)];
    [sectionView.btn1 setTitle:@"动态" forState:UIControlStateSelected];
    
    [sectionView.btn2 setTitle:@"足迹" forState:(UIControlStateNormal)];
    [sectionView.btn2 setTitle:@"足迹" forState:(UIControlStateHighlighted)];
    [sectionView.btn2 setTitle:@"足迹" forState:UIControlStateSelected];
    [sectionView changeBlur:NO];
    
    ygweakify(self);
    sectionView.clickBlock = ^(id data){
        ygstrongify(self);
        if (!self) return;
        NSInteger index = [data integerValue];
        switch (index) {
            case 1:
            {
                self.showIndex = 0; //动态
                if (self.datas1.count == 0) {
                    [self getFirstPage];
                }else{
                    [self.tableView reloadData];
                }
            }
                break;
            case 2:
            {
                self.showIndex = 1; //足迹
                if (self.datas2.count == 0) {
                    [self getFirstPage];
                }else{
                    [self.tableView reloadData];
                }
            }
                break;
            default:
                break;
        }
    };
    
    if (self.showIndex == 0) {
        [sectionView changeLineView:1 animated:NO];
    }else{
        [sectionView changeLineView:2 animated:NO];
    }
    
    self.defaultImage = [UIImage imageNamed:@"cgit_s.png"];
    imgLock = [UIImage imageNamed:@"ic_lock_off_gray"];
    imgForm = [UIImage imageNamed:@"ic_footprint_form"];
    
    _section0Arr = [[NSMutableArray alloc] init];
    _datas1 = [[NSMutableArray alloc] init];
    _datas2 = [[NSMutableArray alloc] init];
    
    self.imageHeader.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageHeader.layer.borderWidth = 1.0;
    
    [self.tableView setContentInset:(UIEdgeInsetsMake(0, 0, ([self iamLogined] ? 0:44), 0))];
    [TopicHelp registerNibs:self.tableView];
    
    if (!self.isFromYQ) {
        if ([self iamLogined]) {
            //个人主页
            self.viewToolbar.hidden = YES;
            [self rightButtonAction:@"编辑资料"];
        }else{
            [self rightButtonActionWithImg:@"ic_threedot" autoSize:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _viewToolbar.hidden = NO;
            });
        }
    } else {
        if (!self.isJoinYQ) {
            self.viewToolbar.hidden = YES;
        }else{
            if ([self iamLogined]) {
                //个人主页
                [self rightButtonAction:@"编辑资料"];
            }else{
                [self rightButtonActionWithImg:@"ic_threedot" autoSize:YES];
            }
            self.viewToolbar.hidden = NO;
        }
    }
    
    self.hidesClearText = YES;
    self.dimissHidden = YES;
    self.inputToolbar.hidden = YES;
    
    [self loadUserDetailFromServer];
    [self getFirstPage];
    
    self.navigationItem.title = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTopicListWithAttention:) name:@"refreshAttentList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSignalCell:) name:@"refreshTopicSignalCell" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFirstPage) name:@"refreshTopicList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFootprintList:) name:@"refreshFootprintList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserPlayedClubList:) name:@"UserPlayedClubList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishTopicFailured) name:@"PUBLISH_TOPIC_FAILURED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFootprintList:) name:@"NOTIFICATION_REFRESH_FOOTPRINT_LIST" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshTopicList" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshAttentList" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshTopicSignalCell" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshFootprintList" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserPlayedClubList" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PUBLISH_TOPIC_FAILURED" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NOTIFICATION_REFRESH_FOOTPRINT_LIST" object:nil];
    }
}


-(void)viewDidLayoutSubviews{
    CGRect navigationBarRect = self.navigationController.navigationBar.frame;
    CGFloat top = navigationBarRect.size.height + navigationBarRect.origin.y - 10;
    self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, 0, 0);
}

- (void)doRightNavAction
{
    if ([self iamLogined]) {
        ygweakify(self);
        YGProfileEditingViewCtrl *vc = [YGProfileEditingViewCtrl instanceFromStoryboard];
        vc.userDetail = self.userDetail;
        vc.delegate = self;
        vc.blockReturn = ^(id data){
            ygstrongify(self);
            self.userDetail = data;
            tagHeight = 0.f;
            [self loadUserDetail];
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self showActionSheetController];
    }
}


-(void)hideKeyboard{
    [super hideKeyboard];
    self.inputToolbar.hidden = YES;
    self.memberId = 0;
    self.displayName = nil;
    [self.inputToolbar setPlaceHolder:@"请输入评论内容"];
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    [self sendContent:toolbar.contentView.textView.text];
}

#pragma mark - 数据逻辑处理

- (void)getFirstPage{
    if (self.showIndex == 0) {
        self.page1 = 1;
        self.pageSize = 10;
        self.hasMore = YES;
        self.refresh = YES;
        [self getTopicList];
    }else if (self.showIndex == 1){
        [self loadUserPlayedCourse];
        self.page2 = 1;
        self.pageSize = 10;
        self.hasMore2 = YES;
        [self getFootprintList];
    }
    
}

- (void)topicListResultList:(NSArray *)arr{
    TrendsModel *m = [arr firstObject];
    if (_isOneDetailList) {
        self.isOneDetailList = NO;
        if (m.topicList.count == 1) {
            TopicModel *tm = [m.topicList firstObject];
            _currentCellModel = tm;
            [self judgeLoginAndPerfectAndIsFollowed];
            for (TopicModel *theModel in _datas1) {
                if ([theModel isKindOfClass:[TopicModel class]]) {
                    if (theModel.memberId == tm.memberId) {
                        theModel.isFollowed = tm.isFollowed;
                    }
                }
            }
        }
        self.loading = NO;
        self.refresh = NO;
        return;
    }
    
    if (self.page1 == 1) {
        [_datas1 removeAllObjects];
    }
    
    if (m && m.topicList.count > 0) {
        NSMutableArray *list = m.topicList;
        
        [_datas1 addObjectsFromArray:list];
        _datas1 = [[NSMutableArray alloc] initWithArray:[_datas1 linq_distinct:^id(id item) {
            TopicModel *_m = (TopicModel *)item;
            if ([_m isKindOfClass:[TopicModel class]]) {
                return @(_m.topicId);
            }
            return _m;
        }]];
        
        
        self.page1 ++;
        self.hasMore = m.topicList.count == self.pageSize;
    }else{
        self.hasMore = NO;
    }
    
    if (self.isFromYQ == YES && self.isJoinYQ == NO) {
        for (TopicModel *theModel in _datas1) {
            if ([theModel isKindOfClass:[TopicModel class]]) {
                theModel.commentList = nil;
                theModel.shareList = nil;
                theModel.praiseList = nil;
                theModel.commentCount = 0;
                theModel.shareCount = 0;
                theModel.praiseCount = 0;
            }
        }
    }
    
    [UIView performWithoutAnimation:^{
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        self.refresh = NO;
    }];
    self.loading = NO;

}

- (void)getTopicListBySessionId:(NSString *)sessionId tagId:(int)tagId tagName:(NSString *)tagName memberId:(int)memberId clubId:(int)clubId topicId:(int)topicId topicType:(int)topicType pageNo:(int)pageNo longitude:(double)longitude latitude:(double)latitude success:(void (^)(NSArray *list))success failure:(void (^)(id error))failure{
    
    [ServerService topicList:sessionId tagId:tagId tagName:tagName memberId:memberId clubId:clubId topicId:topicId topicType:topicType pageNo:pageNo pageSize:self.pageSize longitude:longitude latitude:latitude success:^(NSArray *list) {
        success(list);
    } failure:^(id error) {
        failure(error);
    }];
}

//加载分页数据
- (void)getTopicList{
    if ([[GolfAppDelegate shareAppDelegate] networkReachability]) {
        if (self.loading) {
            return;
        }
        self.loading = YES;
        self.refresh = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *sessoinId = ([LoginManager sharedManager].loginState ? [[LoginManager sharedManager] getSessionId]:nil);
            
            ygweakify(self);
            [self getTopicListBySessionId:sessoinId tagId:0 tagName:nil memberId:_defaultMemberId clubId:0 topicId:0 topicType:0
                                   pageNo:self.page1
                                longitude:[LoginManager sharedManager].currLongitude
                                 latitude:[LoginManager sharedManager].currLatitude success:^(NSArray *list) {
                                     ygstrongify(self);
                [self topicListResultList:list];
            } failure:^(id error) {
                ygstrongify(self);
                self.loading = NO;
                self.refresh = NO;
            }];
        });
    }
}

- (void)getFootprintList{
    if ([[GolfAppDelegate shareAppDelegate] networkReachability] && _defaultMemberId != 0) {
        if (self.loading2) {
            return;
        }
        self.loading2 = YES;
    
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ygweakify(self);
            
            [ServerService footPrintListWithSessionId:[[LoginManager sharedManager] getSessionId] memberId:_defaultMemberId pageNo:self.page2 pageSize:self.pageSize courseid:0 courseName:nil success:^(NSMutableArray *arr) {
                ygstrongify(self);
                if(!self){
                return;
                }
                if (self.page2 == 1) {
                    [self.datas2 removeAllObjects];
                }
                if (arr && arr.count>0) {
                    for (FootprintModel *m in arr) {
                        if (m.topicVideo.length > 0 || m.topicPictures.count > 0 || m.topicContent.length > 0) {
                            [self.datas2 addObject:m];
                        }
                    }
                    self.page2++;
                    self.hasMore2 = arr.count == self.pageSize;
                }else{
                    self.hasMore2 = NO;
                }
                self.loading2 = NO;
                [self.tableView reloadData];

            } failure:^(id error) {
                
            }];
        });
    }
    
}



#pragma mark - 评论回复相关

- (void)sendContent:(NSString*)text{
    [self.inputToolbar.contentView.textView setText:@""];
    if (text && text.length > 0) {
        replyContent = text;
        
        if (![LoginManager sharedManager].loginState) {
            [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
                [self _sendContent:text];
            }];
            return;
        }
        [self _sendContent:text];
    }
}

- (void)_sendContent:(NSString *)text{
    if ([Utilities isBlankString:text]) {
        [SVProgressHUD showInfoWithStatus:@"输入的内容无效"];
        return;
    }
    
    if ([self needPerfectMemberData]) {
        return;
    }
    
    if (text.length > 200) {
        [SVProgressHUD showInfoWithStatus:@"您输入的文字过长，不能超过200字符"];
        return;
    }
    
    [ServerService topicCommentAdd:[[LoginManager sharedManager] getSessionId] topicId:self.topicModel_.topicId toMemberId:self.memberId text:text success:^(id data) {
        self.topicModel_.commentCount ++;
        ArticleCommentModel *cm = [[ArticleCommentModel alloc] initWithDic:data];
        if (self.topicModel_.commentList == nil) {
            self.topicModel_.commentList = [[NSMutableArray alloc] init];
        }
        [self.topicModel_.commentList addObject:cm];
        
        if (self.topicModel_) {
            NSDictionary *nd = @{@"topicModel":self.topicModel_,@"articCommentModel":cm,@"api":@"topic_comment_add"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTopicSignalCell" object:nd];
        }
       
        
        self.topicModel_ = nil;
        self.memberId = 0;
        self.displayName = @"";
        [self hideKeyboard];
        
    } failure:^(id error) {
        self.topicModel_ = nil;
        self.memberId = 0;
        self.displayName = @"";
    }];
}


- (void)reply_:(ArticleCommentModel *)nd{
    if (nd.memberId == [LoginManager sharedManager].session.memberId) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self removeCommentModel:nd];
        }];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [alert addAction:actionCancel];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    self.memberId = nd.memberId;
    self.displayName = nd.displayName;
    [self showChatWithPlaceHolder:[NSString stringWithFormat:@"回复%@:",self.displayName]];
}


- (void)showChat:(ArticleCommentModel *)nd{
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            [self showChat_:nd];
        }];
        return;
    }
    [self showChat_:nd];
}

- (void)showChat_:(ArticleCommentModel *)nd{
    if (nd.memberId == [LoginManager sharedManager].session.memberId) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [ServerService topicCommentDelete:[[LoginManager sharedManager] getSessionId] commentId:nd.commentId topicId:self.topicModel_.topicId success:^(id obj) {
                [ServerService topicList:([LoginManager sharedManager].loginState ? [[LoginManager sharedManager] getSessionId]:nil)
                                   tagId:0 tagName:0 memberId:0 clubId:0 topicId:self.topicModel_.topicId topicType:0 pageNo:1 pageSize:10 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude success:^(NSArray *list) {
                                       if (list && list.count > 0) {
                                           NSInteger index = [_datas1 indexOfObject:self.topicModel_];
                                           TrendsModel *m = list.firstObject;
                                           if (m && m.topicList.count > 0) {
                                               [_datas1 replaceObjectAtIndex:index withObject:m.topicList.firstObject];
                                               
                                               NSDictionary *model = @{@"topicModel":m.topicList.firstObject,@"articCommentModel":nd,@"api":@"topic_comment_delete"};
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTopicSignalCell" object:model];
                                           }
                                           
                                           //                                           [self.tableView reloadData];
                                           [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:(UITableViewRowAnimationNone)];
                                       }
                                   } failure:nil];
            } failure:nil];
        }];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [alert addAction:actionCancel];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (_userDetail.isFollowed == 3 || _userDetail.isFollowed == 6) {
        [SVProgressHUD showInfoWithStatus:@"禁止评论"];
        return;
    }
    self.memberId = nd.memberId;
    self.displayName = nd.displayName;
    [self showChatWithPlaceHolder:[NSString stringWithFormat:@"回复%@:",self.displayName]];
}


- (void)canSendMessage {
    _btnSendMessage.enabled = YES;
}

-(void)willSendMessage {
    if (_userDetail.isFollowed == 6) {
        _btnSendMessage.enabled = YES;
        [SVProgressHUD showInfoWithStatus:@"TA拒绝接收你的私信"];
    } else if (_userDetail.isFollowed == 3) {
        _btnSendMessage.enabled = YES;
        NSString *messageString = @"对方在你的黑名单中，确定要发送私信？TA将从黑名单中移出。";
        self.operationAboutFollow = 7;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:messageString preferredStyle: UIAlertControllerStyleActionSheet];

        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            self.isSendMessage = YES;
            [self userFollowToMemberId:_userDetail.memberId nameRemark:nil operation:_operationAboutFollow];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self sendMessage];
    }
}


- (IBAction)senderMessageAction:(id)sender{
    _btnSendMessage.enabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(canSendMessage) userInfo:nil repeats:NO];
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            [ServerService userHeadImageList:[LoginManager sharedManager].getSessionId memberIds:[NSString stringWithFormat:@"%d", _userDetail.memberId ] success:^(NSArray *list) {
                if (list && list.count > 0) {
                    UserFollowModel *model = list[0];
                    _userDetail.isFollowed = model.isFollowed;
                }
                [self willSendMessage];
                
            } failure:^(id error){
                _btnSendMessage.enabled = YES;
            }];
        }];
        return;
    }
    if (_userDetail.isFollowed == -1) {
        [ServerService userHeadImageList:[LoginManager sharedManager].getSessionId memberIds:[NSString stringWithFormat:@"%d", _userDetail.memberId ] success:^(NSArray *list) {
            if (list && list.count > 0) {
                UserFollowModel *model = list[0];
                _userDetail.isFollowed = model.isFollowed;
            }
            
            [self willSendMessage];
        } failure:^(id error){
            _btnSendMessage.enabled = YES;
        }];
        return;
    }
    
    [self willSendMessage];
}


- (void)sendMessage {
    if ([self needPerfectMemberData]) {
        return;
    }
    [self toChatViewController];
}

- (void)toChatViewController{
    __weak typeof(self) weakSelf = self;
    WKDChatViewController *chatVC = [[WKDChatViewController alloc] init];
    chatVC.hidesBottomBarWhenPushed = YES;
    chatVC.targetImage = _imageHeader.image;
    chatVC.memId = weakSelf.userDetail.memberId;
    chatVC.targetName = weakSelf.userDetail.displayName;
    chatVC.isFollow = weakSelf.userDetail.isFollowed;
    [weakSelf pushViewController:chatVC title:weakSelf.userDetail.displayName  hide:YES];
}


- (void)removeCommentModel:(ArticleCommentModel *)nd{
    [ServerService topicCommentDelete:[[LoginManager sharedManager] getSessionId] commentId:nd.commentId topicId:self.topicModel_.topicId success:^(id obj) {
        [ServerService topicList:([LoginManager sharedManager].loginState ? [[LoginManager sharedManager] getSessionId]:nil)
                           tagId:0 tagName:0 memberId:0 clubId:0 topicId:self.topicModel_.topicId topicType:0 pageNo:1 pageSize:10 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude success:^(NSArray *list) {
                               if (list && list.count > 0) {
                                   NSInteger index = [_datas1 indexOfObject:self.topicModel_];
                                   TrendsModel *m = list.firstObject;
                                   TopicModel *tm = [_datas1 objectAtIndex:index];
                                   if (m && m.topicList.count > 0) {
                                       TopicModel *fm = m.topicList.firstObject;
                                       fm.showAllContent = tm.showAllContent;
                                       [_datas1 replaceObjectAtIndex:index withObject:fm];
                                       
                                       NSDictionary *model = @{@"topicModel":m.topicList.firstObject,@"articCommentModel":nd,@"api":@"topic_comment_delete"};
                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTopicSignalCell" object:model];
                                   }
//                                   [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:(UITableViewRowAnimationNone)];
                                   [self.tableView reloadData];
                                   
                               }
                           } failure:^(id error) {
                               
                           }];
    } failure:nil];
}



#pragma mark - 通知处理

- (void)refreshFootprintList:(NSNotification*)notofication{
    if (self.showIndex == 1) {
        self.page2 = 1;
        self.loading2 = NO;
        self.hasMore2 = YES;
        
        [self loadUserPlayedCourse];
        [self getFootprintList];
    }
}


- (void)refreshSignalCell:(NSNotification *)nf{
    self.refresh = YES;
    NSDictionary *dic = [nf object];
    NSString *api = dic[@"api"];
    
    if ([@"topic_share_add" isEqualToString:api] || [@"topic_praise_add" isEqualToString:api] || [@"topic_comment_add" isEqualToString:api]) {
        TopicModel *m = dic[@"topicModel"];
        if (m) {
            for (TopicModel *tm in _datas1) {
                if ([tm isKindOfClass:[TopicModel class]] && tm.topicId == m.topicId) {
                    NSInteger index = [_datas1 indexOfObject:tm];
                    [_datas1 replaceObjectAtIndex:index withObject:m];
                    break;
                }
            }
        }
    }
    
    if ([@"topic_delete" isEqualToString:api]) {
        TopicModel *m = dic[@"topicModel"];
        if (m) {
            for (TopicModel *tm in _datas1) {
                if ([tm isKindOfClass:[TopicModel class]] && tm.topicId == m.topicId) {
                    [_datas1 removeObject:tm];
                    break;
                }
            }
        }
    }
    
    if ([@"topic_comment_delete" isEqualToString:api]) {
        TopicModel *m = dic[@"topicModel"];
        ArticleCommentModel *cm = dic[@"articCommentModel"];
        if (cm) {
            for (TopicModel *tm in _datas1) {
                if ([tm isKindOfClass:[TopicModel class]] && tm.topicId == m.topicId) {
                    for (ArticleCommentModel *acm in tm.commentList) {
                        if (acm.commentId == cm.commentId) {
                            tm.commentCount--;
                            [tm.commentList removeObject:acm];
                            NSUInteger index = [_datas1 indexOfObject:tm];
                            @try {
                                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:(UITableViewRowAnimationNone)];
                            } @catch (NSException *exception) {
                                [self.tableView reloadData];
                            }
                            [self.tableView layoutIfNeeded];
                            self.refresh = NO;
                            break;
                        }
                    }
                    break;
                }
            }
            return;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        self.refresh = NO;
    });
}


- (void)refreshTopicListWithAttention:(NSNotification *)nf{
    NSDictionary *dic = nf.object;
    UserFollowModel *model = dic[@"data"];
    if (_userDetail.memberId == model.memberId) {//lyf 加
        _userDetail.isFollowed = model.isFollowed;
        if ([dic[@"flag"] intValue] == 3) {
            if(self.userDetail.nickName.length == 0 || Equal(self.userDetail.nickName, self.userDetail.displayName)){
                self.labelName.text = self.userDetail.displayName;
            } else {
                self.labelName.text = [NSString stringWithFormat:@"%@ (%@)",self.userDetail.displayName,self.userDetail.nickName];
            }
        }
    }

    for (TopicModel *m in _datas1) {
        if ([m isKindOfClass:[TopicModel class]]) {
            if (m.memberId == model.memberId) {
                m.isFollowed = model.isFollowed;
                if ([dic[@"flag"] intValue] == 3) {
                    m.displayName = model.displayName;
                }
            }
            if ([dic[@"flag"] intValue] == 3) {
                for (ArticleCommentModel *ac in m.commentList) {
                    if (ac.memberId == model.memberId) {
                        ac.displayName = model.displayName;
                    }
                    if (ac.toMemberId == model.memberId) {
                        ac.toDisplayName = model.displayName;
                    }
                }
            }
        }
    }
    self.btnAttation.selected = (self.userDetail.isFollowed == 1 || self.userDetail.isFollowed == 4);
    [self.tableView reloadData];
}

- (void)refreshUserPlayedClubList:(NSNotification*)notification{
    self.userPlayedClubListModel = [notification object];
    if (self.showIndex == 1) {
        [self.tableView reloadData];
    }
}

- (void)refreshUserInfo{
    [self loadUserDetailFromServer];
    [self getFirstPage];//lq 加 刷新列表
}

-(void)loadUserPlayedCourse{
    [ServerService userPlayedCourseListByMemberId:_defaultMemberId success:^(UserPlayedClubListModel *obj) {
        self.userPlayedClubListModel = obj;
        if (self.showIndex == 1) {
            [self.tableView reloadData];
        }
    } failure:nil];
}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
        {
            [_section0Arr removeAllObjects];
            if (self.userDetail == nil) {
                return 0;
            }
            if (self.userDetail.signature.length > 0) {
                [_section0Arr addObject:@{@"key":@"signature",@"value":self.userDetail.signature}];
            }
            if (self.userDetail.personalTag.length > 0) {
                [_section0Arr addObject:@{@"key":@"personalTag",@"value":[self.userDetail.personalTag componentsSeparatedByString:@","]}];
            }
            if (self.userDetail.academyId > 0) { //学院id大于0表示他是教练
                [_section0Arr addObject:@{@"key":@"academy",@"value":self.userDetail.academyName}];
            }
            [_section0Arr addObject:@{@"key":@"SectionCell"}];
            
            return _section0Arr.count;
        }
            break;
        case 1:
            switch (self.showIndex) {
                case 0: //动态数据
                    if (_datas1.count == 0 && _defaultMemberId != [LoginManager sharedManager].session.memberId && self.hasMore == NO) { //没有动态数据的第三方个人主页
                        return 1;
                    }
                    return _datas1.count + (_datas1.count > 0 ? 1:0) + ([self iamLogined] ? 1:0);
                    break;
                case 1:
                    return _datas2.count + 2 + ([self iamLogined] ? 1:0);
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }

    return 0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isFromYQ && indexPath.section == 1 && self.showIndex == 0) {
        if (!self.isJoinYQ) {
            return;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hideKeyboard];
    
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *nd = _section0Arr[indexPath.row];
            NSString *key = nd[@"key"];
            if ([key isEqualToString:@"academy"]) {
                ygweakify(self);
                [self pushWithStoryboard:@"Teach" title:@"教练详情" identifier:@"CoachDetailsViewController" completion:^(BaseNavController *controller) {
                    ygstrongify(self);
                    CoachDetailsViewController *vc = (CoachDetailsViewController *)controller;
                    vc.coachId = self.userDetail.memberId;
                }];
            }
        }
            break;
        case 1:
        {
            if (self.showIndex == 0) {
                if (_datas1.count == 0 && _defaultMemberId != [LoginManager sharedManager].session.memberId && self.hasMore == NO) { //没有动态数据的第三方个人主页  单元格点击无反应
                    return;
                }
                
                if (_datas1.count + ([self iamLogined] ? 1:0) == indexPath.row) {
                    return;
                }
                
                if (indexPath.row == 0 && [self iamLogined]) {
                    [self toYGTeachingArchivePublishViewCtrl];
                    return;
                }
                id model = _datas1[([self iamLogined]) ? indexPath.row - 1 : indexPath.row];
                if ([model isKindOfClass:[TopicModel class]]) {
                    [self toTrendsDetailsViewController:model indexPath:indexPath];
                }
            }else{
                if (_datas2.count == 0 || indexPath.row == 0) { //没有足迹数据的第三方个人主页  单元格点击无反应
                    return;
                }
                
                if (_datas2.count + 2 + ([self iamLogined] ? 1:0) == indexPath.row) {
                    return;
                }
                if (_datas2.count > indexPath.row - ([self iamLogined] ? 2:1)) {
                    [self toFootprintDetails:_datas2[indexPath.row - ([self iamLogined] ? 2:1)] isDetails:YES];
                }
                
            }
        }
            break;
        default:
            break;
    }
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showIndex == 0) {
        if (indexPath.row == _datas1.count && self.hasMore == YES) {
            [self getTopicList];
        }
    }else{
        if (indexPath.row == _datas2.count && self.hasMore2 == YES) {
            [self getFootprintList];
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ygweakify(self);
    switch (indexPath.section) {
        case 0:
        {
            BOOL hasPersonalTag = [_section0Arr linq_any:^BOOL(id item) {return [item[@"key"] isEqualToString:@"personalTag"];}];
            BOOL hasAcademy = [_section0Arr linq_any:^BOOL(id item) {return [item[@"key"] isEqualToString:@"academy"];}];
            
            NSDictionary *nd = _section0Arr[indexPath.row];
            NSString *key = nd[@"key"];
            
            if ([key isEqualToString:@"signature"]) {
                SimpleContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SignatureCell" forIndexPath:indexPath];
                cell.labelContent.text = self.userDetail.signature;
                if (hasAcademy == YES && hasPersonalTag == NO) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 13, 0, 0);
                }
                return cell;
            }
            if ([key isEqualToString:@"personalTag"]) {
                
                YGTagsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGTagsTableCell" forIndexPath:indexPath];
                [cell configureWithTags:nd[@"value"]];
                if (hasAcademy == NO) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                }
                return cell;
            }
            if ([key isEqualToString:@"academy"]) {
                SimpleContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AcademyCell" forIndexPath:indexPath];
                cell.labelContent.text = [NSString stringWithFormat:@"%@教练",self.userDetail.academyName];
                return cell;
            }
            if ([key isEqualToString:@"SectionCell"]) {
                return [tableView dequeueReusableCellWithIdentifier:@"SectionCell" forIndexPath:indexPath];
            }
            
        }
            break;
        case 1:
        {
            if (self.showIndex == 0) {
                
                if (_datas1.count == 0 && _defaultMemberId != [LoginManager sharedManager].session.memberId && self.hasMore == NO) {
                    SimpleContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyDatasCell" forIndexPath:indexPath];
                    cell.labelContent.text = @"Ta还没有发布动态";
                    return cell;
                }
                
                if (_datas1.count  + ([self iamLogined] ? 1:0) == indexPath.row) {
                    return [tableView dequeueReusableCellWithIdentifier:(self.hasMore ? @"LoadingCell":@"AllLoadedCell") forIndexPath:indexPath];
                }
                
                if (indexPath.row == 0 && [self iamLogined]) {  //当前用户个人主页第一行是发布新动态的按钮
                    SimpleContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FabuCell" forIndexPath:indexPath];
                    [cell.btnAction setTitle:@" 发布新动态" forState:(UIControlStateNormal)];
                    cell.blockReturn = ^(id data){
                        ygstrongify(self);
                        [self toYGTeachingArchivePublishViewCtrl];
                    };
                    
                    return cell;
                }
                
                TopicModel *m = nil;
                
                if (_datas1.count > (([self iamLogined]) ? indexPath.row - 1 : indexPath.row)) {
                    m =_datas1[([self iamLogined]) ? indexPath.row - 1 : indexPath.row];
                    
                    TrendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TopicHelp identifierWithTopicModel:m initIdentifier:@"TrendsTableViewCell7-9"] forIndexPath:indexPath];
                    cell.isInTrendsViewController = ![self iamLogined];
                    cell.showAllContent = NO;
                    cell.delegate = self;
                    if (self.isFromYQ == YES && self.isJoinYQ == NO) {
                        cell.hiddenButtonsAndReplys = YES;
                    }
                    if (self.refresh) {
                        [cell loadDatas:m];
                    }else{
                        [cell loadDatas:m reload:m != cell.data];
                    }
                    
                    if (cell.blockRePublish == nil) {
                        cell.blockRePublish = ^(id data){
                            ygstrongify(self);
                            if ([GolfAppDelegate shareAppDelegate].networkReachability) {
                                [_datas1 enumerateObjectsUsingBlock:^(TopicModel *  _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
                                    if ([m isKindOfClass:[TopicModel class]]) {
                                        if ([@"发布失败" isEqualToString:m.topicTime]) {
                                            m.topicTime = @"发布中";
                                            [self.tableView reloadData];
                                            *stop = YES;
                                        }
                                    }
                                }];
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                    dispatch_semaphore_wait(semaphore4, DISPATCH_TIME_FOREVER);
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [HCStatusBarHud pubDynamic:self.tempMediaBean location:self.tempLocation callBack:^(int status) {
                                        }];
                                    });
                                    dispatch_semaphore_signal(semaphore4);
                                });
                            }
                        };
                    }
                    
                    if (cell.blockLocationAction == nil) {
                        cell.blockLocationAction = ^(id data){
                            ygstrongify(self);
                            TopicModel *m = (TopicModel *)data;
                            [self toFootprintDetailsByTrendsModel:m];
                        };
                    }
                    if (cell.blockHeadImageTaped == nil) {
                        cell.blockHeadImageTaped = ^(id data){
                            ygstrongify(self);
                            TopicModel *m = (TopicModel *)data;
                            [self toPersonalHomeControllerByMemberId:m.memberId displayName:m.displayName];
                        };
                    }
                    
                    if (cell.blockNicknameTaped == nil) {
                        cell.blockNicknameTaped = ^(id data){
                            ygstrongify(self);
                            TopicModel *m = (TopicModel *)data;
                            [self toPersonalHomeControllerByMemberId:m.memberId displayName:m.displayName];
                        };
                    }
                    
                    if (cell.blockVipTaped == nil) {
                        cell.blockVipTaped = ^(id data){
                            ygstrongify(self);
                            TopicModel *m = (TopicModel *)data;
                            [[GolfAppDelegate shareAppDelegate] showInstruction:[NSString stringWithFormat:@"https://m.bookingtee.com/vip.html?%d", m.memberLevel] title:@"用户说明" WithController:self];
                        };
                    }
                    
                    if (cell.blockAttentionTaped == nil) {
                        cell.blockAttentionTaped = ^(id data){
                            ygstrongify(self);
                            [self hideKeyboard];
                            self.currentCellModel = (TopicModel *)data;
                            self.isAttentionOrComment = 1;
                            [self judgeLoginAndPerfectAndIsFollowed];
                        };
                    }
                    
                    if (cell.blockReplyLabelTaped == nil) {
                        cell.blockReplyLabelTaped = ^(id data){
                            ygstrongify(self);
                            [self hideKeyboard];
                            self.viewAction = [data valueForKeyPath:@"el"];
                            ArticleCommentModel *nd = (ArticleCommentModel *)data[@"artice_comment_model"];
                            TopicModel *model = data[@"topic_model"];
                            self.topicModel_ = model;
                            self.isAttentionOrComment = 2;
                            self.articleCommentModel = nd;
                            self.currentCellModel = model;
                            [self judgeLoginAndPerfectAndIsFollowed];
                        };
                    }
                    
                    if (cell.blockReplyTaped == nil) {
                        cell.blockReplyTaped = ^(id data){
                            ygstrongify(self);
                            self.viewAction = [data valueForKeyPath:@"el"];
                            TopicModel *m = (TopicModel *)[data valueForKeyPath:@"data"];
                            self.topicModel_ = m;
                            if (m.commentCount == 0) {
                                if (self.userDetail.isFollowed == 3 || self.userDetail.isFollowed == 6) {
                                    [SVProgressHUD showInfoWithStatus:@"禁止评论"];
                                    return;
                                }
                                self.currentCellModel = m;
                                self.isAttentionOrComment = 3;
                                [self judgeLoginAndPerfectAndIsFollowed];
                            }else{
                                [self toTrendsDetailsViewController:m indexPath:indexPath];
                            }
                        };
                    }
                    
                    if (cell.blockCoachLevelTaped == nil) {
                        cell.blockCoachLevelTaped = ^(id data){
                            ygstrongify(self);
                            TopicModel *m = (TopicModel *)data;
                            [self toPersonalHomeControllerByMemberId:m.memberId displayName:m.displayName];
                        };
                    }
                    
                    if (cell.blockSeeAllContentTaped == nil) {
                        cell.blockSeeAllContentTaped = ^(id data){
                            ygstrongify(self);
                            [self hideKeyboard];
                            TopicModel *m = (TopicModel *)data;
                            m.showAllContent = !m.showAllContent;
                            self.refresh = YES;
                            [self.tableView reloadData];
                            [self.tableView layoutIfNeeded];
                            self.refresh = NO;
                        };
                    }
                    
                    if (cell.blockSellAllReplyTaped == nil) {
                        cell.blockSellAllReplyTaped = ^(id data){
                            ygstrongify(self);
                            [self hideKeyboard];
                            TopicModel *m = (TopicModel *)data;
                            [self toTrendsDetailsViewController:m indexPath:indexPath];
                        };
                    }
                    
                    if (cell.blockMoreZanTaped == nil) {
                        cell.blockMoreZanTaped = ^(id data){
                            ygstrongify(self);
                            TopicModel *m = (TopicModel *)data;
                            [self pushWithStoryboard:@"TrendsPraiseList" title:[NSString stringWithFormat:@"%d人赞过",m.praiseCount] identifier:@"TrendsPraiseListController" completion:^(BaseNavController *controller) {
                                TrendsPraiseListController *vc=(TrendsPraiseListController*)controller;
                                vc.topicId=m.topicId;
                            }];
                        };
                    }
                    if (cell.blockMoreShareTaped == nil) {
                        cell.blockMoreShareTaped = ^(id data){
                            ygstrongify(self);
                            TopicModel *m = (TopicModel *)data;
                            [self pushWithStoryboard:@"TrendsPraiseList" title:[NSString stringWithFormat:@"%d人分享",m.shareCount] identifier:@"TrendsPraiseListController" completion:^(BaseNavController *controller) {
                                TrendsPraiseListController *vc=(TrendsPraiseListController*)controller;
                                vc.isShareList=YES;
                                vc.topicId=m.topicId;
                            }];
                        };
                    }
                    
                    if (cell.blockImagePreview == nil) {
                        cell.blockImagePreview = ^(id data){
                            [self hideKeyboard];
                            
                            ygstrongify(self);
                            NSDictionary *nd = (NSDictionary *)data;
                            TopicModel *m = nd[@"data"];
                            UIButton *btn = nd[@"view"];
                            NSMutableArray *rects = nd[@"rects"];
                            
                            CGRect convertRect = [btn.superview convertRect:btn.frame toView:[GolfAppDelegate shareAppDelegate].window];
                            NSInteger index = btn.tag;
                            if (m.topicPictures.count == 4) {
                                if (index == 4) {
                                    index = 3;
                                }
                                if (index == 5) {
                                    index = 4;
                                }
                            }
                            if (m.topicPictures.count > 0) {
                                id obj = m.topicPictures[0];
                                if ([obj isKindOfClass:[UIImage class]]) {
                                    [ImageBrowser IBWithImages:m.topicPictures isCollection:NO currentIndex:index-1 initRt:convertRect isEdit:NO highQuality:NO vc:self backRtBlock:^CGRect(NSInteger i) {
                                        return [rects[i] CGRectValue];
                                    } completion:nil];
                                    return ;
                                }
                            }
                            [ImageBrowser IBWithImages:m.topicPictures isCollection:NO currentIndex:index-1 initRt:convertRect isEdit:NO highQuality:YES vc:self backRtBlock:^CGRect(NSInteger i) {
                                return [rects[i] CGRectValue];
                            } completion:nil];
                        };
                    }
                    if (cell.blockVideoPreview == nil) {
                        cell.blockVideoPreview = ^(id data){
                            
                            NSDictionary *nd = (NSDictionary *)data;
                            TopicModel *m = nd[@"data"];
                            BaseVideoPlayController *basevc = [[BaseVideoPlayController alloc] init];
                            basevc.blockReturn = ^(id obj){
                                BaseNavController *vc = (BaseNavController*)obj;
                                [Player playWithUrl:m.topicVideo rt:CGRectZero supportSlowed:YES supportCircle:YES vc:vc completion:^{
                                    [vc.navigationController popViewControllerAnimated:NO];
                                }];
                            };
                            [[GolfAppDelegate shareAppDelegate].currentController pushViewController:basevc title:@"" hide:YES animated:NO];
                        };
                    }
                    
                    if (cell.blockTeachingSiteTaped == nil) {
                        cell.blockTeachingSiteTaped = ^(id data){
                            ygstrongify(self);
                            TopicModel *m = (TopicModel *)data;
                            [self pushWithStoryboard:@"Trends" title:@"球场话题" identifier:@"TrendsViewController" completion:^(BaseNavController *controller) {
                                TrendsViewController *vc = (TrendsViewController *)controller;
                                vc.clubId = m.clubId;
                                vc.clubName = m.clubName;
                            }];
                        };
                    }
                    
                    if (cell.blockZanTaped == nil) {
                        __weak UITableViewCell *weakCell = cell;
                        cell.blockZanTaped = ^(id data, UIButton *btn){
                            ygstrongify(self);
                            [self hideKeyboard];
                            
                            TopicModel *m = (TopicModel *)data;
                            
                            if (![LoginManager sharedManager].loginState) {
                                [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
                                    [self zanActionWithModel:m tableViewCell:weakCell button:btn];
                                }];
                                return;
                            }
                            [self zanActionWithModel:m tableViewCell:weakCell button:btn];
                        };
                    }
                    
                    if (cell.blockShareTaped == nil) {
                        __weak UITableViewCell *weakCell = cell;
                        cell.blockShareTaped = ^(id data){
                            ygstrongify(self);
                            [self hideKeyboard];
                            if ([LoginManager sharedManager].loginState) {
                                if ([self needPerfectMemberData]) {
                                    return;
                                }
                            }
                            NSDictionary *nd = (NSDictionary *)data;
                            TopicModel *m = nd[@"data"];
                            NSString *title = nil;
                            NSString *content = nil;
                            NSString *url = [NSString stringWithFormat:@"%@topic/topic.html?topicId=%d",URL_SHARE,m.topicId];
                            UIImage *img = nil;
                            NSString *string = nil;
                            UIImage *headImage = ((TrendsTableViewCell *)weakCell).headImage.imageView.image;
                            BOOL hasVideo = (m.topicVideo && m.topicVideo.length > 0);
                            if (m.topicContent.length > 0 && m.topicPictures.count > 0) {
                                title = [NSString stringWithFormat:@"分享%@的动态",m.displayName];
                                content = m.topicContent;
                                if (hasVideo) {
                                    img = [self ablongToSquareImage:nd[@"img"] image:[UIImage imageNamed:@"bofang_"]];
                                } else {
                                    img = [self ablongToSquareImage:nd[@"img"] image:nil];
                                }
                                if (img == nil) {
                                    img = headImage;
                                }
                            }else if (m.topicContent.length > 0){
                                title = [NSString stringWithFormat:@"分享%@的动态",m.displayName];
                                content = m.topicContent;
                                img = headImage;
                            }else if (m.topicPictures.count > 0){
                                if (hasVideo) {
                                    title = [NSString stringWithFormat:@"分享%@的动态",m.displayName];
                                    content = [NSString stringWithFormat:@"分享了一个视频"];
                                    string = [NSString stringWithFormat:@"在云高发现%@的视频不错，值得一看!",m.displayName];
                                    img = [self ablongToSquareImage:nd[@"img"] image:[UIImage imageNamed:@"bofang_"]];
                                } else {
                                    title = [NSString stringWithFormat:@"分享%@的动态",m.displayName];
                                    content = [NSString stringWithFormat:@"分享了%d张图片",(int)m.topicPictures.count];
                                    string = [NSString stringWithFormat:@"在云高发现%@的图片不错，值得一看!",m.displayName];
                                    img = [self ablongToSquareImage:nd[@"img"] image:nil];
                                }
                                if (img == nil) {
                                    img = headImage;
                                }
                            }
                            if (!self.share) {
                                self.share = [[SharePackage alloc] init];
                            }
                            self.share.shareTitle = title;
                            self.share.shareContent = content;
                            self.share.shareUrl = url;
                            self.share.shareImg = img;
                            self.share.circleOfFriendsString = string;
                            self.share.topicID = m.topicId;
                            self.share.delegate = self;
                            self.sharedTopicID = m.topicId;
                            [self.share shareInfoForView:self.view];
                        };
                    }
                    /**
                     点击进入悦读详情
                     */
                    if (cell.blockYueDu == nil) {
                        cell.blockYueDu = ^(id data){
                            TopicModel *model = (TopicModel *)data;
                            NSDictionary *dict = [Utilities webLinkParamParser:model.linkUrl];
                            [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:dict];
                        };
                    }
                    
                    return cell;
                    
                }
                
            }else if(self.showIndex == 1){
                
                
                
                if (indexPath.row == 0) {
                    YGProfileFootprintHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGProfileFootprintHeaderCell" forIndexPath:indexPath];
                    cell.labelFootprintTimes.text = [NSString stringWithFormat:@"%d",self.userPlayedClubListModel.footprintCount];
                    NSLog(@"self.userPlayedClubListModel.playCount %d",self.userPlayedClubListModel.playCount);
                    cell.labelClubCount.text =  [NSString stringWithFormat:@"%d",self.userPlayedClubListModel.playCount];
                    
                    cell.blockClubTaped = ^(id data){
                        ygstrongify(self);
                        [self pushWithStoryboard:@"CourseRecord" title:@"打过的球场" identifier:@"CourseRecordViewController" completion:^(BaseNavController *controller) {
                            CourseRecordViewController *vc = (CourseRecordViewController *)controller;
                            vc.memberId = self.userDetail.memberId;
                            vc.userPlayedClubListModel = self.userPlayedClubListModel;
                        }];
                    };
                    cell.blockMapTaped = ^(id data){
                        ygstrongify(self);
                        FootPrintMapController *vc = [[FootPrintMapController alloc] init];
                        vc.isMapAll = YES;
                        vc.userPlayedClubListModel = self.userPlayedClubListModel;
                        vc.memberId = self.defaultMemberId;
                        [self pushViewController:vc title:@"足迹" hide:YES];
                    };
                    return cell;
                }
                
                if (indexPath.row == 1 && [self iamLogined]) {  //当前用户个人主页第一行是发布新动态的按钮
                    SimpleContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FabuCell" forIndexPath:indexPath];
                    [cell.btnAction setTitle:@" 添加新足迹" forState:(UIControlStateNormal)];
                    cell.blockReturn = ^(id data){
                        ygstrongify(self);
                        if ([self needPerfectMemberData]) {
                            return;
                        }
                        
                        SelectClubViewController *managementVC = [[self storyboard:@"Footprint"] instantiateViewControllerWithIdentifier:@"SelectClubViewController"];
                        managementVC.isNormalReleaseFootprint = YES;
                        [self pushViewController:managementVC title:@"选择球场" hide:YES];
                        
                    };
                    return cell;
                }
                
                if (_datas2.count == 0 && _hasMore2 == NO) {
                    SimpleContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyDatasCell" forIndexPath:indexPath];
                    cell.labelContent.text = ([self iamLogined]) ? @"暂未发布足迹":@"Ta还没有添加足迹";
                    return cell;
                }
                
                if (_datas2.count + ([self iamLogined] ? 2:1) == indexPath.row) {
                    return [tableView dequeueReusableCellWithIdentifier:(self.hasMore2 ? @"LoadingCell":@"AllLoadedCell") forIndexPath:indexPath];
                }
                
                
                if (_datas2.count > indexPath.row - ([self iamLogined] ? 2:1)) {
                    FootprintModel *m = _datas2[indexPath.row - ([self iamLogined] ? 2:1)];
                    FootprintTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(m.topicPictures.count > 0 ? @"FootprintImageCell":@"FootprintCell") forIndexPath:indexPath];
                    [self configureFootprintCell:cell atIndexPath:indexPath withData:m];
                    return cell;
                }
            }
        }
            break;
        default:
            break;
    }
    return [[UITableViewCell alloc] init];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return sectionView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollOffset = self.tableView.contentOffset.y;
    [sectionView changeBlur:scrollOffset >= 230 + 41 + academyHeight + tagHeight + signatureHeight - 64]; //230 是图片高度，section0Height是section0的高度。64是导航高度
    
    if (scrollOffset < 0){
        CGFloat f = 1 - (scrollOffset / 80);
        self.imageBg.transform = CGAffineTransformMakeScale(f, f);
    }else{
        self.imageBg.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
    
    if (scrollOffset >= 214) {
        [self.tableView setContentInset:(UIEdgeInsetsMake(64, 0, ([self iamLogined] ? 0:44), 0))];
        self.tableView.backgroundColor = [UIColor whiteColor];
    }else{
        [self.tableView setContentInset:(UIEdgeInsetsMake(0, 0, ([self iamLogined] ? 0:44), 0))];
        self.tableView.backgroundColor = [UIColor clearColor];
    }
    [self updateNaviTitle];
    if(scrollOffset > 120 && self.jz_navigationBarBackgroundAlpha != 1.f){
        [UIView animateWithDuration:0.3 animations:^{
            self.jz_navigationBarBackgroundAlpha = 1.f;
        } completion:^(BOOL finished) {
        }];
    }else if(scrollOffset < 120 && self.jz_navigationBarBackgroundAlpha != 0.f){
        [UIView animateWithDuration:0.3 animations:^{
            self.jz_navigationBarBackgroundAlpha = 0.f;
        } completion: ^(BOOL finished) {
        }];
    }
}

#pragma mark - 逻辑方法

- (void)toYGTeachingArchivePublishViewCtrl{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    YGPublishViewCtrl *vc = [YGPublishViewCtrl instanceFromStoryboard];
    vc.publishType = YGPublishTypeTopic;
    vc.taPublishBlock = ^(NSMutableDictionary *data){
        [self insertPublicTopicFirst:data];
    };
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)toTrendsDetailsViewController:(TopicModel *)m indexPath:(NSIndexPath *)indexPath{
    ygweakify(self)
    [TopicHelp toTrendsDetailsViewController:m indexPath:indexPath target:self blockDelete:^(id data) {
        TopicModel *d = (TopicModel *)data;
        ygstrongify(self)
        for (id obj in self.datas1) {
            if ([obj isKindOfClass:[TopicModel class]]) {
                TopicModel *mm = (TopicModel *)obj;
                if (mm.topicId == d.topicId) {
                    [self.datas1 removeObject:obj];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
                    break;
                }
            }
        }
    }];
}

- (void)toPersonalHomeControllerByMemberId:(int)memberId displayName:(NSString*)displayName{
    if (self.defaultMemberId != memberId) {
        YGProfileViewCtrl *vc = [YGProfileViewCtrl instanceFromStoryboard];
        vc.title = displayName;
        vc.memberId = memberId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)toFootprintDetails:(FootprintModel *)_ftModel isDetails:(BOOL)isDetails{
    
    if (_ftModel.scoreCard) {
        __weak YGProfileViewCtrl *weakSelf = self;
        
        [SVProgressHUD show];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            int memberId = _defaultMemberId != [LoginManager sharedManager].session.memberId ? self.userDetail.memberId : [LoginManager sharedManager].session.memberId;
            
            
            [[API shareInstance] cardInfo:_ftModel.scoreCard.cardId toMemberId:memberId success:^(CardInfo *data) {
                [weakSelf toFootprintDetailsViewController:_ftModel cardInfo:data isDetails:isDetails];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            } failure:^(Error *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            }];
        });
    }else{
        [self toFootprintDetailsViewController:_ftModel cardInfo:nil isDetails:isDetails];
    }
}

- (void)toFootprintDetailsViewController:(FootprintModel *)_ftModel cardInfo:(CardInfo *)data isDetails:(BOOL)isDetails{
    TopicModel *topicModel = [[TopicModel alloc] init];
    topicModel.memberId = _userDetail.memberId;
    topicModel.displayName = _userDetail.displayName;
    topicModel.headImage = _userDetail.headImage;
    //    topicModel.isFollowed = _userDetail.isFollowed;//lyf 加 足迹也需要isfollowd参数
    topicModel.topicContent = _ftModel.topicContent;
    
    topicModel.topicPictures = _ftModel.topicPictures;
    topicModel.clubId = _ftModel.clubId;
    topicModel.clubImageUrl = _ftModel.clubImage;
    topicModel.clubName = _ftModel.clubName;
    topicModel.teeDate = _ftModel.teeDate;
    topicModel.gross = _ftModel.gross;
    topicModel.praiseCount = _ftModel.praiseCount;
    topicModel.commentCount = _ftModel.commentCount;
    topicModel.scoreCards = _ftModel.scoreCards;
    topicModel.topicId = _ftModel.topicId;
    
    
    
    [self pushWithStoryboard:@"Footprint" title:@"足迹详情" identifier:@"FootprintDetialsViewController" completion:^(BaseNavController *controller) {
        FootprintDetialsViewController *vc = (FootprintDetialsViewController *)controller;
        vc.topicModel = topicModel;
        vc.isDetails = isDetails;
        vc.cardId = _ftModel.scoreCard.cardId;
        vc.footprintId = _ftModel.footprintId;
        vc.isShowOnlyMe = _ftModel.publicMode == 0;
        if (data) {
            vc.cardInfo = data;
        }
        
        vc.blockIsShowOnlyMeChanged = ^(NSDictionary *data){
            int fid = [data[@"footprintId"] intValue];
            int mode = [data[@"mode"] intValue];
            
            for (FootprintModel *model in _datas2) {
                if (model.footprintId == fid) {
                    model.publicMode = mode;
                    break;
                }
            }
            [self.tableView reloadData];
        };
        
        vc.blockDeleted = ^(id data){
            
            [SVProgressHUD show];
            [ServerService footprintDeleteWithSessionId:[[LoginManager sharedManager] getSessionId]
                                            footprintId:_ftModel.footprintId
                                                 clubId:_ftModel.clubId
                                                success:^(id data) {
                                                    [_datas2 removeObject:_ftModel];
                                                    [self.tableView reloadData];
                                                    [SVProgressHUD dismiss];
                                                } failure:^(id error) {
                                                    [SVProgressHUD showErrorWithStatus:@"足迹删除失败"];
                                                }];
            
            
        };
    }];
}


- (void)toPictureManageViewController:(BOOL)immediatelyShowPictureSelector{
    YGUserPictureListViewCtrl *vc = [YGUserPictureListViewCtrl instanceFromStoryboard];
    vc.isMine = [self iamLogined];
    vc.memberId = self.userDetail.memberId;
    vc.images = [NSMutableArray arrayWithArray:self.userDetail.imageList];
    vc.showAssetsPickerWithNoneImages = YES;
    [vc setUpdateCallback:^{
        [self loadUserDetailFromServer];
    }];
    [vc setDidDeletedPicture:^(NSArray *images) {
        self.userDetail.imageList = images;
        self.userDetail.photeImage = [self.userDetail.imageList.firstObject stringByReplacingOccurrencesOfString:@"_s." withString:@"_l."];
        [self loadUserDetail];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)toFootprintDetailsByTrendsModel:(TopicModel *)model{
    
    if (model && model.cardId > 0) {
        __weak YGProfileViewCtrl *weakSelf = self;
        
        [[API shareInstance] cardInfo:model.cardId toMemberId:model.memberId success:^(CardInfo *data) {
            [weakSelf pushWithStoryboard:@"Footprint" title:@"足迹详情" identifier:@"FootprintDetialsViewController" completion:^(BaseNavController *controller) {
                FootprintDetialsViewController *vc = (FootprintDetialsViewController *)controller;
                vc.topicModel = model;
                vc.isDetails = YES;
                vc.cardId = data.cardId;
                vc.footprintId = model.footprintId;
                if (data) {
                    vc.cardInfo = data;
                }
                
                vc.blockDeleted = ^(id data){
                    
                    [SVProgressHUD show];
                    [ServerService footprintDeleteWithSessionId:[[LoginManager sharedManager] getSessionId]
                                                    footprintId:model.footprintId
                                                         clubId:model.clubId
                                                        success:^(id data) {
                                                            //                                                    [self getFirstPage];
                                                            [weakSelf.tableView reloadData];
                                                            [SVProgressHUD dismiss];
                                                        } failure:^(id error) {
                                                            [SVProgressHUD showErrorWithStatus:@"足迹删除失败"];
                                                        }];
                    
                    
                };
            }];
        } failure:^(Error *error) {
        }];
    }
}


#pragma mark - 头像切换
- (IBAction)showHeaderImage:(id)sender {
    CGRect convertRect = [_imageHeader.superview convertRect:_imageHeader.frame toView:[GolfAppDelegate shareAppDelegate].window];
    
    if (self.userDetail.headImage.length > 0) {
        if ([self iamLogined]) {
            [ImageBrowser IBWithImages:@[self.userDetail.headImage] isCollection:NO currentIndex:0 initRt:convertRect isEdit:NO highQuality:YES vc:self actionTitle:@"更改头像" blockAction:^(id data){
                [self changeHeadPicture];
            } backRtBlock:^CGRect(NSInteger i) {
                return convertRect;
            } completion:nil];
        }else{
            [ImageBrowser IBWithImages:@[self.userDetail.headImage] isCollection:NO currentIndex:0 initRt:convertRect isEdit:NO highQuality:YES vc:self backRtBlock:^CGRect(NSInteger i) {
                return convertRect;
            } completion:nil];
        }
        
    }
}

- (void)changeHeadPicture
{
    [ImageBrowser hide];
    [YGSystemImagePicker presentSheetFrom:self modes:YGSystemImagePickerModes allowEditing:YES completion:^(UIImage *image) {
        [self handleCustomSelectImageWithSelectImage:image];
    }];
}

- (void)handleCustomSelectImageWithSelectImage:(UIImage *)aImage{
    
    ygweakify(self);
    [ServerService userEditInfo:[[LoginManager sharedManager] getSessionId]
                     memberName:nil
                       nickName:nil
                         gender:2
                  headImageData:[Utilities imageDataWithImage:aImage]
                 photoImageData:nil
                       birthday:nil
                      signature:nil
                       location:nil
                       handicap:-100
                    personalTag:nil
                      academyId:0
                      seniority:0
                   introduction:nil
              careerAchievement:nil
            teachingAchievement:nil
                        success:^(id arr) {
                            ygstrongify(self);
                            NSDictionary *dic = [arr objectAtIndex:0];
                            NSString *headImage = [dic objectForKey:@"head_image"];
                            if (headImage && headImage.length > 0) {
                                self.userDetail.headImage = headImage;
                                [LoginManager sharedManager].session.headImage = self.userDetail.headImage;
                                [self loadUserDetail];
                                
                                if (self.datas1.count > 0) {
                                    self.page1 = 1;
                                    self.pageSize = 10;
                                    self.hasMore = YES;
                                    [self getTopicList];
                                }
                            }
                        } failure:^(id error) {
                            
                        }];
    
    [_imageHeader setImage:[aImage applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.11 alpha:0.33] saturationDeltaFactor:1.8 maskImage:nil]];
    
    UIActivityIndicatorView *iv =[UIActivityIndicatorView autoLayoutView];
    [_imageHeader addSubview:iv];
    
    [iv centerInView:_imageHeader];
    iv.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [iv startAnimating];
}

#pragma mark - tableview高度单元格高度

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 40;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *nd = _section0Arr[indexPath.row];
            NSString *key = nd[@"key"];
            if ([key isEqualToString:@"signature"]) {
                
                CGFloat contentWidth = 0;
                
                if (IS_3_5_INCH_SCREEN || IS_4_0_INCH_SCREEN) {
                    contentWidth = 294;
                }else if(IS_4_7_INCH_SCREEN){
                    contentWidth = 349;
                }else if(IS_5_5_INCH_SCREEN) {
                    contentWidth = 388;
                }
                
                CGSize size = [self.userDetail.signature boundingRectWithSize:CGSizeMake(contentWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:14]} context:nil].size;
                CGFloat height = size.height + 11;
                signatureHeight = height;
                return height;
            }
            if ([key isEqualToString:@"personalTag"]) {
                
                if (tagHeight > 1) {
                    return tagHeight;
                }
                YGTagsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGTagsTableCell"];
                [cell configureWithTags:nd[@"value"]];
                tagHeight = [cell contentHeight];
                return tagHeight;
            }
            if ([key isEqualToString:@"academy"]) {
                academyHeight = 40;
                return 40;
            }
            if ([key isEqualToString:@"SectionCell"]) {
                return 10;
            }
        }
            break;
        case 1:
        {
            if (self.showIndex == 0) {
                if (_datas1.count == 0 && ![self iamLogined] && self.hasMore == NO) {
                    return 49;
                }
                if (_datas1.count + ([self iamLogined] ? 1:0) == indexPath.row) {
                    return 44;
                }
                if (indexPath.row == 0 && [self iamLogined]) {
                    return 74;
                }
                id modal = _datas1[[self iamLogined] ? indexPath.row - 1 : indexPath.row];
                if ([modal isKindOfClass:[TopicModel class]]) {
                    return [TopicHelp cellHeightWithData:modal topicType:0 hasDetail:YES refresh:self.refresh];
                }
            }else{
                
                if (indexPath.row == 0) {
                    return 76;
                }
                
                if (indexPath.row == 1 && [self iamLogined]) {
                    return 74;
                }
                
                if (_datas2.count + 2 + ([self iamLogined] ? 1:0) == indexPath.row) {
                    return 44;
                }
                
                if (_datas2.count > 0 && _datas2.count > (indexPath.row - ([self iamLogined] ? 2:1))) {
                    
                    FootprintModel *m = _datas2[indexPath.row - ([self iamLogined] ? 2:1)];
                    
                    int widthTitle = 0;
                    if (m.topicPictures.count > 0) {
                        if (IS_3_5_INCH_SCREEN || IS_4_0_INCH_SCREEN) {
                            widthTitle = 228;
                        }else if(IS_4_7_INCH_SCREEN){
                            widthTitle = 283;
                        }else if(IS_5_5_INCH_SCREEN){
                            widthTitle = 322;
                        }
                        CGSize size = [m.clubName boundingRectWithSize:CGSizeMake(widthTitle, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:16]} context:nil].size;
                        return size.height + 95;
                    }else{
                        int widthContent = 0;
                        if (IS_3_5_INCH_SCREEN || IS_4_0_INCH_SCREEN) {
                            widthContent = 228;
                            widthTitle = 228;
                        }else if(IS_4_7_INCH_SCREEN){
                            widthContent = 283;
                            widthTitle = 283;
                        }else if(IS_5_5_INCH_SCREEN){
                            widthContent = 322;
                            widthTitle = 322;
                        }
                        CGFloat titleHeight = [m.clubName boundingRectWithSize:CGSizeMake(widthTitle, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:16]} context:nil].size.height;
                        
                        CGFloat contentHeight = [m.topicContent boundingRectWithSize:CGSizeMake(widthTitle, 29) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:12]} context:nil].size.height;
                        return titleHeight + contentHeight + 40;
                    }
                    
                }else{
                    return 49;
                }
            }
            
        }
            break;
        default:
            break;
    }
    
    return 0;
}



- (void)configureFootprintCell:(FootprintTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withData:(FootprintModel *)m{
    UIColor *fontColor = [UIColor colorWithHexString:@"#333333"];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%tu",m.gross] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0],NSForegroundColorAttributeName:fontColor}];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"杆" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0],NSForegroundColorAttributeName:fontColor}]];
    cell.labelGanCount.attributedText = str;
    
    cell.labelDate.text = [Utilities getDateStringFromString:m.teeDate WithFormatter:@"MM月dd日"];
    cell.labelTitle.text = m.clubName;
    cell.labelContent.text = m.topicContent;
    if (m.topicPictures.count > 0) {
        [cell.imageFootprint sd_setImageWithURL:[NSURL URLWithString:m.topicPictures.firstObject] placeholderImage:self.defaultImage];
        cell.labelPictureCount.text = [NSString stringWithFormat:@"共%tu张",m.topicPictures.count];
    }
    cell.imageForm.image = imgForm;
    cell.imageLock.image = imgLock;
    cell.imageForm.hidden = m.scoreCard.cardId == 0;
    cell.imageLock.hidden = m.publicMode > 0;
    
    if (m.scoreCard.cardId > 0 && m.publicMode == 0) { //有积分卡也有上锁
        cell.constraintRight.constant = 48;
    }else if(m.scoreCard.cardId == 0 && m.publicMode == 1){ //没有积分卡又没有上锁
        cell.constraintRight.constant = 6;
    }else{  //左右有一种
        cell.constraintRight.constant = 29;
        if (m.scoreCard.cardId > 0) {
            cell.imageForm.image = imgForm;
        }else if(m.publicMode == 0){
            cell.imageForm.image = imgLock;
        }
        cell.imageLock.hidden = YES;
        cell.imageForm.hidden = NO;
    }
}




#pragma mark - tableviewcell事件



//图片浏览或者添加管理
- (IBAction)actionPictureManage:(id)sender {
    if ([self iamLogined]) {
        [self toPictureManageViewController:self.userDetail.photeImage.length <= 0];
    }else{
        if (self.userDetail.photeImage.length > 0) {
            CGRect rt = [_imageBg.superview convertRect:_imageBg.frame toView:[GolfAppDelegate shareAppDelegate].window];
            [ImageBrowser IBWithImages:self.userDetail.imageList isCollection:NO currentIndex:0 initRt:rt isEdit:NO highQuality:YES vc:self showCollectionView:YES blockCollectionView:^(id data){
                [ImageBrowser hide];
                [self toPictureManageViewController:NO];
            } backRtBlock:nil completion:nil];
        }
    }
}


- (void)zanActionWithModel:(TopicModel *)m tableViewCell:(UITableViewCell *)weakCell button:(UIButton *)btn {
    self.refresh = YES;
    [ServerService topicPraiseAdd:[[LoginManager sharedManager] getSessionId] topicId:m.topicId success:^(id data) {
        
        int memberId = [[LoginManager sharedManager] getUserId];
        int praiseCount = [[data valueForKeyPath:@"praise_count"] intValue];
        int praised =  [[data valueForKeyPath:@"praised"] intValue];
        
        m.praised = praised;
        m.praiseCount = praiseCount;
        
        NSString *headImage = [data valueForKeyPath:@"head_image"];
        if (praised == 1) {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:m.praiseList];
            [arr insertObject:@{@"member_id":@(memberId),@"head_image":headImage} atIndex:0];
            m.praiseList = arr;
        }else{
            NSArray *arr = [m.praiseList linq_where:^BOOL(id item) {
                return [[item valueForKeyPath:@"member_id"] intValue] != memberId;
            }];
            m.praiseList = arr;
        }
        
        NSDictionary *model = @{@"topicModel":m,@"api":@"topic_praise_add"};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTopicSignalCell" object:model];
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        self.refresh = NO;
        btn.userInteractionEnabled = YES;
    } failure:^(id error) {
        btn.userInteractionEnabled = YES;
        self.refresh = NO;
    }];
}

- (void)loadUserDetail{
    _loadingView.hidden = YES;
    if (self.userDetail.photeImage.length > 0) {
        [self.imageBg sd_setImageWithURL:[NSURL URLWithString:self.userDetail.photeImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.imageBg.hidden = NO;
        }];
        [self.btnAddPicture setTitle:@"" forState:(UIControlStateNormal)];
        [self.btnAddPicture setImage:nil forState:(UIControlStateNormal)];
    }else{
        if (self.userDetail.headImage.length > 0) { //如果没有头像则显示蓝天白云
            [self.imageBg sd_setImageWithURL:[NSURL URLWithString:self.userDetail.headImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                _imageBg.image = [image applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.11 alpha:0.33] saturationDeltaFactor:1.8 maskImage:nil];
                _imageBg.hidden = NO;
            }];
        }else{
            self.imageBg.image = [UIImage imageNamed:@"bg_PersonalHomepage_sky"];
            _imageBg.hidden = NO;
        }
        if ([self iamLogined]) {
            [self.btnAddPicture setImage:[UIImage imageNamed:@"ic_plus100"] forState:(UIControlStateNormal)];
            if (IS_3_5_INCH_SCREEN || IS_4_0_INCH_SCREEN) {
                [self.btnAddPicture setImageEdgeInsets:(UIEdgeInsetsMake(-27, 130, 0, 0 ))];
            }else if (IS_4_7_INCH_SCREEN){
                [self.btnAddPicture setImageEdgeInsets:(UIEdgeInsetsMake(-27, 153, 0, 0 ))];
            }else if (IS_5_5_INCH_SCREEN){
                [self.btnAddPicture setImageEdgeInsets:(UIEdgeInsetsMake(-27, 153, 0, 0 ))];
            }else{
                [self.btnAddPicture setImageEdgeInsets:(UIEdgeInsetsMake(-27, 153, 0, 0 ))];
            }
            
            [self.btnAddPicture setTitle:@"添加照片，获得更多关注" forState:(UIControlStateNormal)];
        }else{
            self.btnAddPicture.hidden = YES;
        }
    }
    
    self.labelFans.text = [NSString stringWithFormat:@"粉丝%d",self.userDetail.followedCount];
    self.labelAttion.text = [NSString stringWithFormat:@"关注%d",self.userDetail.followingCount];
    
    [[self.imageHeader subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
            [obj removeFromSuperview];
            *stop = YES;
        }
    }];
    [self.imageHeader sd_setImageWithURL:[NSURL URLWithString:self.userDetail.headImage] placeholderImage:[UIImage imageNamed:@"head_image"]];
    
    if (self.userDetail.gender == 2) {
        self.imageSex.hidden = YES;
        self.labelAge.backgroundColor = [UIColor clearColor];
        self.labelAge.textColor = [UIColor colorWithHexString:@"666666"];
        self.labelAge.font = [UIFont systemFontOfSize:12];
    }else{
        self.infomationConstraint.constant = 10;
        [self.labelInfo layoutIfNeeded];
        self.imageSex.hidden = NO;
        self.labelAge.hidden = NO;
        self.imageSex.image = [UIImage imageNamed:self.userDetail.gender == 1 ? @"ic_man":@"ic_woman"];
        UIColor *femaleColor = [UIColor colorWithRed:249/255.0 green:148/255.0 blue:171/255.0 alpha:1];
        UIColor *maleColor = [UIColor colorWithRed:151/255.0 green:188/255.0 blue:240/255.0 alpha:1];
        self.labelAge.backgroundColor = self.userDetail.gender == 1 ? maleColor:femaleColor;
    }
    
    
    if(self.userDetail.nickName.length == 0 || Equal(self.userDetail.nickName, self.userDetail.displayName)){
        self.labelName.text = self.userDetail.displayName;
    } else {
        self.labelName.text = [NSString stringWithFormat:@"%@ (%@)",self.userDetail.displayName,self.userDetail.nickName];
    }
    if (self.userDetail.birthday.length > 0) {
        if (self.userDetail.gender == 2) {
            self.labelAge.text = [NSString stringWithFormat:@" %d ",[Utilities agewithBirthday:self.userDetail.birthday]];
        }else{
            self.labelAge.text = [NSString stringWithFormat:@"      %d ",[Utilities agewithBirthday:self.userDetail.birthday]];
        }
    }else{
        if (self.userDetail.gender == 2) {
            self.labelAge.text = @"";
            self.infomationConstraint.constant = 0;
            [self.labelInfo layoutIfNeeded];
        }else{
            self.labelAge.text = @"      ";
        }
    }
    
    
    if (self.userDetail.handicap > -100) {
        self.labelInfo.text = [NSString stringWithFormat:@"差点%d  %@",self.userDetail.handicap,self.userDetail.location];
    }else{
        self.labelInfo.text = self.userDetail.location;
    }
    
    self.btnAttation.selected = (self.userDetail.isFollowed == 1 || self.userDetail.isFollowed == 4);
    
    UIImage *img = [Utilities imageOfUserType:self.userDetail.memberLevel];
    if (img) {
        self.btnLevel.hidden = NO;
        [self.btnLevel setImage:img forState:UIControlStateNormal];
    }else{
        self.btnLevel.hidden = YES;
    }
    if (self.userDetail.signature.length > 0 || self.userDetail.personalTag.length > 0) {
        self.line.hidden = YES;
    }else if (self.userDetail.academyId > 0){
        self.line.hidden = NO;
    }else{
        self.line.hidden = YES;
    }
}

- (void)loginWithGetFirstDatas{
    self.isOneDetailList = YES;
    
    self.page1 = 1;
    self.pageSize = 20;
    self.hasMore = YES;
    
    if ([[GolfAppDelegate shareAppDelegate] networkReachability]) {
        if (self.loading) {
            return;
        }
        self.loading = YES;
        
        ygweakify(self);
        [self getTopicListBySessionId:[[LoginManager sharedManager] getSessionId] tagId:0 tagName:nil memberId:_currentCellModel.memberId clubId:0 topicId:_currentCellModel.topicId topicType:0 pageNo:1 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude success:^(NSArray *list) {
            ygstrongify(self);
            [self topicListResultList:list];
        } failure:^(id error) {
            ygstrongify(self);
            self.loading = NO;
        }];
    }
}



- (void)judgeLoginAndPerfectAndIsFollowed {
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            [self loginWithGetFirstDatas];
        }];
        return;
    };
    if (_currentCellModel.isFollowed == -1) {
       [self loginWithGetFirstDatas];
        return;
    }
    if ([self needPerfectMemberData]) {
        return;
    }
    if (_isAttentionOrComment == 1) {
        [self clickedAttentionButton];
    } else if (_isAttentionOrComment == 2) {
        if (_currentCellModel.isFollowed == 3 || _currentCellModel.isFollowed == 6) {
            self.disabledChat = YES;
            [SVProgressHUD showInfoWithStatus:@"禁止评论"];
        } else {
            self.disabledChat = NO;
            [self reply_:_articleCommentModel];
        }
    } else if (_isAttentionOrComment == 3) {
        if (_currentCellModel.isFollowed == 3 || _currentCellModel.isFollowed == 6) {
            self.disabledChat = YES;
            [SVProgressHUD showInfoWithStatus:@"禁止评论"];
        } else {
            self.disabledChat = NO;
            [self.inputToolbar.contentView.textView becomeFirstResponder];
        }
    }
}


- (void)publishTopicFailured{
    for (TopicModel *m in _datas1) {
        if ([m isKindOfClass:[TopicModel class]]) {
            if ([@"发布中" isEqualToString:m.topicTime]) {
                m.topicTime = @"发布失败";
                [self.tableView reloadData];
                break;
            }
        }
    }
}


-(void)insertPublicTopicFirst:(NSMutableDictionary *)data{
    _tempMediaBean = data[@"MediaBean"];
    _tempLocation = data[@"location"];
    
    TopicModel *m = [[TopicModel alloc] init];
    m.memberId = [LoginManager sharedManager].session.memberId;
    m.memberLevel = [LoginManager sharedManager].session.memberLevel;
    m.displayName = [LoginManager sharedManager].session.displayName;
    m.headImage = [LoginManager sharedManager].session.headImage;
    m.topicTime = @"发布中";
    if (_tempLocation.location.length > 0) {
        m.clubName = _tempLocation.location;
    }
    if (_tempMediaBean.text.length > 0) {
        m.plainContent = [Utilities plainTextWithText:_tempMediaBean.text];
        m.topicContent = _tempMediaBean.text;
    }
    if (_tempMediaBean.dtype == 2) {
        m.topicVideo = _tempMediaBean.mediaList[0];
        m.topicPictures = @[_tempMediaBean.extraMedia[@"pic"]];
    }
    if (_tempMediaBean.dtype == 1) {
        m.topicPictures = _tempMediaBean.mediaList;
    }
 
    m.isTemp = YES;
    if (_datas1) {
        m.imageHeight = [TopicHelp heightWithImage:[m.topicPictures firstObject] hasVideo:(m.topicVideo && m.topicVideo.length > 0)];
        [_datas1 insertObject:m atIndex:0];
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}




#pragma mark - 关注和举报

- (IBAction)attentionAction:(id)sender{
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            [self userHeadImageListWithSender:sender];
        }];
        return;
    }
    if (_userDetail.isFollowed == -1) {
        [self userHeadImageListWithSender:sender];
        return;
    }
    switch (_userDetail.isFollowed) {
        case 1:
        case 4:
            _operationAboutFollow = 2;
            [self userFollowToMemberId:_userDetail.memberId nameRemark:nil operation:_operationAboutFollow];
            break;
        default:
            [self clickedAttentionButtonOrClickedAttentionAlertaction];
            break;
    }
}

- (void)userHeadImageListWithSender:(id)sender{
    [ServerService userHeadImageList:[LoginManager sharedManager].getSessionId memberIds:[NSString stringWithFormat:@"%d", _userDetail.memberId ] success:^(NSArray *list) {
        if (list && list.count > 0) {
            UserFollowModel *model = list[0];
            _userDetail.isFollowed = model.isFollowed;
        }
        [self attentionAction:sender];
    } failure:nil];
}

-(void)clickedAttentionButton {
    if (_currentCellModel.memberId == [LoginManager sharedManager].session.memberId) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除此条动态吗？删除后将无法恢复" message:nil preferredStyle: UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [ServerService topicDelete:[[LoginManager sharedManager] getSessionId]  topicId:_currentCellModel.topicId success:^(id data) {
                [SVProgressHUD showSuccessWithStatus:@"已删除"];
                NSDictionary *nd = @{@"topicModel":_currentCellModel ,@"api":@"topic_delete"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTopicSignalCell" object:nd];
                
            } failure:nil];
        }];
        [alert addAction:cancelAction];
        [alert addAction:deleteAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self showActionSheetControllerInTrends];
    }
}



- (void)clickedAttentionButtonOrClickedAttentionAlertaction {
    NSString *messageString;
    _operationAboutFollow = 1;
    if (_userDetail.isFollowed == 6) {
        [SVProgressHUD showInfoWithStatus:@"对方不允许你关注TA"];
        return;
    } else if (_userDetail.isFollowed == 3) {
        messageString = @"对方在你的黑名单中，需要先移出才能关注。确定移出吗？";
    } else if (_userDetail.isFollowed == 5) {
        messageString = @"确定将对方移出屏蔽名单，并且重新关注？点击\"确定\"，你将重新接收TA的动态";
    } else {
        [self userFollowToMemberId:_userDetail.memberId nameRemark:nil operation:_operationAboutFollow];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:messageString preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (_userDetail.isFollowed == 3) {
            self.willAttentionMustRemove = YES;//lyf 加
            _operationAboutFollow = 7;
        } else
            _operationAboutFollow = 1;
        [self userFollowToMemberId:_userDetail.memberId nameRemark:nil operation:_operationAboutFollow];
    }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showActionSheetControllerInTrends {
    NSString *followString = nil;
    NSString *shieldingString = nil;
    switch (_currentCellModel.isFollowed) {
        case 0:
        case 2:
            followString = @"加关注";
            shieldingString = @"不看此人动态";
            break;
        case 1:
        case 4:
            followString = @"取消关注";
            shieldingString = @"不看此人动态";
            break;
        case 3:
            followString = @"加关注";
            shieldingString = nil;
            break;
        case 5:
            followString = @"加关注";
            shieldingString = @"取消屏蔽";
            break;
        case 6:
            followString = @"加关注";
            shieldingString = nil;
            break;
        default:
            break;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:followString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([followString isEqualToString:@"加关注"]) {
            [self clickedAttentionButtonOrClickedAttentionAlertaction];
        } else {
            _operationAboutFollow = 2;
            [self userFollowToMemberId:_userDetail.memberId nameRemark:nil operation:_operationAboutFollow];
        }
    }]];
    if (shieldingString.length > 0) {
        [alertController addAction:[UIAlertAction actionWithTitle:shieldingString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *messageString;
            if ([shieldingString isEqualToString:@"不看此人动态"]) {
                _operationAboutFollow = 5;
                messageString = @"确定屏蔽此人动态吗？你将不再看到TA的动态。可以到\"我的-设置-不看此人动态\"中进行修改";
            } else {
                _operationAboutFollow = 6;
                messageString = @"确定重新接收此人动态吗？";
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:messageString preferredStyle: UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self userFollowToMemberId:_userDetail.memberId nameRemark:nil operation:_operationAboutFollow];
            }];
            [alert addAction:cancelAction];
            [alert addAction:deleteAction];
            [self presentViewController:alert animated:YES completion:nil];
        }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showJubaoActionSheetByTargetType:2 targetId:_currentCellModel.topicId];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)toChangeRemarkNameViewController{
    // 备注
    if (![LoginManager sharedManager].loginState) {
        ygweakify(self)
        self.loginHandleTag = @"userNoteName";
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            ygstrongify(self)
            [self _toChangeRemarkNameViewController];
        }];
        return;
    }
    [self _toChangeRemarkNameViewController];
}
- (void)_toChangeRemarkNameViewController{
    YGInputViewCtrl *vc = [YGInputViewCtrl instanceFromStoryboard];
    vc.title = @"备注";
    vc.isTextField = YES;
    vc.placeHolderText = @"请输入备注内容";
    vc.defaultText = self.userDetail.displayName.length > 0 ? self.userDetail.displayName : @"";
    vc.maxLength = 8;
    ygweakify(self)
    vc.blockReturn = ^(NSString *callBackString){
        ygstrongify(self)
        if (callBackString.length == 0 && [self.userDetail.displayName isEqualToString:self.userDetail.nickName]) {
            return;
        }
        
        [[YGUserRemarkCacheHelper shared] updateUserRemarkName:(callBackString.length > 0 ? callBackString : self.userDetail.nickName) memberId:self.defaultMemberId];
        
        if (callBackString.length > 0) {
            self.userDetail.displayName = callBackString;
        } else {
            self.userDetail.displayName = self.userDetail.nickName;
        }
        [self updateNaviTitle];
        
        for (TopicModel *tm in self.datas1) {
            tm.displayName = self.userDetail.displayName;
        }
        
        [self.tableView reloadData];
        
        self.labelName.text = self.userDetail.displayName;
        self.loginHandleTag = @"userNoteName";
        _operation = 3;
        [self userFollowToMemberId:_userDetail.memberId nameRemark:callBackString operation:_operation];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showActionSheetController {
    NSString *defriendString = @"加入黑名单";
    if (_userDetail.isFollowed == 3) {
        defriendString = @"移出黑名单";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"修改备注名" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self toChangeRemarkNameViewController];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:defriendString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *messageString;
        if ([defriendString isEqualToString:@"加入黑名单"]) {
            _operationAboutFollow = 4;
            messageString = @"确定将对方加入黑名单吗？你们相互无法看到对方的动态，并且不接收对方的私信及评论";
        } else {
            _operationAboutFollow = 7;
            messageString = @"确定将对方移出黑名单吗？TA将可以给你发送私信和评论";
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:messageString preferredStyle: UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self userFollowToMemberId:_userDetail.memberId nameRemark:nil operation:_operationAboutFollow];
        }];
        [alert addAction:cancelAction];
        [alert addAction:deleteAction];
        [self presentViewController:alert animated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([LoginManager sharedManager].loginState == NO || [[LoginManager sharedManager] getSessionId] == nil) {
            [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
                [self showJubaoActionSheetByTargetType:1 targetId:_defaultMemberId];
            } cancelReturn:^(id data) {
            }];
            return;
        }
        [self showJubaoActionSheetByTargetType:1 targetId:_defaultMemberId];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)loadUserDetailFromServer{
    @weakify(self)
    [ServerService userDetailByMemberId:_defaultMemberId mobilePhone:[[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone] sessionID:[LoginManager sharedManager].session.sessionId success:^(UserDetailModel *userDetail) {
        @strongify(self)
        self.userDetail = userDetail;
        [self loadUserDetail];
        [self.tableView reloadData];
        self.tableView.hidden = NO;
    } failure:^(id error) {
        
    }];
}


- (void)userFollowToMemberId:(int)memberId nameRemark:(NSString *)remark operation:(int)operation {
    [ServerService userFollowAddWithSessionId:[[LoginManager sharedManager] getSessionId] toMemberId:memberId nameRemark:remark operation:operation success:^(id dic) {
        if ([dic objectForKey:@"is_followed"]) {
            int operation = [dic[@"operation"] intValue];
            
            NSString *alertString;
            BOOL have = NO;
            switch (operation) {
                case 1:
                    if ([dic[@"is_followed"] intValue] == 6) {
                        alertString = @"对方不允许你关注TA";
                        have = NO;
                    } else {
                        alertString = @"关注成功";
                        [self loadUserDetailFromServer];
                        have = YES;
                    }
                    break;
                case 2:
                    alertString = @"已取消关注";
                    [self loadUserDetailFromServer];
                    have = NO;
                    break;
                case 3:
                    alertString = @"备注名修改成功";
                    have = YES;
                    break;
                case 4:
                    alertString = @"已加入黑名单";
                    have = YES;
                    break;
                case 5:
                    alertString = @"已屏蔽";
                    have = YES;
                    break;
                case 6:
                    alertString = @"已取消屏蔽";
                    have = YES;
                    break;
                case 7:{
                    if (_willAttentionMustRemove) {
                        self.willAttentionMustRemove = NO;
                        alertString = @"已移出，可重新关注";
                        have = NO;
                    } else {
                        alertString = @"已移出";
                        have = YES;
                    }
                    break;}
                default:
                    break;
            }
            self.userDetail.isFollowed = [[dic objectForKey:@"is_followed"] intValue];
            UserFollowModel *model = [[UserFollowModel alloc] init];
            model.memberId = self.userDetail.memberId;
            model.isFollowed = [dic[@"is_followed"] intValue];
            if (operation == 3) {
                model.displayName = self.userDetail.displayName;
            }
            NSDictionary *dictionary = @{@"flag":dic[@"operation"], @"data":model};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAttentList" object:dictionary];
            
            self.btnAttation.selected = (self.userDetail.isFollowed == 1 || self.userDetail.isFollowed == 4);
            
            if (_isSendMessage) {
                self.isSendMessage = NO;
                if (_userDetail.isFollowed == 6) {
                    [SVProgressHUD showInfoWithStatus:@"TA拒绝接收你的私信"];
                } else {
                    [self sendMessage];
                }
            }
            
            if (have) {
                [SVProgressHUD showSuccessWithStatus:alertString];
            }else{
                [SVProgressHUD showInfoWithStatus:alertString];
            }
            
            if (_blockFollow) {
                _blockFollow(model);
            }
            
            NSString *data = [[NSUserDefaults standardUserDefaults] objectForKey:KContactsPerson];
            if(data.length > 0) {
                NSArray *array = [data componentsSeparatedByString:@","];
                if(array.count>0) {
                    Person *person = [[Person alloc] init];
                    person.memberId = [[array objectAtIndex:0] intValue];
                    person.isFollowed = self.userDetail.isFollowed;
                    
                    data =[NSString stringWithFormat:@"%d,%d",person.memberId,person.isFollowed];
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:KContactsPerson];
                }
            }
        }
        if (_willAttentionMustRemove) {//黑名单状态下点加关注成功后提示语不一样，标记后若失败也要移除标记
            self.willAttentionMustRemove = NO;
        }
    } failure:nil];
}

- (void)showJubaoActionSheetByTargetType:(int)targetType targetId:(int)targetId{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"骚扰信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jubao:@"骚扰信息" targetType:targetType targetId:targetId];
    }];
    UIAlertAction *archiveAction1 = [UIAlertAction actionWithTitle:@"虚假信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jubao:@"虚假信息" targetType:targetType targetId:targetId];
    }];
    UIAlertAction *archiveAction2 = [UIAlertAction actionWithTitle:@"色情相关" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jubao:@"色情相关" targetType:targetType targetId:targetId];
    }];
    UIAlertAction *archiveAction3 = [UIAlertAction actionWithTitle:@"广告欺诈" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jubao:@"广告欺诈" targetType:targetType targetId:targetId];
    }];
    UIAlertAction *archiveAction4 = [UIAlertAction actionWithTitle:@"不当发言" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jubao:@"不当发言" targetType:targetType targetId:targetId];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:archiveAction];
    [alertController addAction:archiveAction1];
    [alertController addAction:archiveAction2];
    [alertController addAction:archiveAction3];
    [alertController addAction:archiveAction4];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)jubao:(NSString *)reason targetType:(int)type targetId:(int)targetId{
    [ServerService reportInfoAddWithImei:[OpenUDID value] sessionId:[[LoginManager sharedManager] getSessionId] reportReason:reason targetType:type targetId:targetId success:^(BOOL flag) {
        if (flag) {
            [SVProgressHUD showSuccessWithStatus:@"已举报"];
        }
    } failure:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"举报失败"];
    }];
}

#pragma mark -SharePackageDelegate
- (void)SharePackageRefreshTableviewCellShareImage:(NSDictionary *)dictionary judge:(JudgeShareImageBlock)judgeBlock{
    TopicModel *model;
    for (model in _datas1) {
        if ([model isKindOfClass:[TopicModel class]]) {
            if (model.topicId == _sharedTopicID) {
                break;
            }
        }
    }
    NSMutableArray *array=[[NSMutableArray alloc]initWithArray:model.shareList];
    JudgeShareImageBlock block = judgeBlock;
    if(block(array,[[LoginManager sharedManager] getUserId])){
        return;
    }
    NSDictionary *dic=@{@"head_image":dictionary[@"head_image"],@"member_id":@([[LoginManager sharedManager] getUserId])};
    [array insertObject:dic atIndex:0];
    model.shareList=array;
    model.shareCount=(int)array.count;
    
    NSDictionary *nd = @{@"topicModel":model,@"api":@"topic_share_add"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTopicSignalCell" object:nd];
}

#pragma mark - UIImage
- (UIImage *)ablongToSquareImage:(UIImage *)image image:(UIImage *)imageOther {
    CGSize size;
    CGSize imageSize=image.size;
    CGPoint point;
    if (imageSize.width/imageSize.height > 1) {
        point.x=(imageSize.height-imageSize.width)/2;
        point.y=0;
        size.height=imageSize.height;
        size.width=imageSize.height;
    }else{
        point.x=0;
        point.y=(imageSize.width-imageSize.height)/2;
        size.height=imageSize.width;
        size.width=imageSize.width;
    }
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(point.x, point.y, size.width-point.x*2, size.height-point.y*2);
    [image drawInRect:rect];
    CGFloat a = MIN(size.width, size.height)/2;
    [imageOther drawInRect:CGRectMake(a/2, a/2, a, a)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
