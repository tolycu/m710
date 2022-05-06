//
//  HistoryCellView.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/21.
//

#import "HistoryCellView.h"

@interface HistoryCellView ()

@property (nonatomic ,strong) UIImageView *qrImg;
@property (nonatomic ,strong) UILabel *dateLab;
@property (nonatomic ,strong) UILabel *resultLab;
@property (nonatomic ,strong) UIImageView *shareImg;
@property (nonatomic ,strong) UIImageView *deleteImg;

@end

@implementation HistoryCellView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubViews_layout];
    }
    return self;
}

- (void)addSubViews_layout{
    self.qrImg = [[UIImageView alloc] init];
    self.qrImg.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.qrImg];
    [self.qrImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(15);
        make.width.height.mas_equalTo(68);
    }];
    self.qrImg.layer.cornerRadius = 10.f;
    self.qrImg.layer.masksToBounds = YES;
    
    UILabel *dateTitleLab = [[UILabel alloc] init];
    dateTitleLab.font = [UIFont systemFontOfSize:14];
    dateTitleLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    dateTitleLab.text = @"Generate Date：";
    [self.contentView addSubview:dateTitleLab];
    [dateTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.qrImg);
        make.left.equalTo(self.qrImg.mas_right).offset(10);
    }];
    
    self.dateLab = [[UILabel alloc] init];
    self.dateLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    self.dateLab.font = [UIFont systemFontOfSize:12.f];
    self.dateLab.text = @"03/23/2022";
    [self.contentView addSubview:self.dateLab];
    [self.dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(dateTitleLab);
        make.left.equalTo(dateTitleLab.mas_right);
    }];
    
    UILabel *resTitleLab = [[UILabel alloc] init];
    resTitleLab.font = [UIFont systemFontOfSize:14];
    resTitleLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    resTitleLab.text = @"Result：";
    [self.contentView addSubview:resTitleLab];
    [resTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dateTitleLab.mas_bottom).offset(5);
        make.left.equalTo(dateTitleLab);
    }];
    
    self.resultLab = [[UILabel alloc] init];
    self.resultLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    self.resultLab.font = [UIFont systemFontOfSize:14.f];
    self.resultLab.text = @"baidu.com";
    [self.contentView addSubview:self.resultLab];
    [self.resultLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(resTitleLab);
        make.left.equalTo(resTitleLab.mas_right);
        make.right.mas_lessThanOrEqualTo(self.contentView).offset(-15);
    }];
    
    self.deleteImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_delete"]];
    [self.contentView addSubview:self.deleteImg];
    [self.deleteImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-7);
        make.right.equalTo(self.contentView).offset(-10);
        make.width.height.mas_equalTo(30);
    }];
    
    self.shareImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_share"]];
    [self.contentView addSubview:self.shareImg];
    [self.shareImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.deleteImg);
        make.right.equalTo(self.deleteImg.mas_left).offset(-10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(65);
    }];
    
}



@end
