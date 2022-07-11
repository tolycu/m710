//
//  Szero_HistoryViewController.m
//  szeroqr
//
//  Created by xc-76 on 2022/4/21.
//

#import "Szero_HistoryViewController.h"
#import "Szero_ScanResultController.h"
#import "Szero_CreatResultController.h"

#import "Szero_HistoryCellView.h"
#import "SelectNavgidueView.h"


@interface Szero_HistoryViewController ()<UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray *dataList;
@property (nonatomic ,assign) NSInteger index;

//底部横幅广告
@property(nonatomic,strong) ADConfigModel *bannerModel;
@property(nonatomic,strong) GADBannerView *bannerView;
@property(nonatomic,strong) NSTimer *loadTimer;
@property(nonatomic,assign) NSInteger longTime; //检测广告时长 30s

@end

@implementation Szero_HistoryViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showBannerAD];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [FIRAnalytics logEventWithName:show_history parameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
    [self reloadDataList];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Szero_HistoryCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"Szero_HistoryCellView" forIndexPath:indexPath];
    cell.dataDict = self.dataList[indexPath.section];
    cell.deleteBlock = ^{
        [self deleteHistoryAtIndexPath:indexPath];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor colorWithString:@"#FAFAFA"];
    return footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *resultStr = self.dataList[indexPath.section][@"resultStr"];
    NSString *dateStr = self.dataList[indexPath.section][@"dateStr"];
    
    [self showFinishAD];
    
    if (self.index) {
        Szero_ScanResultController *vc = [[Szero_ScanResultController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.resultStr = resultStr;
        vc.dateStr = dateStr;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        Szero_CreatResultController *vc = [[Szero_CreatResultController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.resultStr = resultStr;
        vc.dateStr = dateStr;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)addSubView_layout{
    [self hideBackItem];
    [self setTitleStr:@"History"];
    
    SelectNavgidueView *headerView = [[SelectNavgidueView alloc] initWithFrame:CGRectZero leftTitle:@"Generate History " rightTitle:@"Scan History"];
    headerView.selectBlock = ^(NSInteger index) {
        self.index = index;
        [self reloadDataList];
    };
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(TOP_HEIGHT+10);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(35);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.top.equalTo(headerView.mas_bottom).offset(10);
    }];
}

- (void)reloadDataList{
    [self.dataList removeAllObjects];
    if (self.index) {
        [self.dataList addObjectsFromArray:[NSUserDefaults jk_arrayForKey:@"Scan_History"]];
    }else{
        [self.dataList addObjectsFromArray:[NSUserDefaults jk_arrayForKey:@"Creat_History"]];
    }
    [self.tableView reloadData];
}

- (void)deleteHistoryAtIndexPath:(NSIndexPath *)indexPath{
    if (self.index) {
        [self.dataList removeObjectAtIndex:indexPath.section];
        [NSUserDefaults jk_setObject:self.dataList.copy forKey:@"Scan_History"];
        [self.tableView reloadData];
    }else{
        [self.dataList removeObjectAtIndex:indexPath.section];
        [NSUserDefaults jk_setObject:self.dataList.copy forKey:@"Creat_History"];
        [self.tableView reloadData];
    }
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 100;
        _tableView.sectionFooterHeight = 5.f;
        _tableView.sectionHeaderHeight = 0.f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[Szero_HistoryCellView class] forCellReuseIdentifier:@"Szero_HistoryCellView"];
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

#pragma mark - 完成广告
- (void)showFinishAD{
    ADConfigModel *configModel = [ADConfigSetting filterADPosition:ADPositionType_finish];
    if (!configModel) {return; }
    [FIRAnalytics logEventWithName:ShowFinishAds parameters:@{@"id":configModel.model.expert_placeId}];
    ADDataType adType = [ADConfigSetting getLoadADtype:configModel.model.expert_type];
    if (adType == ADDataType_int && [NSStringFromClass([configModel.requestAD class]) isEqualToString:@"GADInterstitialAd"]){
        GADInterstitialAd *interstitial = (GADInterstitialAd *)configModel.requestAD;
        [interstitial presentFromRootViewController:self];
        configModel.requestAD = nil;
        [AD_MANAGE resetADConfigManage];
    }
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
        self.bannerView.rootViewController = self;
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
