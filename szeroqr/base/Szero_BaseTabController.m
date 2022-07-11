//
//  Szero_BaseTabController.m
//  sportqr
//
//  Created by Hoho Wu on 2022/2/27.
//

#import "Szero_BaseTabController.h"
#import "Szero_BaseNavController.h"

#import "Szero_ScanViewController.h"
#import "Szero_CreatViewController.h"
#import "Szero_HistoryViewController.h"
#import "Szero_MineViewController.h"

@interface Szero_BaseTabController ()<UITabBarControllerDelegate>

@end

@implementation Szero_BaseTabController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.tabBar.translucent = NO;
    self.delegate = self;
    [self setSubView_layout];
    self.tabBar.barTintColor = [UIColor whiteColor];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIndex:) name:APP_Change_TabIndex object:nil];
}

- (void)changeIndex:(NSNotification *)notf{
    NSInteger index = [notf.userInfo jk_integerForKey:@"index"];
    self.selectedIndex = index;
    [[self currentController].navigationController popToRootViewControllerAnimated:NO];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSLog(@"tabbar 选中%ld",tabBarController.selectedIndex);
    if (tabBarController.selectedIndex == 0) {
        viewController.tabBarItem.title = @"";
    }else{
        UITabBarItem *item = tabBarController.tabBar.items[0];
        item.title = @"Scan";
    }
}

- (void)setSubView_layout{
    
    CGRect rect = CGRectMake(0, 0, XCScreenW - 15, 0.5);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.tabBar.shadowImage = img;
    self.tabBar.backgroundImage = [UIImage jk_imageWithColor:[UIColor whiteColor]];

    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    [attrs setValue:[UIColor colorWithString:@"#CCCCCC"] forKey:NSForegroundColorAttributeName];

    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    [selectedAttrs setValue:[UIColor colorWithString:@"#52CCBB"] forKey:NSForegroundColorAttributeName];

    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    
    Szero_ScanViewController *sacnVC = [[Szero_ScanViewController alloc] init];
    Szero_BaseNavController *sacnNa = [[Szero_BaseNavController alloc] initWithRootViewController:sacnVC];
    sacnNa.tabBarItem.title = @"";
    sacnNa.tabBarItem.image = [[UIImage imageNamed:@"tab_scan"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    sacnNa.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_scan_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [sacnNa.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    
    Szero_CreatViewController *creatVC = [[Szero_CreatViewController alloc] init];
    Szero_BaseNavController *creatNa = [[Szero_BaseNavController alloc] initWithRootViewController:creatVC];
    creatNa.tabBarItem.title = @"Create";
    creatNa.tabBarItem.image = [[UIImage imageNamed:@"tab_creat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    creatNa.tabBarItem.selectedImage =  [[UIImage imageNamed:@"tab_creat_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [creatNa.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    
    Szero_HistoryViewController *historyVC = [[Szero_HistoryViewController alloc] init];
    Szero_BaseNavController *historyNa = [[Szero_BaseNavController alloc] initWithRootViewController:historyVC];
    historyNa.tabBarItem.title = @"History";
    historyNa.tabBarItem.image = [[UIImage imageNamed:@"tab_history"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    historyNa.tabBarItem.selectedImage =  [[UIImage imageNamed:@"tab_history_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [historyNa.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    
    Szero_MineViewController *settVC = [[Szero_MineViewController alloc] init];
    Szero_BaseNavController *settNa = [[Szero_BaseNavController alloc] initWithRootViewController:settVC];
    settNa.tabBarItem.title = @"Setting";
    settNa.tabBarItem.image = [[UIImage imageNamed:@"tab_setting"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    settNa.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_setting_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [settNa.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    
    self.tabBar.tintColor = [UIColor colorWithString:@"#52CCBB"];
    self.viewControllers = @[sacnNa,creatNa,historyNa,settNa];
    
    
    if (@available(iOS 15.0, *)) {
            
            UITabBarAppearance *appearance = [UITabBarAppearance new];
            //tabBar背景颜色
            appearance.backgroundColor = [UIColor whiteColor];
           // 去掉半透明效果
            appearance.backgroundEffect = nil;
           // tabBaritem title选中状态颜色
           appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{
                NSForegroundColorAttributeName:[UIColor colorWithString:@"#52CCBB"],
                NSFontAttributeName:[UIFont systemFontOfSize:12],
            };
            //tabBaritem title未选中状态颜色
            appearance.stackedLayoutAppearance.normal.titleTextAttributes =  @{
                NSForegroundColorAttributeName:[UIColor colorWithString:@"#CCCCCC"],
                NSFontAttributeName:[UIFont systemFontOfSize:12],
            };
            self.tabBar.scrollEdgeAppearance = appearance;
            self.tabBar.standardAppearance = appearance;
    }
}

@end


