//
//  Expert_WebViewController.m
//  sportqr
//
//  Created by Hoho Wu on 2022/3/3.
//

#import "Expert_WebViewController.h"
#import <WebKit/WebKit.h>

@interface Expert_WebViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic,strong) WKWebView *webView;

@end

@implementation Expert_WebViewController


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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(TOP_HEIGHT);
    }];
    
    if ([self.url isEqualToString:privacy_url]) {
        NSString *bundleStr = [[NSBundle mainBundle] pathForResource:@"Privacy" ofType:@"html"];
        NSURL *url = [NSURL fileURLWithPath:bundleStr];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        
    }else if ([self.url isEqualToString:terms_url]){

        NSString *bundleStr = [[NSBundle mainBundle] pathForResource:@"Service" ofType:@"html"];
        NSURL *url = [NSURL fileURLWithPath:bundleStr];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        
    }else{
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    }
    [self.webView reload];
}


@end
