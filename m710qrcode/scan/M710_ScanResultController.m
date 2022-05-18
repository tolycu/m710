//
//  M710_ScanResultController.m
//  m710qrcode
//
//  Created by xc-76 on 2022/4/22.
//

#import "M710_ScanResultController.h"
#import "Expert_WebViewController.h"

@interface M710_ScanResultController ()

@property (nonatomic ,strong) UILabel *dateLab;
@property (nonatomic ,strong) UITextView *resultView;

@property(nonatomic,assign) DataStringQRType type;

@end

@implementation M710_ScanResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.type = [Expert_GlobalMananger qrDataAnalysisType:self.resultStr];
    [self addSubViews_layout];
}

- (void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addSubViews_layout{
    UIImageView *bgView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"creat_resultBg"]];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(0.728*XCScreenW);
    }];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"navBack_white"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(self.view).offset(STATUS_HEIGHT+3);
        make.width.height.mas_equalTo(27);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.font = [UIFont systemFontOfSize:19 weight:UIFontWeightBold];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.text = @"Result";
    [self.view addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(STATUS_HEIGHT+10);
    }];
    
    UIView *contView = [[UIView alloc] init];
    contView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contView];
    [contView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
        make.height.mas_equalTo(kScaleWidth(210));
    }];
    contView.layer.cornerRadius = 14.f;
    contView.layer.shadowColor = [UIColor colorWithString:@"#E3E3E3"].CGColor;
    contView.layer.shadowOffset = CGSizeMake(0, 3);
    contView.layer.shadowOpacity = 0.5;
    contView.layer.shadowRadius = 8.f;
    
   
    self.dateLab = [[UILabel alloc] init];
    self.dateLab.text = self.dateStr;
    self.dateLab.textColor = [UIColor colorWithString:@"#999999"];
    self.dateLab.font = [UIFont systemFontOfSize:12.f];
    [contView addSubview:self.dateLab];
    [self.dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contView).offset(-15);
        make.top.equalTo(contView).offset(15);
    }];
    
    self.resultView = [[UITextView alloc] init];
    self.resultView.textColor = [UIColor colorWithString:@"#1A1A1A"];
    self.resultView.font = [UIFont systemFontOfSize:14.f];
    self.resultView.layer.cornerRadius = 8.f;
    self.resultView.layer.masksToBounds = YES;
    self.resultView.backgroundColor = [UIColor colorWithString:@"#F5F5F5"];
    self.resultView.showsVerticalScrollIndicator = NO;
    self.resultView.contentInset = UIEdgeInsetsMake(5, 10, 5, 10);
    self.resultView.editable = NO;
    self.resultView.text = self.resultStr;
    [contView addSubview:self.resultView];
    [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contView).offset(15);
        make.right.equalTo(contView).offset(-15);
        make.top.equalTo(self.dateLab.mas_bottom).offset(15);
        make.bottom.equalTo(contView).offset(-30);
    }];
    
    CGFloat item_w = (XCScreenW - 45)/3;
    CGFloat item_h = 0.71*item_w;
    
    
    DataStringQRType type = [Expert_GlobalMananger qrDataAnalysisType:self.resultStr];
    if (type == DataStringQRType_text ||
        type == DataStringQRType_wifi) {
        UIImageView *copyImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"result_copy"]];
        copyImg.userInteractionEnabled = YES;
        [copyImg jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [self copyClick];
        }];
        [self.view addSubview:copyImg];
        [copyImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contView.mas_bottom).offset(20);
            make.right.equalTo(self.view.mas_centerX).offset(-30);
            make.width.mas_equalTo(item_w);
            make.height.mas_equalTo(item_h);
        }];
        
        UIImageView *shareImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"creat_result_share"]];
        shareImg.userInteractionEnabled = YES;
        [shareImg jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [self shareClick];
        }];
        [self.view addSubview:shareImg];
        [shareImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(copyImg);
            make.left.equalTo(self.view.mas_centerX).offset(30);
            make.width.mas_equalTo(item_w);
            make.height.mas_equalTo(item_h);
        }];
    }else{
        UIImageView *copyImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"result_copy"]];
        copyImg.userInteractionEnabled = YES;
        [copyImg jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [self copyClick];
        }];
        [self.view addSubview:copyImg];
        [copyImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contView.mas_bottom).offset(20);
            make.left.equalTo(self.view).offset(15);
            make.width.mas_equalTo(item_w);
            make.height.mas_equalTo(item_h);
        }];
        
        UIImageView *shareImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"creat_result_share"]];
        shareImg.userInteractionEnabled = YES;
        [shareImg jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [self shareClick];
        }];
        [self.view addSubview:shareImg];
        [shareImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(copyImg);
            make.centerX.equalTo(self.view);
            make.width.mas_equalTo(item_w);
            make.height.mas_equalTo(item_h);
        }];
        
        UIImageView *openImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"result_open"]];
        openImg.userInteractionEnabled = YES;
        [openImg jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [self openClick];
        }];
        [self.view addSubview:openImg];
        [openImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(copyImg);
            make.right.equalTo(self.view).offset(-15);
            make.width.mas_equalTo(item_w);
            make.height.mas_equalTo(item_h);
        }];
    }
}

#pragma mark - 复制
- (void)copyClick{
    UIPasteboard * pastboard = [UIPasteboard generalPasteboard];
    pastboard.string = self.resultStr;
    [self.view makeToast:@"Copy Success" duration:1.f position:CSToastPositionCenter];
}

#pragma mark - 分享
- (void)shareClick{
    [TOOL_MANAGE startShareString:self.resultStr];
}

#pragma mark - 打开
- (void)openClick{
    switch (self.type) {
        case DataStringQRType_phone:
        {
            NSArray *tempArr = [self.resultStr componentsSeparatedByString:@":"];
            NSString *phone = [NSString stringWithFormat:@"telprompt://%@",tempArr.lastObject];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
        }
            break;
        case DataStringQRType_card:
        {
            [TOOL_MANAGE saveVCardNewContact:self.resultStr];
        }
            break;
        case DataStringQRType_url:
        {
            self.resultStr = [self.resultStr stringByReplacingOccurrencesOfString:@"www." withString:@""];
            NSArray *temp = [self.resultStr componentsSeparatedByString:@"://"];
            NSString *url = [NSString stringWithFormat:@"https://www.%@",temp.lastObject];
            Expert_WebViewController *vc = [Expert_WebViewController new];
            vc.url = url;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case DataStringQRType_barcode:
        {
            [TOOL_MANAGE showSelectPlatform:self.resultStr];
        }
            break;
            
        case DataStringQRType_Twitter:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.resultStr]];
        }
            break;
            
        case DataStringQRType_FB:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.resultStr]];
        }
            break;
        case DataStringQRType_whatsapp:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.resultStr]];
        }
            break;
        default:
            break;
    }
}

@end
