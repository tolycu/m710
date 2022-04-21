//
//  M710_BaseViewController.m
//  camera
//
//  Created by 李光尧 on 2021/12/21.
//

#import "M710_BaseViewController.h"

@interface M710_BaseViewController ()

@property(nonatomic,strong) UIButton *backBtn;
@property (nonatomic ,strong) UILabel *titleLab;

@end

@implementation M710_BaseViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)setTitleStr:(NSString *)title{
    self.titleLab.text = title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithString:@"#FAFAFA"];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"navBack_black"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    self.backBtn = backBtn;
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(self.view).offset(STATUS_HEIGHT+3);
        make.width.height.mas_equalTo(27);
    }];
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.font = [UIFont systemFontOfSize:19 weight:UIFontWeightBold];
    self.titleLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    [self.view addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(STATUS_HEIGHT+10);
    }];
}

- (void)hideBackItem{
    self.backBtn.hidden = YES;
}

- (void)backClick{
    
    [[self currentController].navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
