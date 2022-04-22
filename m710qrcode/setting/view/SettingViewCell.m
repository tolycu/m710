//
//  SettingViewCell.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/22.
//

#import "SettingViewCell.h"

@interface SettingViewCell ()

@property (nonatomic ,strong) UIImageView *icon;
@property (nonatomic ,strong) UILabel *titleLab;
@property (nonatomic ,strong) UISwitch *switchBtn;
@property (nonatomic ,strong) UIImageView *rightImg;

@end

@implementation SettingViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubView_layout];
    }
    return self;
}

- (void)switchChange:(UISwitch*)sw {
    if(sw.on == YES) {
        NSLog(@"开关切换为开");
    } else if(sw.on == NO) {
        NSLog(@"开关切换为关");
    }
}

- (void)addSubView_layout{
    self.contentView.layer.cornerRadius = 10.f;
    self.contentView.layer.masksToBounds = YES;
    
    self.icon = [[UIImageView alloc] init];
    [self.contentView addSubview:self.icon];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(22);
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(17);
    }];
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.font = [UIFont systemFontOfSize:12];
    self.titleLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    [self.contentView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(10);
    }];
    
    self.rightImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    [self.contentView addSubview:self.rightImg];
    [self.rightImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(24);
    }];
    
    self.switchBtn = [[UISwitch alloc] init];
    [self.switchBtn setOnTintColor: [UIColor colorWithString:@"#52CCBB"]];
    [self.switchBtn setThumbTintColor: [UIColor colorWithString:@"#F0F0F0"]];
    [self.switchBtn setTintColor:[UIColor grayColor]];
    self.switchBtn.on = NO;
    [self.switchBtn addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.switchBtn];
}
@end
