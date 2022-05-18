//
//  AppDelegate.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/20.
//

#import "AppDelegate.h"
#import "LBTabBarController.h"
#import "HomeAdapter.h"
#import "SOneVPTool.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "Sport_PrivacyViewController.h"
#import "M710_LaunchController.h"

@interface AppDelegate ()

@property (nonatomic ,strong) HomeAdapter *adapter;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
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
}

- (void)installLaunch{
    
    BOOL isFirst = [NSUserDefaults jk_boolForKey:APP_Launched];
    Sport_PrivacyViewController *privacyVC = [[Sport_PrivacyViewController alloc] init];
    privacyVC.nextBlock = ^{
        [NSUserDefaults jk_setObject:@(YES) forKey:APP_QRCode_Cache];
        [self hideSubWindow];
    };
    
    M710_LaunchController *launchVC = [[M710_LaunchController alloc] init];
    launchVC.nextBlock = ^{
        if (isFirst) {
            [self hideSubWindow];
        }else{
            self.subWindow.rootViewController = privacyVC;
            [Expert_GlobalMananger checkoutAdPrivacy:^(BOOL allow) {}];
        }
    };
    self.subWindow.rootViewController = launchVC;
    [self.subWindow makeKeyAndVisible];
}

- (void)hideSubWindow{
    [self.subWindow resignKeyWindow];
    self.subWindow = nil;
}

- (void)installRootController{
    
    LBTabBarController *vc = [[LBTabBarController alloc] init];
    vc.selectedIndex = 2;
    self.window.rootViewController = vc;
    [self.window makeKeyWindow];
}

// 关闭旋转
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}


// 网络请求
- (void)loadAppBaseData{
    [self.adapter getConfigWithCompletionHandler:^(BOOL success, NSError * _Nonnull error) {
        
    }];
    
    [self.adapter getVpnListWithCompletionHandler:^(BOOL success, NSError * _Nonnull error) {
        [self loadPingBestServer];
    }];
    
    [self.adapter getAppPostionInfoWithCompletionHandler:^(BOOL success, NSError * _Nonnull error) {
            
    }];
    
}

- (void)loadPingBestServer{
    
    [HomeAdapter pingVPNServers:Adapter_MANAGE.servers WithCompletionHandler:^{
        Expert_ServerVPNModel *bestServer = [HomeAdapter getBestVpnFrom:Adapter_MANAGE.servers];
        Adapter_MANAGE.bestServer = bestServer;
        if (![SOneVPTool isOpenVPNForDevice]) {
            NSMutableArray *bodys = [NSMutableArray array];
            for (Expert_ServerVPNModel *model in Adapter_MANAGE.servers) {
                NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
                [dictM setValue:model.expert_host forKey:@"expert_serverIp"];
                [dictM setValue:model.expert_alisaName forKey:@"expert_serverAlias"];
                [dictM setValue:model.expert_country forKey:@"expert_serverCountry"];
                [dictM setValue:@(model.ping!=0?model.ping:1000) forKey:@"expert_pingTime"];
                [bodys addObject:dictM];
            }
            [self.adapter upLoadServersPingWithParams:bodys CompletionHandler:^(BOOL success, NSError * _Nonnull error) {
                NSLog(@"上传服务器状态");
            }];
        }
    }];
}

-(HomeAdapter *)adapter{
    if (!_adapter) {
        _adapter = [[HomeAdapter alloc] init];
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
