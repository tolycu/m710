//
//  M710_FolderViewCell.m
//  M710qr
//
//  Created by Hoho Wu on 2022/3/3.
//

#import "M710_FolderViewCell.h"

@interface M710_FolderViewCell ()

@property (nonatomic ,strong) UIImageView *icon;
@property (nonatomic ,strong) UILabel *nameLab;

@end

@implementation M710_FolderViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubView_layout];
    }
    return self;
}

- (void)setDict:(NSDictionary *)dict{
    if (dict) {
        _dict = dict;
        self.icon.image = [UIImage imageNamed:dict[@"img"]];
        self.nameLab.text = dict[@"title"];
        self.nameLab.textColor = [UIColor colorWithString:dict[@"color"]];
    }
}

- (void)addSubView_layout{
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 14.f;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.borderWidth = 1.f;
    self.contentView.layer.borderColor = [UIColor colorWithString:@"#F0F0F0"].CGColor;
    
    self.icon = [[UIImageView alloc] init];
    self.icon.contentMode = UIViewContentModeScaleToFill;
    self.icon.clipsToBounds = YES;
    [self.contentView addSubview:self.icon];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(35);
        make.width.height.mas_equalTo(50);
    }];
    
    self.nameLab = [[UILabel alloc] init];
    self.nameLab.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.icon.mas_bottom).offset(12);
    }];
    
}


@end
