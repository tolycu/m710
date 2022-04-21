//
//  M710_NetViewController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "M710_NetViewController.h"

@interface M710_NetViewController ()

@end

@implementation M710_NetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
}

- (void)addSubView_layout{
    [self hideBackItem];
    [self setTitleStr:@"Net Tool"];
}


@end
