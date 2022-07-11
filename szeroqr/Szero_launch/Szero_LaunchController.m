//
//  Szero_LaunchController.m
//  szeroqr
//
//  Created by xc-76 on 2022/4/21.
//

#import "Szero_LaunchController.h"
#import <Lottie/Lottie.h>

@interface Szero_LaunchController ()

@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,assign) float longTime;
@property(nonatomic,strong) LOTAnimationView *lottieView;

@end

@implementation Szero_LaunchController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
}

- (void)addSubView_layout{
    
    self.view.backgroundColor = [UIColor colorWithString:@"#47E1CC"];
    
    [self.view addSubview:self.lottieView];
    [self.lottieView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-30);
        make.width.mas_equalTo(kScaleWidth(202));
        make.height.mas_equalTo(kScaleWidth(152));
    }];
    
    [self.lottieView playToProgress:0.81 withCompletion:^(BOOL animationFinished) {
        if (animationFinished) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkoutConfig) userInfo:nil repeats:YES];
            self.lottieView.loopAnimation = YES;
            [self.lottieView playFromProgress:0.81 toProgress:1 withCompletion:^(BOOL animationFinished) {
                [self.timer invalidate];
                self.timer = nil;
                self.nextBlock();
            }];
        }
    }];
}

- (void)checkoutConfig{
    
    self.longTime = self.longTime + 0.5;
    if (Adapter_MANAGE.globalModel) {
        if (self.longTime + 4 > Adapter_MANAGE.globalModel.IStartPageTime) {
            [self.lottieView stop];
            return;
        }
    }else{
        if (self.longTime + 4 > 10) {
            [self.lottieView stop];
            return;
        }
    }

    ADConfigModel *model = [ADConfigSetting filterADPosition:ADPositionType_start];
    if (model) {
        [self.lottieView stop];
        return;
    }
}


-(LOTAnimationView *)lottieView{
    if (!_lottieView) {
        _lottieView = [LOTAnimationView animationNamed:@"start"];
    }
    return _lottieView;
}

@end
