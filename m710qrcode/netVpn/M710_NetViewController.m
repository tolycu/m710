//
//  M710_NetViewController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "M710_NetViewController.h"
#import "M710_VpnResultController.h"
#import "M710_ServerListController.h"
#import "HomeAdapter.h"
#import "SOneVPTool.h"
#import "SOneVPManage.h"
#import "M710_ClearCacheView.h"
#import "M710_VpnConnectView.h"
#import "M710_ConnectServerView.h"
#import "M710_ConnectTypeView.h"
#import "Sport_PrivacyView.h"

@interface M710_NetViewController ()<SOneVPManageDelegate>

@property (nonatomic ,strong) HomeAdapter *adapter;
@property (nonatomic ,assign) BOOL connectIndex;
@property (nonatomic ,strong) UILabel *statusLab;
@property (nonatomic ,strong) M710_ConnectServerView *serverView;

@property (nonatomic ,assign) VPConnectMode mode;

@end

@implementation M710_NetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.connectIndex = 0;
    self.mode = SOneVPConnectModeAUTO;
    [self addSubView_layout];
    [self loadBaseConfig];
    [self becomActive];
}

- (void)loadBaseConfig{
    [self updateConnectServer:Adapter_MANAGE.bestServer];
    [SOneVPManage sharedInstance].delegate = self;
    [SOneVPManage sharedInstance].providerBundleIdentifier = @"iqr.expert.qrcode.PacketTunnel";
    [Adapter_MANAGE addObserver:self forKeyPath:@"bestServer" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectAction) name:Current_Connect_Model object:nil];
}

- (void)becomActive{
    [[SOneVPManage sharedInstance] getConnectStatusWithCompletionHandler:^(NEVPNStatus status, VPConnectMode mode) {
        [TOOL_MANAGE changeVpnStatue:status];
        if (status == NEVPNStatusConnected){
            NSDictionary *tempDict = [[NSUserDefaults standardUserDefaults] objectForKey:History_Connect_VPNS];
            Expert_ServerVPNModel *historyModel = [Expert_ServerVPNModel mj_objectWithKeyValues:tempDict];
            [Adapter_MANAGE changeBestServer:historyModel];
        }
    }];
}

- (void)checkPrivacy{
    BOOL isAgress = [NSUserDefaults jk_boolForKey:APP_Privacy_Agree];
    if (isAgress) {
        [self connectClick];
    }else{
        Sport_PrivacyView *vc = [[Sport_PrivacyView alloc] init];
        [vc show];
        vc.nextBlock = ^{
            [self connectClick];
        };
    }
}


- (void)connectClick{
    if (TOOL_MANAGE.status == NEVPNStatusConnecting ||
        TOOL_MANAGE.status == NEVPNStatusConnected ||
        TOOL_MANAGE.status == NEVPNStatusDisconnecting) {
        M710_ClearCacheView *alterView = [[M710_ClearCacheView alloc] initWithFrame:CGRectZero title:@"Notice" des:@"You will close the current connection,Please confirm whether to close？" btns:YES];
        alterView.yesCompletionHandler = ^{
            if (TOOL_MANAGE.status == NEVPNStatusConnecting ||
                TOOL_MANAGE.status == NEVPNStatusDisconnecting) {
                [[SOneVPManage sharedInstance] stopConnectWithCompletionHandler:^(BOOL stopSuccess, NEVPNStatus status, NSError * _Nullable error) {
                    if (stopSuccess) {
                        [TOOL_MANAGE changeVpnStatue:status];
                    }
                }];
            }else{
                [self disConnectWithCompletionHandler:nil];
            }
        };
        [alterView show];
    }else{
        [self connectAction];
    }
}

- (void)connectAction {
    
    if (!Adapter_MANAGE.bestServer) {
        [self.view makeToast:@"The server is not ready,try again later."];
        return;
    }

    if ([[Adapter_MANAGE.country_short uppercaseString] isEqualToString:@"CN"]) {
        M710_ClearCacheView *alterView = [[M710_ClearCacheView alloc] initWithFrame:CGRectZero title:@"Notice" des:@"Sorry, due to policy reasons, this function is temporarily unavailable in China, please understand, thank you!" btns:NO];
        [alterView show];
        return;
    }
    [SOneVPManage checkAuthorStatusWithCompletionHandler:^(BOOL isAuthor) {
        NSLog(@"vpn 授权");
    }];
    
    [TOOL_MANAGE changeVpnStatue:NEVPNStatusConnecting];
    [[SOneVPManage sharedInstance] connectWithServerHost:Adapter_MANAGE.bestServer.expert_host openvpPort:Adapter_MANAGE.bestServer.expert_oports mode:(self.mode) completionHandler:^(BOOL connectSuccess, NEVPNStatus status, NSError * _Nullable error) {
        [TOOL_MANAGE changeVpnStatue:status];
        if (connectSuccess) {
            if (status == NEVPNStatusConnected) {
                [NSUserDefaults jk_setObject:[Adapter_MANAGE.bestServer mj_JSONObject] forKey:History_Connect_VPNS];
                [self pushConnectReport:YES];

                [self.adapter uploadCurrentServersStatusWithModel:Adapter_MANAGE.bestServer connectInfos:[[SOneVPManage sharedInstance] connectInfo] CompletionHandler:^(BOOL success, NSError * _Nonnull error) {
                    NSLog(@"上报VPS");
                }];
            }
        }else{
            if (status != NEVPNStatusInvalid) {
                [self pushConnectReport:NO];
            } else{
                if (self.connectIndex == 0) {
                    self.connectIndex = 1;
                    [self connectAction];
                }
            }
        }
    }];
}

- (void)disConnectWithCompletionHandler:(void(^)(BOOL success))completionHandler{
    [TOOL_MANAGE changeVpnStatue:NEVPNStatusDisconnecting];
    [[SOneVPManage sharedInstance] stopConnectWithCompletionHandler:^(BOOL stopSuccess, NEVPNStatus status, NSError * _Nullable error) {
        if (stopSuccess) {
            [TOOL_MANAGE changeVpnStatue:status];
            if (completionHandler) {
                completionHandler(YES);
            }
            [self pushConnectReport:NO];
        }else{
            [self.view makeToast:@"Disconnect failed"];
        }
    }];
}

- (void)pushConnectReport:(BOOL)isSuccess{
    M710_VpnResultController *vc = [[M710_VpnResultController alloc] init];
    vc.isSuccess = isSuccess;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(TOOL_MANAGE.status != NEVPNStatusConnected){
        [self updateConnectServer:Adapter_MANAGE.bestServer];
    }
}

- (void)updateConnectServer:(Expert_ServerVPNModel *)vpnModel{
    self.serverView.vpnModel = vpnModel;
}

- (void)addSubView_layout{
    [self hideBackItem];
    [self setTitleStr:@"Net Tool"];
    
    self.statusLab = [[UILabel alloc] init];
    self.statusLab.font = [UIFont systemFontOfSize:21 weight:UIFontWeightMedium];
    self.statusLab.textColor = [UIColor colorWithString:@"#52CCBB"];
    self.statusLab.text = @"Not connected";
    [self.view addSubview:self.statusLab];
    [self.statusLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).mas_equalTo(kScaleWidth(50)+TOP_HEIGHT);
    }];
    
    M710_VpnConnectView *connectView = [[M710_VpnConnectView alloc] init];
    [connectView jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [self checkPrivacy];
    }];
    [self.view addSubview:connectView];
    [connectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+150);
        make.width.mas_equalTo(kScaleWidth(235));
        make.height.mas_equalTo(kScaleWidth(128));
    }];
    
    M710_ConnectServerView *serverView = [[M710_ConnectServerView alloc] init];
    [self.view addSubview:serverView];
    self.serverView = serverView;
    [serverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(connectView.mas_bottom).offset(kScaleWidth(100));
        make.height.mas_equalTo(55);
    }];
    
    M710_ConnectTypeView *typeView = [[M710_ConnectTypeView alloc] init];
    typeView.selectCompletionHandler = ^(VPConnectMode mode) {
        self.mode = mode;
        [self connectAction];
    };
    [self.view addSubview:typeView];
    [typeView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(serverView.mas_bottom).offset(10);
        make.height.mas_equalTo(55);
    }];
}

#pragma mark - HFVPManagerDelegate
- (BOOL)vpnFunctionEnable {
    // 根据国家定位的编码判断
    return YES;
}

- (BOOL)exitAppWhenVPNNullable {
    return NO;
}

- (void)vpnManagerStatus:(NEVPNStatus)status {
    if (status == NEVPNStatusConnected) {
        self.statusLab.text = @"Connected";
    }else if (status == NEVPNStatusConnecting){
        self.statusLab.text = @"Connecting";
    }else if (status == NEVPNStatusDisconnecting){
        self.statusLab.text = @"Disconnecting";
    }else{
        self.statusLab.text = @"Not connected";
    }
}
     
-(HomeAdapter *)adapter{
   if (!_adapter) {
    _adapter = [[HomeAdapter alloc] init];
   }
   return _adapter;
}
@end
