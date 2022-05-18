//
//  M710_ConnectTypeView.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/25.
//

#import "M710_ConnectTypeView.h"


@interface M710_ConnectTypeView ()

@property (nonatomic ,strong) UILabel *typeLab;

@property (nonatomic ,strong) UIView *firstView;
@property (nonatomic ,strong) UILabel *firstLab;
@property (nonatomic ,strong) UIView *lastView;
@property (nonatomic ,strong) UILabel *lastLab;

@property (nonatomic ,strong) UIButton *nextBtn;



@end

@implementation M710_ConnectTypeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview_layout];
    }
    return self;
}

- (void)nextClick:(UIButton *)button{
    button.selected = !button.selected;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(button.selected?(55*3):55);
    }];
    
    self.firstView.hidden = !button.selected;
    self.firstLab.hidden = self.firstView.hidden;
    self.lastView.hidden = !button.selected;
    self.lastLab.hidden = self.lastView.hidden;
}

- (void)addSubview_layout{
    
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *typeTitleLab = [[UILabel alloc] init];
    typeTitleLab.text = @"Type ：";
    typeTitleLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    typeTitleLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self addSubview:typeTitleLab];
    [typeTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(18.5);
    }];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setImage:[UIImage imageNamed:@"VpnType_up"] forState: UIControlStateNormal];
    [nextBtn setImage:[UIImage imageNamed:@"VpnType_down"] forState: UIControlStateSelected];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextBtn];
    self.nextBtn = nextBtn;
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(typeTitleLab);
    }];
    
    self.typeLab = [[UILabel alloc] init];
    self.typeLab.text = @"OpenVpn(TCP)";
    self.typeLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    self.typeLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self addSubview:self.typeLab];
    [self.typeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(typeTitleLab);
        make.left.equalTo(typeTitleLab.mas_right);
        make.right.mas_lessThanOrEqualTo(nextBtn.mas_left).offset(-10);
    }];
    
    [self creatTypeListView];
}

- (void)creatTypeListView{
    
    self.firstView = [[UIView alloc] init];
    self.firstView.backgroundColor = [UIColor whiteColor];
    [self.firstView jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        NSString *typeStr = self.typeLab.text;
        [self completionHandler:typeStr];
        self.typeLab.text = self.firstLab.text;
        self.firstLab.text = typeStr;
        [self closeClick];
    }];
    self.firstView.hidden = YES;
    [self addSubview:self.firstView];
    [self.firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self).offset(55);
        make.height.mas_equalTo(55);
    }];
    
    self.firstLab = [[UILabel alloc] init];
    self.firstLab.text = @"OpenVpn(UDP)";
    self.firstLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    self.firstLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.firstLab.hidden = YES;
    [self addSubview:self.firstLab];
    [self.firstLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.firstView);
        make.left.right.equalTo(self.typeLab);
    }];
    
    self.lastView = [[UIView alloc] init];
    self.lastView.backgroundColor = [UIColor whiteColor];
    self.lastView.hidden = YES;
    [self.lastView jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        
        NSString *typeStr = self.typeLab.text;
        [self completionHandler:typeStr];
        self.typeLab.text = self.lastLab.text;
        self.lastLab.text = typeStr;
        [self closeClick];
        
        
    }];
    [self addSubview:self.lastView];
    [self.lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.firstView);
        make.top.equalTo(self.firstView.mas_bottom);
        make.height.mas_equalTo(55);
    }];
    
    self.lastLab = [[UILabel alloc] init];
    self.lastLab.text = @"IKEV2";
    self.lastLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    self.lastLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.lastLab.hidden = YES;
    [self addSubview:self.lastLab];
    [self.lastLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lastView);
        make.left.right.equalTo(self.firstLab);
    }];
}


- (void)completionHandler:(NSString *)title{
    if (self.selectCompletionHandler) {
        if ([title isEqualToString:@"OpenVpn(TCP)"]) {
            self.selectCompletionHandler(SOneVPConnectModeOPENVPN_TCP);
        }else if ([title isEqualToString:@"OpenVpn(UDP)"]){
            self.selectCompletionHandler(SOneVPConnectModeOPENVPN_UDP);
        }else{
            self.selectCompletionHandler(SOneVPConnectModeIKEV2);
        }
    }
}

- (void)closeClick{
    
    self.firstView.hidden = YES;
    self.firstLab.hidden = YES;
    self.lastView.hidden = YES;
    self.lastLab.hidden = YES;
    
    self.nextBtn.selected = NO;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(55);
    }];
}

@end
