//
//  M710_VpnResultController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/25.
//

#import "M710_VpnResultController.h"
#import "HomeAdapter.h"

@interface M710_VpnResultController ()

@property (nonatomic ,strong) Expert_ServerVPNModel *serverModel;

@end

@implementation M710_VpnResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serverModel = Adapter_MANAGE.bestServer;
    [self addSubView_layout];
}

- (void)addSubView_layout{
    [self setTitleStr:@"Net Tool"];
    
    UILabel *statusLab = [[UILabel alloc] init];
    statusLab.font = [UIFont systemFontOfSize:21 weight:UIFontWeightMedium];
    statusLab.textColor = [UIColor colorWithString:@"#52CCBB"];
    statusLab.numberOfLines = 0;
    statusLab.textAlignment = NSTextAlignmentCenter;
    statusLab.text = self.isSuccess?@"Connection succeeded!":@"Connection failed,\nplease try again later!";
    [self.view addSubview:statusLab];
    [statusLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).mas_equalTo(kScaleWidth(50)+TOP_HEIGHT);
    }];
    
    UIImageView *statusImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.isSuccess?@"result_success":@"result_failer"]];
    [self.view addSubview:statusImg];
    [statusImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScaleWidth(224));
        make.height.mas_equalTo(kScaleWidth(128));
        make.centerX.equalTo(self.view);
        make.top.equalTo(statusLab.mas_bottom).offset(40);
    }];
    
    UILabel *ipLab = [[UILabel alloc] init];
    ipLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    ipLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    ipLab.text = [NSString stringWithFormat: @"IP: %@",self.serverModel.expert_host];
    [self.view addSubview:ipLab];
    [ipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(statusImg.mas_bottom).offset(40);
    }];
    
    UILabel *nameLab = [[UILabel alloc] init];
    nameLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    nameLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    nameLab.text = [NSString stringWithFormat: @"Node：%@",self.serverModel.expert_alisaName];
    [self.view addSubview:nameLab];
    [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(ipLab.mas_bottom).offset(10);
    }];
}

@end
