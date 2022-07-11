//
//  Szero_CreatUrlCell.m
//  szeroqr
//
//  Created by xc-76 on 2022/4/26.
//

#import "Szero_CreatUrlCell.h"

@interface Szero_CreatUrlCell ()

@property (nonatomic ,strong) UILabel *textLab;

@end

@implementation Szero_CreatUrlCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubView_layout];
    }
    return self;
}

- (void)setDesStr:(NSString *)desStr{
    if (desStr) {
        _desStr = desStr;
        self.textLab.text = desStr;
    }
}

- (void)addSubView_layout{
    
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
    
    self.textLab = [[UILabel alloc] init];
    self.textLab.font = [UIFont systemFontOfSize:14];
    self.textLab.textColor = [UIColor colorWithString:@"#52CCBB"];
    self.textLab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.textLab];
    [self.textLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}


@end
