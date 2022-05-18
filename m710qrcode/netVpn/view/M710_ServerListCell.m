//
//  M710_ServerListCell.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/25.
//

#import "M710_ServerListCell.h"

@interface M710_ServerListCell ()

@property (nonatomic ,strong) UIImageView *countryImg;
@property (nonatomic ,strong) UILabel *nameLab;
@property (nonatomic ,strong) UILabel *ipLab;
@property (nonatomic ,strong) UIButton *statusBtn;
@property (nonatomic ,strong) UILabel *pingLab;

@end


@implementation M710_ServerListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview_layout];
    }
    return self;
}

- (void)setVpnModel:(Expert_ServerVPNModel *)vpnModel{
    if (vpnModel) {
        _vpnModel = vpnModel;
        self.countryImg.image = [UIImage imageNamed:[vpnModel.icon uppercaseString]];
        self.nameLab.text = vpnModel.expert_alisaName;
        self.ipLab.text = vpnModel.expert_host;
        NSString *pingStr = vpnModel.ping>0?[NSString stringWithFormat:@"%d",vpnModel.ping]:@"N/A";
        self.pingLab.text = pingStr;
        [self changePingTextColorWithPing:vpnModel.ping];
        self.statusBtn.selected = [TOOL_MANAGE checkoutSelect:vpnModel];
    }
}

- (void)changePingTextColorWithPing:(int)ping{
    if (ping > 0 && ping < 221) {
        self.pingLab.textColor = [UIColor colorWithString:@"#52ccbb"];
    }else if (ping >220 && ping < 501){
        self.pingLab.textColor = [UIColor colorWithString:@"#ffea00"];
    }else if (ping >500 && ping < 1001){
        self.pingLab.textColor = [UIColor colorWithString:@"#ffa250"];
    }else{
        self.pingLab.textColor = [UIColor colorWithString:@"#ff5050"];
    }
}

- (void)addSubview_layout{
    
    self.contentView.layer.cornerRadius = 10.f;
    self.contentView.layer.masksToBounds = YES;
    
    self.countryImg = [[UIImageView alloc] init];
    [self.contentView addSubview:self.countryImg];
    [self.countryImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(44);
        make.left.equalTo(self.contentView).offset(15);
        make.centerY.equalTo(self.contentView);
    }];
    self.countryImg.layer.cornerRadius = 22.f;
    self.countryImg.layer.masksToBounds = YES;

    self.nameLab = [[UILabel alloc] init];
    self.nameLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    self.nameLab.text = @"US - New York";
    self.nameLab.font = [UIFont systemFontOfSize:14.f];
    [self.contentView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_centerY).offset(-2);
        make.left.equalTo(self.countryImg.mas_right).offset(10);
    }];
    
    UILabel *ipTitleLab = [[UILabel alloc] init];
    ipTitleLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    ipTitleLab.text = @"IP：";
    ipTitleLab.font = [UIFont systemFontOfSize:14.f];
    [self.contentView addSubview:ipTitleLab];
    [ipTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_centerY).offset(2);
        make.left.equalTo(self.nameLab);
    }];
    
    self.ipLab = [[UILabel alloc] init];
    self.ipLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    self.ipLab.text = @"192.168.1.1";
    self.ipLab.font = [UIFont systemFontOfSize:14.f];
    [self.contentView addSubview:self.ipLab];
    [self.ipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(ipTitleLab);
        make.left.equalTo(ipTitleLab.mas_right).offset(2);
    }];
    
    self.statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.statusBtn setImage:[UIImage imageNamed:@"i_unselected"] forState:UIControlStateNormal];
    [self.statusBtn setImage:[UIImage imageNamed:@"i_checked"] forState:UIControlStateSelected];
    [self.contentView addSubview:self.statusBtn];
    [self.statusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-20);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(14);
    }];
    
    UIImageView *infoImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"server_info"]];
    [self.contentView addSubview:infoImg];
    [infoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.statusBtn).offset(-80);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(8);
    }];
    
    self.pingLab = [[UILabel alloc] init];
    self.pingLab.font = [UIFont systemFontOfSize:12];
    self.pingLab.textColor = [UIColor colorWithString:@"#52CCBB"];
    [self.contentView addSubview:self.pingLab];
    [self.pingLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(infoImg);
        make.left.equalTo(infoImg.mas_right).offset(2);
    }];
    
}

@end
