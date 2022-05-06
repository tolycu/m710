//
//  M710_NetViewController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "M710_NetViewController.h"
#import "M710_VpnResultController.h"
#import "M710_ServerListController.h"

#import "M710_VpnConnectView.h"
#import "M710_ConnectServerView.h"
#import "M710_ConnectTypeView.h"

@interface M710_NetViewController ()

@property (nonatomic ,strong) UILabel *statusLab;

@end

@implementation M710_NetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
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
        [TOOL_MANAGE changeVpnStatue:NEVPNStatusConnecting];
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
    [serverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(connectView.mas_bottom).offset(kScaleWidth(100));
        make.height.mas_equalTo(55);
    }];
    
    M710_ConnectTypeView *typeView = [[M710_ConnectTypeView alloc] init];
    [self.view addSubview:typeView];
    [typeView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(serverView.mas_bottom).offset(10);
        make.height.mas_equalTo(55);
    }];
    
    
}


@end
