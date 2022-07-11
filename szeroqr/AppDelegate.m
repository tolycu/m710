//
//  AppDelegate.m
//  szeroqr
//
//  Created by xc-76 on 2022/4/20.
//

#import "AppDelegate.h"
#import "Szero_HomeAdapter.h"
#import "SOneVPTool.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Sport_PrivacyViewController.h"
#import "Szero_LaunchController.h"
#import "Szero_BaseTabController.h"
#import "XKConsoleBoard.h"

@interface AppDelegate ()<GADFullScreenContentDelegate>

@property (nonatomic ,strong) Szero_HomeAdapter *adapter;

@property (nonatomic,strong) ADConfigModel *_Nullable configModel;
@property (nonatomic,assign) ADDataType adType;
@property (nonatomic,strong) GADAppOpenAd *openAd;
@property (nonatomic,strong) GADInterstitialAd *interstitial;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [XKConsoleBoard borad];
    [self installThirdPartyByLaunchOptions:launchOptions];
    [self installRootController];
    [self installLaunch];
    [self loadAppBaseData];
    return YES;
}

- (void)installThirdPartyByLaunchOptions:(NSDictionary *)launchOptions{
    // 强制关闭暗黑模式
    #if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
    if(@available(iOS 13.0,*)){
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
//        self.subWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    #endif
    
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.toolbarManageBehaviour = IQAutoToolbarByPosition;
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.enableAutoToolbar = YES;
    
    [FIRApp configure];
    [[FIRConfiguration sharedInstance] setLoggerLevel:FIRLoggerLevelError];
    [[FIRCrashlytics crashlytics] setCrashlyticsCollectionEnabled:YES];
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ @"5e8e2e5148d24d33fca9376d7e80de92" ];
    
    [[FBSDKSettings sharedSettings] setAdvertiserTrackingEnabled:YES];
    [[FBSDKSettings sharedSettings] setClientToken:@"5cd1778d02bb0135d6317d1124e73dfd"];
    [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:launchOptions];
    
}

- (void)installLaunch{
    
    BOOL isFirst = [NSUserDefaults jk_boolForKey:APP_Launched];
    Sport_PrivacyViewController *privacyVC = [[Sport_PrivacyViewController alloc] init];
    privacyVC.nextBlock = ^{
        [NSUserDefaults jk_setObject:@(YES) forKey:APP_QRCode_Cache];
        [self showAds];
    };
    
    Szero_LaunchController *launchVC = [[Szero_LaunchController alloc] init];
    launchVC.nextBlock = ^{
        if (isFirst) {
            [self showAds];
        }else{
            self.subWindow.rootViewController = privacyVC;
            [Szero_GlobalMananger checkoutAdPrivacy:^(BOOL allow) {}];
        }
    };
    self.subWindow.rootViewController = launchVC;
    [self.subWindow makeKeyAndVisible];
}

- (void)showAds{
    self.configModel = [ADConfigSetting filterADPosition:ADPositionType_start];
    if (self.configModel) {
        self.adType = [ADConfigSetting getLoadADtype:self.configModel.model.expert_type];
        [self loadShowADData];
    }else{
        [self hideSubWindow];
    }
}

- (void)loadShowADData{
    if (self.adType == ADDataType_int &&
        [NSStringFromClass([self.configModel.requestAD class]) isEqualToString:@"GADInterstitialAd"]){
        [FIRAnalytics logEventWithName:ShowFinishAds parameters:@{@"id":self.configModel.model.expert_placeId}];
        self.interstitial = (GADInterstitialAd *)self.configModel.requestAD;
        [self.interstitial presentFromRootViewController:self.subWindow.rootViewController];
        self.interstitial.fullScreenContentDelegate = self;
        self.configModel.requestAD = nil;
        [AD_MANAGE resetADConfigManage];
    }else if (self.adType == ADDataType_open && [NSStringFromClass([self.configModel.requestAD class]) isEqualToString:@"GADAppOpenAd"]){
        [FIRAnalytics logEventWithName:ShowStartAds parameters:@{@"id":self.configModel.model.expert_placeId}];
        self.openAd = (GADAppOpenAd *)self.configModel.requestAD;
        [self.openAd presentFromRootViewController:self.subWindow.rootViewController];
        self.openAd.fullScreenContentDelegate = self;
        self.configModel.requestAD = nil;
        [AD_MANAGE resetADConfigManage];
    }
}

- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad{
    [self hideSubWindow];
}

- (void)hideSubWindow{
    [[NSNotificationCenter defaultCenter] postNotificationName:Home_Banner_Show object:nil];
    self.subWindow.hidden = YES;
    [self.subWindow resignKeyWindow];
    self.subWindow = nil;
}

- (void)installRootController{
    
    Szero_BaseTabController *vc = [[Szero_BaseTabController alloc] init];
    vc.selectedIndex = 0;
    self.window.rootViewController = vc;
    [self.window makeKeyWindow];
}


- (void)applicationWillEnterForeground:(UIApplication *)application{
    
    NSString *currentVC = NSStringFromClass([[self currentController] class]);
    NSLog(@"当前控制器是%@",currentVC );
    if ([currentVC isEqualToString:@"UIAlertController"] ||
        [currentVC isEqualToString:@"GADFullScreenAdViewController"] ||
        [currentVC isEqualToString:@"UADSViewController"] ||
        [currentVC isEqualToString:@"SFSafariViewController"] ) {
        [[self currentController] dismissViewControllerAnimated:NO completion:nil];
    }
    
    //没授权 不弹广告
//    NSDictionary *tempDict = [[NSUserDefaults standardUserDefaults] objectForKey:History_Connect_VPNS];
//    if (!tempDict) {return;}
    if (self.subWindow) {
        [self hideSubWindow];
    }
    [self againActive];
}

#pragma mark - 热启动
- (void)againActive{
    //全局检测广告
    [AD_MANAGE resetADConfigManage];
    [self installLaunch];
}

// 关闭旋转
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}


// 网络请求
- (void)loadAppBaseData{
    [self.adapter getConfigWithCompletionHandler:^(BOOL success, NSError * _Nonnull error) {
        
    }];
}

-(Szero_HomeAdapter *)adapter{
    if (!_adapter) {
        _adapter = [[Szero_HomeAdapter alloc] init];
    }
    return _adapter;
}

-(UIWindow *)subWindow{
    if (!_subWindow) {
        _subWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _subWindow.backgroundColor = [UIColor clearColor];
        _subWindow.windowLevel = UIWindowLevelAlert;
    }
    return _subWindow;
}
@end
