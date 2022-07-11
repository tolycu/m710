//
//  Sport_PrivacyViewController.m
//  sportqr
//
//  Created by Hoho Wu on 2022/3/13.
//

#import "Sport_PrivacyViewController.h"
#import <WebKit/WebKit.h>

@interface Sport_PrivacyViewController ()<WKNavigationDelegate,WKUIDelegate>

@property(nonatomic,strong) WKWebView *webView;

@end

@implementation Sport_PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSubViews];
    
}

- (void)setSubViews{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.backgroundColor = [UIColor colorWithString:@"#35E89B"];
    [nextBtn setTitle:@"Agree" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor colorWithString:@"#1A1A1A"] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    [nextBtn addTarget:self action:@selector(nextClick) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.layer.cornerRadius = 14.f;
    nextBtn.layer.masksToBounds = YES;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-40-SYSTEM_GESTURE_HEIGHT);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(nextBtn.mas_top).offset(-20);
    }];
  
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(TOP_HEIGHT);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"Your privacy is Important";
    titleLab.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    titleLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    [headerView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(STATUS_HEIGHT + 10);
    }];

    NSString *bundleStr = [[NSBundle mainBundle] pathForResource:@"FirstPrivacy" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:bundleStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.webView reload];
}

- (void)nextClick{
    [NSUserDefaults jk_setObject:@(YES) forKey:APP_Launched];
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
