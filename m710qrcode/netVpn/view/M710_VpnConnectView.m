//
//  M710_VpnConnectView.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/24.
//

#import "M710_VpnConnectView.h"
#import <Lottie/Lottie.h>

@interface M710_VpnConnectView ()

@property(nonatomic,strong) LOTAnimationView *lottieView;
@property(nonatomic,strong) UIImageView *bgImg;
@property(nonatomic,strong) UIImageView *leftImg;
@property(nonatomic,strong) UIImageView *rightImg;

@end

@implementation M710_VpnConnectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubView_layout];
        [TOOL_MANAGE addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSLog(@"Status 改变了%@  AppStore--%ld",change,TOOL_MANAGE.status);
    [self changeConnectView:TOOL_MANAGE.status];
}

- (void)changeConnectView:(NEVPNStatus)status{
    if (status == NEVPNStatusConnecting ||
        status == NEVPNStatusDisconnecting) {
        self.lottieView.hidden = NO;
        [self.lottieView play];
        self.rightImg.hidden = YES;
        self.leftImg.hidden = YES;
        
    }else if(status == NEVPNStatusConnected){
        self.lottieView.hidden = YES;
        self.leftImg.hidden = YES;
        self.rightImg.hidden = NO;
        
    }else{
        self.lottieView.hidden = YES;
        self.leftImg.hidden = NO;
        self.rightImg.hidden = YES;
    }
}

- (void)addSubView_layout{
    self.bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vpn_bg"]];
    self.bgImg.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImg.clipsToBounds = YES;
    [self addSubview:self.bgImg];
    [self.bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(kScaleWidth(224));
        make.height.mas_equalTo(kScaleWidth(80));
    }];
    
    self.leftImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_switch"]];
    self.leftImg.contentMode = UIViewContentModeScaleAspectFill;
    self.leftImg.clipsToBounds = YES;
    [self addSubview:self.leftImg];
    [self.leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.bgImg).offset(-kScaleWidth(12));
        make.width.height.mas_equalTo(kScaleWidth(128));
    }];
    
    self.rightImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_switch_suc"]];
    self.rightImg.contentMode = UIViewContentModeScaleAspectFill;
    self.rightImg.clipsToBounds = YES;
    self.rightImg.hidden = YES;
    [self addSubview:self.rightImg];
    [self.rightImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.bgImg).offset(kScaleWidth(12));
        make.width.height.mas_equalTo(kScaleWidth(128));
    }];
    
    [self addSubview:self.lottieView];
    self.lottieView.hidden = YES;
    [self.lottieView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.height.mas_equalTo(kScaleWidth(124));
        make.width.mas_equalTo(kScaleWidth(225));
    }];
}

-(LOTAnimationView *)lottieView{
    if (!_lottieView) {
        _lottieView = [LOTAnimationView animationNamed:@"connect"];
        _lottieView.loopAnimation = YES;
    }
    return _lottieView;
}

@end
