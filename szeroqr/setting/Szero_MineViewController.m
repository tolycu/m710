//
//  Szero_MineViewController.m
//  szeroqr
//
//  Created by xc-76 on 2022/4/21.
//

#import "Szero_MineViewController.h"
#import "SettingViewCell.h"
#import "Szero_AboutViewController.h"
#import "Szero_RateView.h"
#import "Szero_ClearCacheView.h"

@interface Szero_MineViewController ()<UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSArray *dataList;

//底部横幅广告
@property(nonatomic,strong) ADConfigModel *bannerModel;
@property(nonatomic,strong) GADBannerView *bannerView;
@property(nonatomic,strong) NSTimer *loadTimer;
@property(nonatomic,assign) NSInteger longTime; //检测广告时长 30s

@end

@implementation Szero_MineViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showBannerAD];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [FIRAnalytics logEventWithName:show_settings parameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeFlash) name:App_CloseFlash object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self closeFlash];
}

- (void)closeFlash{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    SettingViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.switchBtn.on = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingViewCell" forIndexPath:indexPath];
    cell.dict = self.dataList[indexPath.section];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor colorWithString:@"#FAFAFA"];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 5) {
        Szero_AboutViewController *vc = [[Szero_AboutViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 3){
        [[Szero_RateView new] show];
    }else if (indexPath.section == 4){
        Szero_ClearCacheView *alterView = [[Szero_ClearCacheView alloc] initWithFrame:CGRectZero title:@"Clear Cache" des:@"Clearing the cache will clear your unsaved QR code history and usage track !" btns:YES];
        alterView.yesCompletionHandler = ^{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Scan_History"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Creat_History"];
        };
        [alterView show];
    }else if (indexPath.section == 2){
        [TOOL_MANAGE startShare];
    }
}



- (void)addSubView_layout{
    [self hideBackItem];
    [self setTitleStr:@"Settings"];
    
    self.dataList = @[@{@"img":@"set_history",@"title":@"Save History",@"isSwitch":@(YES)},
                      @{@"img":@"set_flash",@"title":@"Flashlight",@"isSwitch":@(YES)},
                      @{@"img":@"set_share",@"title":@"Share with Friend",@"isSwitch":@(NO)},
                      @{@"img":@"set_star",@"title":@"Rate",@"isSwitch":@(NO)},
                      @{@"img":@"set_clear",@"title":@"Clear Cache",@"isSwitch":@(NO)},
                      @{@"img":@"set_aboutUs",@"title":@"About Us",@"isSwitch":@(NO)},];
    
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 55.f;
        _tableView.sectionHeaderHeight = 0.f;
        _tableView.sectionFooterHeight = 10.f;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[SettingViewCell class] forCellReuseIdentifier:@"SettingViewCell"];
    }
    return _tableView;
}

#pragma mark - 底部广告
- (void)showBannerAD{
    if (!self.loadTimer) {
        self.longTime = 0;
        self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadShowBannerAD) userInfo:nil repeats:YES];
    }
}

- (void)loadShowBannerAD{
    self.longTime = +2;
    if (self.longTime > 30 && self.loadTimer) {
        [self.loadTimer invalidate];
        self.loadTimer = nil;
    }
    
    self.bannerModel = [ADConfigSetting filterADPosition:ADPositionType_home];
    if (!self.bannerModel) {
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
        }];
        return;
    }
    [self.loadTimer invalidate];
    self.loadTimer = nil;
    ADDataType temp = [ADConfigSetting getLoadADtype:self.bannerModel.model.expert_type];
    if(temp == ADDataType_banner &&
       [NSStringFromClass([self.bannerModel.requestAD class]) isEqualToString:@"GADBannerView"]){
        self.bannerView = (GADBannerView *)self.bannerModel.requestAD;
        self.bannerView.rootViewController = [self currentController];
        self.bannerView.delegate = self;
        [self.view addSubview:self.bannerView];
        [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-10);
            make.height.mas_equalTo(50);
        }];
        
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-60);
        }];
    }
}

- (void)bannerViewDidRecordClick:(nonnull GADBannerView *)bannerView{
    [ADConfigSetting clickADWithAddLimitForkey:APP_Banner_Count];
    if (![ADConfigSetting isLimitShowADWithAllowForkey:APP_Banner_Count]) {
        self.bannerView.hidden = YES;
        [self.bannerView removeFromSuperview];
    }
}

@end
