//
//  Sport.m
//  sportqr
//
//  Created by Hoho Wu on 2022/3/6.
//

#import "Sport_PrivacyView.h"
#import <WebKit/WebKit.h>

@interface Sport_PrivacyView ()<WKNavigationDelegate,WKUIDelegate>

@property(nonatomic,strong) WKWebView *webView;


@end

@implementation Sport_PrivacyView

- (instancetype)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, XCScreenW,XCScreenH);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews{
    
    UIView *contView = [[UIView alloc] init];
    contView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contView];
    [contView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self).offset(200);
        make.bottom.equalTo(self).offset(20);
    }];
    contView.layer.cornerRadius = 14.f;
    contView.layer.masksToBounds = YES;
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.backgroundColor = [UIColor colorWithString:@"#35E89B"];
    [nextBtn setTitle:@"Agree" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor colorWithString:@"#1A1A1A"] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    [nextBtn addTarget:self action:@selector(nextClick) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.layer.cornerRadius = 14.f;
    nextBtn.layer.masksToBounds = YES;
    [contView addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contView).offset(-40-SYSTEM_GESTURE_HEIGHT);
        make.left.equalTo(contView).offset(20);
        make.right.equalTo(contView).offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    [contView addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contView);
        make.left.right.equalTo(contView);
        make.bottom.equalTo(nextBtn.mas_top).offset(-20);
    }];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    [contView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(contView);
        make.height.mas_equalTo(60);
    }];
    bgView.layer.cornerRadius = 14.f;
    bgView.layer.masksToBounds = YES;
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"Your privacy is Important";
    titleLab.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    titleLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    [contView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contView);
        make.top.equalTo(contView).offset(30);
    }];
    
    NSString *bundleStr = [[NSBundle mainBundle] pathForResource:@"FirstPrivacy" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:bundleStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.webView reload];
    
  
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"i_closure"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    [contView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contView).offset(15);
        make.right.equalTo(contView).offset(-15);
        make.width.height.mas_equalTo(24);
    }];

}



- (void)closeClick{
    [self removeFromSuperview];
}

- (void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)nextClick{
    [self removeFromSuperview];
    [NSUserDefaults jk_setObject:@(YES) forKey:APP_Privacy_Agree];
    if (self.nextBlock) {
        self.nextBlock();
    }
}


- (WKWebView *)webView{
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}
@end
