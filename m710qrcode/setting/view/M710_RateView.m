//
//  M710_RateView.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/24.
//

#import "M710_RateView.h"

@interface M710_RateView ()

@property (nonatomic ,strong) NSMutableArray<UIButton *> *stars;
@property (nonatomic ,assign) NSInteger index;

@end

@implementation M710_RateView

- (instancetype)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, XCScreenW, XCScreenH);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self setSubViewsConfig];
    }
    return self;
}

- (void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)setSubViewsConfig{
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(kScaleWidth(320));
        make.height.equalTo(@260);
    }];
    contentView.layer.cornerRadius = 20.f;
    contentView.layer.masksToBounds = YES;
    
    UIImageView *logoImg = [[UIImageView alloc] init];
    logoImg.image = [UIImage imageNamed:@"set_aboutUs"];
    [contentView addSubview:logoImg];
    [logoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(25);
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(40);
    }];
    
    UILabel *desLab = [[UILabel alloc] init];
    desLab.numberOfLines = 0;
    desLab.text = @"If you like our app, please\n rate us!";
    desLab.font = [UIFont systemFontOfSize:17];
    desLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    desLab.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:desLab];
    [desLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(logoImg.mas_bottom).offset(20);
        make.centerX.equalTo(self);
    }];
    
    UIView *btnView = [[UIView alloc] init];
    [contentView addSubview: btnView];
    [btnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(desLab.mas_bottom).offset(22);
        make.width.equalTo(@270);
        make.height.mas_equalTo(40);
        make.centerX.equalTo(contentView);
    }];
    for (int i=0; i<5; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"set_love"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"set_love_sel"] forState:UIControlStateSelected];
        btn.tag = 100+i;
        [btn addTarget:self action:@selector(selectStar:) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:btn];
        [self.stars addObject:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
            make.centerY.equalTo(btnView);
        }];
    }
    [self.stars mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:40 leadSpacing:10 tailSpacing:10];
    
    
    UIView *herLink = [[UIView alloc] init];
    herLink.backgroundColor = [UIColor colorWithString:@"#E0E0E0"];
    [contentView addSubview:herLink];
    [herLink mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScaleWidth(270));
        make.height.mas_equalTo(1);
        make.centerX.equalTo(contentView);
        make.bottom.equalTo(contentView.mas_bottom).offset(-50);
    }];
    
    UIView *verLink = [[UIView alloc] init];
    verLink.backgroundColor = [UIColor colorWithString:@"#E0E0E0"];
    [contentView addSubview:verLink];
    [verLink mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScaleWidth(1));
        make.height.mas_equalTo(30);
        make.centerX.equalTo(contentView);
        make.top.equalTo(herLink).offset(10);
    }];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithString:@"#52CCBB"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentView);
        make.right.equalTo(verLink.mas_left);
        make.left.equalTo(herLink);
        make.top.equalTo(herLink.mas_bottom);
    }];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor colorWithString:@"#52CCBB"] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitClick:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:submitBtn];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentView);
        make.left.equalTo(verLink.mas_right);
        make.right.equalTo(herLink);
        make.top.equalTo(herLink.mas_bottom);
    }];
}

- (void)closeClick:(UIButton *)button{
    [self removeFromSuperview];
}

- (void)submitClick:(UIButton *)button{
    [self removeFromSuperview];
    if (self.index > 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:k_APPStore_Write]];
    }
}

- (void)selectStar:(UIButton *)button{
    NSInteger index = button.tag - 100;
    self.index = index;
    for (UIButton *btn in self.stars) {
        btn.selected = NO;
    }
    for (int i=0; i<index+1; i++) {
        self.stars[i].selected = YES;
    }
}

- (NSMutableArray<UIButton *> *)stars{
    if (!_stars) {
        _stars = [NSMutableArray array];
    }
    return _stars;
}

@end
