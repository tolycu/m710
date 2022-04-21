//
//  M710_HistoryViewController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "M710_HistoryViewController.h"

@interface M710_HistoryViewController ()

@property (nonatomic ,strong) UIButton *leftBtn;
@property (nonatomic ,strong) UIButton *rightBtn;
@property (nonatomic ,strong) UIView *dotLView;
@property (nonatomic ,strong) UIView *dotRView;

@end

@implementation M710_HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
    [self selectClick:self.leftBtn];
}

- (void)selectClick:(UIButton *)button{
    if (button.selected) {
        return;
    }
    if (button == self.leftBtn) {
        self.dotLView.hidden = NO;
        self.dotRView.hidden = YES;
        self.leftBtn.selected = YES;
        self.rightBtn.selected = NO;
    }else{
        self.dotLView.hidden = YES;
        self.dotRView.hidden = NO;
        self.leftBtn.selected = NO;
        self.rightBtn.selected = YES;
    }
}

- (void)addSubView_layout{
    [self hideBackItem];
    [self setTitleStr:@"History"];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTitle:@"Generate History" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor colorWithString:@"#1A1A1A"] forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor colorWithString:@"#52CCBB"] forState:UIControlStateSelected];
    [leftBtn addTarget:self action:@selector(selectClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    self.leftBtn = leftBtn;
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+10);
        make.height.mas_equalTo(30);
    }];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"Scan History" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor colorWithString:@"#1A1A1A"] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor colorWithString:@"#52CCBB"] forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(selectClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    self.rightBtn = rightBtn;
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.left.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+10);
        make.height.mas_equalTo(30);
    }];
    
    self.dotLView = [[UIView alloc] init];
    self.dotLView.backgroundColor = [UIColor colorWithString:@"#52CCBB"];
    self.dotLView.layer.cornerRadius = 2.5;
    self.dotLView.layer.masksToBounds = YES;
    [self.view addSubview:self.dotLView];
    [self.dotLView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(5);
        make.centerY.equalTo(leftBtn.mas_bottom);
        make.centerX.equalTo(leftBtn);
    }];
    
    self.dotRView = [[UIView alloc] init];
    self.dotRView.backgroundColor = [UIColor colorWithString:@"#52CCBB"];
    self.dotRView.layer.cornerRadius = 2.5;
    self.dotRView.layer.masksToBounds = YES;
    [self.view addSubview:self.dotRView];
    [self.dotRView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(5);
        make.centerY.equalTo(leftBtn.mas_bottom);
        make.centerX.equalTo(rightBtn);
    }];
}


@end
