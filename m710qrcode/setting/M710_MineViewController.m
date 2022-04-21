//
//  M710_MineViewController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "M710_MineViewController.h"

@interface M710_MineViewController ()

@end

@implementation M710_MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
}

- (void)addSubView_layout{
    [self hideBackItem];
    [self setTitleStr:@"Settings"];
}

@end
