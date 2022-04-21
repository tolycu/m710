//
//  LBTabBarController.m
//  XianYu
//
//  Created by li  bo on 16/5/28.
//  Copyright © 2016年 li  bo. All rights reserved.
//

#import "LBTabBarController.h"
#import "LBTabBar.h"
#import "BaseNavController.h"
#import "M710_ScanViewController.h"
#import "M710_MineViewController.h"
#import "M710_HistoryViewController.h"
#import "M710_CreatViewController.h"
#import "M710_NetViewController.h"


@interface LBTabBarController ()<LBTabBarDelegate>

@end

@implementation LBTabBarController

#pragma mark - 第一次使用当前类的时候对设置UITabBarItem的主题
+ (void)initialize
{
    UITabBarItem *tabBarItem = [UITabBarItem appearanceWhenContainedInInstancesOfClasses:@[self]];
    
    NSMutableDictionary *dictNormal = [NSMutableDictionary dictionary];
    dictNormal[NSForegroundColorAttributeName] = [UIColor colorWithString:@"#CCCCCC"];
    dictNormal[NSFontAttributeName] = [UIFont systemFontOfSize:13];

    NSMutableDictionary *dictSelected = [NSMutableDictionary dictionary];
    dictSelected[NSForegroundColorAttributeName] = [UIColor colorWithString:@"#1EDBBD"];
    dictSelected[NSFontAttributeName] = [UIFont systemFontOfSize:13];

    [tabBarItem setTitleTextAttributes:dictNormal forState:UIControlStateNormal];
    [tabBarItem setTitleTextAttributes:dictSelected forState:UIControlStateSelected];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpAllChildVc];

    //创建自己的tabbar，然后用kvc将自己的tabbar和系统的tabBar替换下
    LBTabBar *tabbar = [[LBTabBar alloc] init];
    tabbar.myDelegate = self;
    //kvc实质是修改了系统的_tabBar
    [self setValue:tabbar forKeyPath:@"tabBar"];
    [self.tabBar setBackgroundImage:[UIImage jk_imageWithColor:[UIColor whiteColor]]];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectIndex) name:Current_Connect_Model object:nil];
}

- (void)selectIndex{
    if (self.selectedIndex == 1) {
        self.selectedIndex = 0; 
    }
}


#pragma mark - ------------------------------------------------------------------
#pragma mark - 初始化tabBar上除了中间按钮之外所有的按钮

- (void)setUpAllChildVc{
    
    M710_CreatViewController *creatVC = [[M710_CreatViewController alloc] init];
    [self setUpOneChildVcWithVc:creatVC Image:@"tab_creat" selectedImage:@"tab_creat_sel" title:@"Create"];
    
    M710_HistoryViewController *historyVC = [[M710_HistoryViewController alloc] init];
    [self setUpOneChildVcWithVc:historyVC Image:@"tab_history" selectedImage:@"tab_history_sel" title:@"History"];
    
    M710_ScanViewController *scanVC = [[M710_ScanViewController alloc] init];
    [self setUpOneChildVcWithVc:scanVC Image:@"" selectedImage:@"" title:@""];
    
    M710_NetViewController *netVC = [[M710_NetViewController alloc] init];
    [self setUpOneChildVcWithVc:netVC Image:@"tab_net" selectedImage:@"tab_net_sel" title:@"NetTool"];

    M710_MineViewController *settingVC = [[M710_MineViewController alloc] init];
    [self setUpOneChildVcWithVc:settingVC Image:@"tab_setting" selectedImage:@"tab_setting_sel" title:@"Setting"];
}

#pragma mark - 初始化设置tabBar上面单个按钮的方法

/**
 *  @author li bo, 16/05/10
 *
 *  设置单个tabBarButton
 *
 *  @param Vc            每一个按钮对应的控制器
 *  @param image         每一个按钮对应的普通状态下图片
 *  @param selectedImage 每一个按钮对应的选中状态下的图片
 *  @param title         每一个按钮对应的标题
 */
- (void)setUpOneChildVcWithVc:(UIViewController *)Vc Image:(NSString *)image selectedImage:(NSString *)selectedImage title:(NSString *)title{
    
    BaseNavController *nav = [[BaseNavController alloc] initWithRootViewController:Vc];
    
    
    UIImage *myImage = [UIImage imageNamed:image];
    myImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    //tabBarItem，是系统提供模型，专门负责tabbar上按钮的文字以及图片展示
    Vc.tabBarItem.image = myImage;

    UIImage *mySelectedImage = [UIImage imageNamed:selectedImage];
    mySelectedImage = [mySelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    Vc.tabBarItem.selectedImage = mySelectedImage;
    Vc.tabBarItem.title = title;
    Vc.navigationItem.title = title;
    [self addChildViewController:nav];
    
}

#pragma mark - LBTabBarDelegate
//点击中间按钮的代理方法
- (void)tabBarPlusBtnClick:(LBTabBar *)tabBar{
    self.selectedIndex = 2;
}

@end

