//
//  AppDelegate.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/20.
//

#import "AppDelegate.h"
#import "LBTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self installThirdPartyByLaunchOptions:launchOptions];
    [self installRootController];
    
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



@end
