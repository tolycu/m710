//
//  SelectNavgidueView.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/26.
//

#import "SelectNavgidueView.h"

@interface SelectNavgidueView ()

@property (nonatomic ,strong) UIButton *leftBtn;
@property (nonatomic ,strong) UIButton *rightBtn;
@property (nonatomic ,strong) UIView *dotLView;
@property (nonatomic ,strong) UIView *dotRView;

@property (nonatomic ,strong) NSString *leftStr;
@property (nonatomic ,strong) NSString *rightStr;

@end

@implementation SelectNavgidueView


- (instancetype)initWithFrame:(CGRect)frame leftTitle:(NSString *)leftStr rightTitle:(NSString *)rightStr
{
    self = [super initWithFrame:frame];
    if (self) {
        self.leftStr = leftStr;
        self.rightStr = rightStr;
        [self addSubView_layout];
        [self selectClick:self.leftBtn];
    }
    return self;
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
        
        if (self.selectBlock) {
            self.selectBlock(0);
        }
        
    }else{
        self.dotLView.hidden = YES;
        self.dotRView.hidden = NO;
        self.leftBtn.selected = NO;
        self.rightBtn.selected = YES;
        
        if (self.selectBlock) {
            self.selectBlock(1);
        }
    }
}

- (void)addSubView_layout{
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTitle:self.leftStr forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor colorWithString:@"#1A1A1A"] forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor colorWithString:@"#52CCBB"] forState:UIControlStateSelected];
    [leftBtn addTarget:self action:@selector(selectClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftBtn];
    self.leftBtn = leftBtn;
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.right.equalTo(self.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:self.rightStr forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor colorWithString:@"#1A1A1A"] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor colorWithString:@"#52CCBB"] forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(selectClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightBtn];
    self.rightBtn = rightBtn;
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self);
        make.left.equalTo(self.mas_centerX);
        make.height.mas_equalTo(30);
    }];
    
    self.dotLView = [[UIView alloc] init];
    self.dotLView.backgroundColor = [UIColor colorWithString:@"#52CCBB"];
    self.dotLView.layer.cornerRadius = 2.5;
    self.dotLView.layer.masksToBounds = YES;
    [self addSubview:self.dotLView];
    [self.dotLView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(5);
        make.centerX.equalTo(leftBtn);
        make.bottom.equalTo(self);
    }];
    
    self.dotRView = [[UIView alloc] init];
    self.dotRView.backgroundColor = [UIColor colorWithString:@"#52CCBB"];
    self.dotRView.layer.cornerRadius = 2.5;
    self.dotRView.layer.masksToBounds = YES;
    [self addSubview:self.dotRView];
    [self.dotRView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(5);
        make.centerX.equalTo(rightBtn);
        make.bottom.equalTo(self);
    }];
}

@end
