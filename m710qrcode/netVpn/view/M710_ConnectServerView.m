//
//  M710_ConnectServerView.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/25.
//

#import "M710_ConnectServerView.h"
#import "M710_ServerListController.h"

@interface M710_ConnectServerView ()

@property (nonatomic ,strong) UIImageView *countryImg;
@property (nonatomic ,strong) UILabel *nameLab;

@end

@implementation M710_ConnectServerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview_layout];
    }
    return self;
}

-(void)setVpnModel:(Expert_ServerVPNModel *)vpnModel{
    if (vpnModel) {
        _vpnModel = vpnModel;
        self.countryImg.image = [UIImage imageNamed:[vpnModel.icon uppercaseString]];
        self.nameLab.text = vpnModel.expert_alisaName;
    }
}

- (void)moreClick:(UIButton *)button{
    M710_ServerListController *vc = [[M710_ServerListController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [[self currentController].navigationController pushViewController:vc animated:YES];
}

- (void)addSubview_layout{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 10.f;
    
    self.countryImg = [[UIImageView alloc] init];
    self.countryImg.backgroundColor = [UIColor redColor];
    [self addSubview:self.countryImg];
    [self.countryImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(15);
        make.width.height.mas_equalTo(44);
    }];
    self.countryImg.layer.cornerRadius = 22.f;
    self.countryImg.layer.masksToBounds = YES;
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn setImage:[UIImage imageNamed:@"server_more"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(22);
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-15);
    }];
    
    self.nameLab = [[UILabel alloc] init];
    self.nameLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    self.nameLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.countryImg.mas_right).offset(10);
        make.centerY.equalTo(self);
    }];
}

@end
