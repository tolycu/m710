//
//  SettingViewCell.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/22.
//

#import "SettingViewCell.h"

@interface SettingViewCell ()

@property (nonatomic ,strong) UIImageView *icon;
@property (nonatomic ,strong) UILabel *titleLab;
@property (nonatomic ,strong) UIImageView *rightImg;

@end

@implementation SettingViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubView_layout];
    }
    return self;
}

- (void)setDict:(NSDictionary *)dict{
    if (dict) {
        _dict = dict;
        self.icon.image = [UIImage imageNamed:dict[@"img"]];
        self.titleLab.text = dict[@"title"];
        self.rightImg.hidden = [dict[@"isSwitch"] boolValue];
        self.switchBtn.hidden = !self.rightImg.hidden;
        
        if ([dict[@"title"] isEqualToString:@"Save History"]) {
            self.switchBtn.on = [NSUserDefaults jk_boolForKey:APP_QRCode_Cache];
        }
    }
}

- (void)hideRightBtn{
    self.rightImg.hidden = YES;
    self.switchBtn.hidden = YES;
}

- (void)switchChange:(UISwitch*)sw {
    if ([self.dict[@"title"] isEqualToString:@"Save History"]) {
        [NSUserDefaults jk_setObject:@(sw.on) forKey:APP_QRCode_Cache];
    }else{
        [self openFlash:sw.on];
    }
}

- (void)openFlash:(BOOL)isOpen{
    if ([Expert_GlobalMananger checkoutDeviceIsiPad]) {
        return;
    }
    if (isOpen == YES) {
        //打开闪光灯
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        if ([captureDevice hasTorch]) {
            BOOL locked = [captureDevice lockForConfiguration:&error];
            if (locked) {
                captureDevice.torchMode = AVCaptureTorchModeOn;
                [captureDevice unlockForConfiguration];
            }
        }
    }else{
         //关闭闪光灯
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }
}

- (void)addSubView_layout{
    self.contentView.layer.cornerRadius = 10.f;
    self.contentView.layer.masksToBounds = YES;
    
    self.icon = [[UIImageView alloc] init];
    [self.contentView addSubview:self.icon];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(22);
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(17);
    }];
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.font = [UIFont systemFontOfSize:14];
    self.titleLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    [self.contentView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.icon.mas_right).offset(10);
    }];
    
    self.rightImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"set_arrow"]];
    [self.contentView addSubview:self.rightImg];
    [self.rightImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(24);
    }];
    
    self.switchBtn = [[UISwitch alloc] init];
    [self.switchBtn setOnTintColor: [UIColor colorWithString:@"#52CCBB"]];
    [self.switchBtn setThumbTintColor: [UIColor colorWithString:@"#F0F0F0"]];
    [self.switchBtn setTintColor:[UIColor grayColor]];
    self.switchBtn.on = NO;
    [self.switchBtn addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.switchBtn];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-15);
    }];
}
@end
