//
//  M710_ClearCacheView.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/24.
//

#import "M710_ClearCacheView.h"

@interface M710_ClearCacheView ()

@property (nonatomic ,strong) NSString *titleStr;
@property (nonatomic ,strong) NSString *desStr;
@property (nonatomic ,assign) BOOL isBtns;

@end

@implementation M710_ClearCacheView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title des:(NSString *)des btns:(BOOL)btns
{
    frame = CGRectMake(0, 0, XCScreenW, XCScreenH);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.titleStr = title;
        self.desStr = des;
        self.isBtns = btns;
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
        make.width.mas_equalTo(kScaleWidth(300));
        make.height.equalTo(@200);
    }];
    contentView.layer.cornerRadius = 20.f;
    contentView.layer.masksToBounds = YES;
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    titleLab.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    titleLab.text = self.titleStr;
    [contentView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(15);
        make.centerX.equalTo(self);
    }];
    
    UILabel *desLab = [[UILabel alloc] init];
    desLab.numberOfLines = 0;
    desLab.text = self.desStr;
    desLab.font = [UIFont systemFontOfSize:17];
    desLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    desLab.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:desLab];
    [desLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLab.mas_bottom).offset(20);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(kScaleWidth(250));
    }];
    
    UIView *herLink = [[UIView alloc] init];
    herLink.backgroundColor = [UIColor colorWithString:@"#E0E0E0"];
    [contentView addSubview:herLink];
    [herLink mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScaleWidth(270));
        make.height.mas_equalTo(1);
        make.centerX.equalTo(contentView);
        make.bottom.equalTo(contentView.mas_bottom).offset(-50);
    }];
    
    if (!self.isBtns) {
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [submitBtn setTitle:@"Yes" forState:UIControlStateNormal];
        [submitBtn setTitleColor:[UIColor colorWithString:@"#52CCBB"] forState:UIControlStateNormal];
        [submitBtn addTarget:self action:@selector(submitClick:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:submitBtn];
        [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(contentView);
            make.left.right.equalTo(herLink);
            make.top.equalTo(herLink.mas_bottom);
        }];
        return;
    }
    
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
    [closeBtn setTitle:@"No" forState:UIControlStateNormal];
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
    [submitBtn setTitle:@"Yes" forState:UIControlStateNormal];
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
}

@end
