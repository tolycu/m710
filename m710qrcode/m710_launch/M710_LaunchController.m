//
//  M710_LaunchController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "M710_LaunchController.h"
#import <Lottie/Lottie.h>

@interface M710_LaunchController ()

@property(nonatomic,strong) LOTAnimationView *lottieView;

@end

@implementation M710_LaunchController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
}

- (void)addSubView_layout{
    
    self.view.backgroundColor = [UIColor colorWithString:@"#47E1CC"];
    [self.lottieView playWithCompletion:^(BOOL animationFinished) {
        if (self.nextBlock) {
            self.nextBlock();
        }
    }];
    [self.view addSubview:self.lottieView];
    [self.lottieView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-30);
        make.width.mas_equalTo(kScaleWidth(202));
        make.height.mas_equalTo(kScaleWidth(152));
    }];
//    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"m710_logo"]];
//    [self.view addSubview:icon];
//    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view);
//        make.width.height.mas_equalTo(kScaleWidth(84));
//        make.centerY.equalTo(self.view).offset(-30);
//    }];
//
//    UILabel *nameLab = [[UILabel alloc] init];
//    nameLab.text = @"IQR-Scanning Expert";
//    nameLab.textColor = [UIColor whiteColor];
//    nameLab.font = [UIFont systemFontOfSize:19];
//    [self.view addSubview:nameLab];
//    [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view);
//        make.top.equalTo(icon.mas_bottom).offset(25);
//    }];
}


-(LOTAnimationView *)lottieView{
    if (!_lottieView) {
        _lottieView = [LOTAnimationView animationNamed:@"start"];
//        _lottieView.loopAnimation = YES;
    }
    return _lottieView;
}

@end
