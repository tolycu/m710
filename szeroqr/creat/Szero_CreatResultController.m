//
//  Szero_CreatResultController.m
//  szeroqr
//
//  Created by xc-76 on 2022/4/22.
//

#import "Szero_CreatResultController.h"
#import "Szero_QRManager.h"
#import <Photos/Photos.h>

@interface Szero_CreatResultController ()<GADNativeAdDelegate>

@property (nonatomic ,strong) UIScrollView *scrollView;
@property (nonatomic ,strong) UIView *contView;

@property (nonatomic ,strong) UIImageView *qrImg;
@property (nonatomic ,strong) UILabel *dateLab;
@property (nonatomic ,strong) UITextView *resultView;
@property (nonatomic ,strong) UIImageView *saveImg;
@property (nonatomic ,strong) UIImage *qrcode;

@property MASConstraint *contViewBottom;

//底部横幅广告
@property(nonatomic,strong) ADConfigModel *bannerModel;
@property(nonatomic,strong) GADNativeAd *nativeAd;
@property(nonatomic,strong) GADNativeAdView *nativeAdView;
@property(nonatomic,assign) BOOL isClickNative;  //点击底部原生广告

@end

@implementation Szero_CreatResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews_layout];
    [self loadShowBannerAD];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomActivebecomActive) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self showFinishAD];
}

- (void)becomActivebecomActive{
    if (self.isClickNative) {
        [self loadShowBannerAD];
        self.isClickNative = NO;
    }
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
    titleLab.text = @"Generated Qr Code";
    [self.view addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(STATUS_HEIGHT+10);
    }];
    
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
        make.bottom.equalTo(self.view).offset(-SYSTEM_GESTURE_HEIGHT);
    }];
    
    self.contView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contView];
    [self.contView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.width.equalTo(self.scrollView);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    UIView *contView = [[UIView alloc] init];
    contView.backgroundColor = [UIColor whiteColor];
    [self.contView addSubview:contView];
    [contView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contView).offset(15);
        make.right.equalTo(self.contView).offset(-15);
        make.top.equalTo(self.contView);
        make.height.mas_equalTo(kScaleWidth(300));
    }];
    contView.layer.cornerRadius = 14.f;
    contView.layer.shadowColor = [UIColor colorWithString:@"#E3E3E3"].CGColor;
    contView.layer.shadowOffset = CGSizeMake(0, 3);
    contView.layer.shadowOpacity = 0.5;
    contView.layer.shadowRadius = 8.f;
    
    self.qrImg = [[UIImageView alloc] init];
    self.qrcode = [Szero_QRManager createQRimageString:self.resultStr sizeWidth:127 fillColor:[UIColor blackColor]];
    self.qrImg.image = self.qrcode;
    [contView addSubview:self.qrImg];
    [self.qrImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(127);
        make.centerX.equalTo(contView);
        make.top.equalTo(contView).offset(20);
    }];
    
    UILabel *dateTitleLab = [[UILabel alloc] init];
    dateTitleLab.text = @"Generate Date：";
    dateTitleLab.textColor = [UIColor colorWithString:@"#999999"];
    dateTitleLab.font = [UIFont systemFontOfSize:14.f];
    [contView addSubview:dateTitleLab];
    [dateTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contView).offset(15);
        make.top.equalTo(self.qrImg.mas_bottom).offset(12);
    }];
    
    self.dateLab = [[UILabel alloc] init];
    self.dateLab.text = self.dateStr;
    self.dateLab.textColor = [UIColor colorWithString:@"#1A1A1A"];
    self.dateLab.font = [UIFont systemFontOfSize:14.f];
    [contView addSubview:self.dateLab];
    [self.dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dateTitleLab);
        make.top.equalTo(dateTitleLab.mas_bottom).offset(5);
    }];
    
    UILabel *resTitleLab = [[UILabel alloc] init];
    resTitleLab.text = @"Content：";
    resTitleLab.textColor = [UIColor colorWithString:@"#999999"];
    resTitleLab.font = [UIFont systemFontOfSize:14.f];
    [contView addSubview:resTitleLab];
    [resTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dateTitleLab);
        make.top.equalTo(self.dateLab.mas_bottom).offset(12);
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
        make.left.equalTo(resTitleLab);
        make.right.equalTo(contView).offset(-15);
        make.top.equalTo(resTitleLab.mas_bottom).offset(5);
        make.bottom.equalTo(contView).offset(-15);
    }];
    
    UIImageView *saveImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"creat_result_save"]];
    [saveImg jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [self saveClick];
    }];
    saveImg.userInteractionEnabled = YES;
    [self.contView addSubview:saveImg];
    self.saveImg = saveImg;
    [saveImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contView.mas_bottom).offset(20);
        make.right.equalTo(self.contView.mas_centerX).offset(-35);
        make.width.mas_equalTo(kScaleWidth(110));
        make.height.mas_equalTo(kScaleWidth(78));
        self.contViewBottom = make.bottom.equalTo(self.contView);
    }];
    
    UIImageView *shareImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"creat_result_share"]];
    [shareImg jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [self shareClick];
    }];
    shareImg.userInteractionEnabled = YES;
    [self.view addSubview:shareImg];
    [shareImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(saveImg);
        make.left.equalTo(self.contView.mas_centerX).offset(35);
        make.width.mas_equalTo(kScaleWidth(110));
        make.height.mas_equalTo(kScaleWidth(78));
    }];
}

#pragma mark - 相册权限检测
- (void)isCanVisitPhotoLibrary:(void(^)(BOOL isAllow))result {

    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        result(YES);
    }else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted){
        [TOOL_MANAGE showAlterToPrivacy:APP_Photo_Alert];
        result(NO);
    }else{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // 回调是在子线程的
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    result(YES);
                }else{
                    result(NO);
                }
            });
        }];
    }
}

- (void)saveClick{
    [self isCanVisitPhotoLibrary:^(BOOL isAllow) {
        if (isAllow) {
            [self savePhoto];
        }
    }];
}

- (void)savePhoto{
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:self.qrcode];
     } completionHandler:^(BOOL success, NSError * _Nullable error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (!error) {
                 [self.view makeToast:@"Save Success" duration:1.f position:CSToastPositionCenter];
             }
         });
    }];
}

- (void)shareClick{
    [TOOL_MANAGE startShareImage:self.qrcode];
}

#pragma mark - 完成广告
- (void)showFinishAD{
    ADConfigModel *configModel = [ADConfigSetting filterADPosition:ADPositionType_extra];
    if (!configModel) {return; }
    [FIRAnalytics logEventWithName:ShowFinishAds parameters:@{@"id":configModel.model.expert_placeId}];
    ADDataType adType = [ADConfigSetting getLoadADtype:configModel.model.expert_type];
    if (adType == ADDataType_int && [NSStringFromClass([configModel.requestAD class]) isEqualToString:@"GADInterstitialAd"]){
        GADInterstitialAd *interstitial = (GADInterstitialAd *)configModel.requestAD;
        [interstitial presentFromRootViewController:[self currentController]];
        configModel.requestAD = nil;
        [AD_MANAGE resetADConfigManage];
    }
}

#pragma mark - 加载ADMob原生广告
- (void)loadShowBannerAD{
    self.bannerModel = [ADConfigSetting filterADPosition:ADPositionType_report];
    if (!self.bannerModel) {
        [self.contViewBottom install];
        return;
    }
    [FIRAnalytics logEventWithName:ShowNativeAds parameters:@{@"id":self.bannerModel.model.expert_placeId}];
    ADDataType temp = [ADConfigSetting getLoadADtype:self.bannerModel.model.expert_type];
    if(temp == ADDataType_nav &&
       [NSStringFromClass([self.bannerModel.requestAD class]) isEqualToString:@"GADNativeAd"]){
        self.nativeAd = (GADNativeAd *)self.bannerModel.requestAD;
        self.nativeAd.delegate = self;
        [self loadadNativeAd:self.nativeAd];
    }
}

- (void)loadadNativeAd:(nonnull GADNativeAd *)nativeAd{
    GADNativeAdView *nativeAdView = [[NSBundle mainBundle] loadNibNamed:@"UnifiedNativeAdView" owner:nil options:nil].lastObject;
    nativeAdView.userInteractionEnabled = YES;
    nativeAdView.backgroundColor = [UIColor colorWithString:@"#E0E0E0"];
    [self.contView addSubview:nativeAdView];
    self.nativeAdView = nativeAdView;
    
    [self.contViewBottom uninstall];
    [nativeAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.saveImg.mas_bottom).offset(15);
        make.width.mas_equalTo(XCScreenW - 30);
        make.height.mas_equalTo(300);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.contView).offset(-30);
    }];
    nativeAdView.layer.cornerRadius = 10.f;
    nativeAdView.layer.masksToBounds = YES;

    nativeAdView.nativeAd = nativeAd;
    nativeAdView.mediaView.contentMode = UIViewContentModeScaleAspectFill;
    nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;
 
    ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
    
    ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
    nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;
    
    [((UIButton *)nativeAdView.callToActionView)setTitle:nativeAd.callToAction forState:UIControlStateNormal];
      nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;
    
    ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
      nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;
    
    nativeAdView.callToActionView.userInteractionEnabled = NO;
    
    self.bannerModel.requestAD = nil;
    [AD_MANAGE resetADConfigManage];
}

- (void)nativeAdDidRecordClick:(nonnull GADNativeAd *)nativeAd{
    self.isClickNative = YES;
    self.nativeAdView.hidden = YES;
    [self.nativeAdView removeFromSuperview];
    [ADConfigSetting clickADWithAddLimitForkey:APP_Native_Count];
}

@end
