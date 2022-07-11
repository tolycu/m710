//
//  ADConfigManage.m
//  startvpn
//
//  Created by 李光尧 on 2020/12/9.
//

#import "ADConfigManage.h"


@interface ADConfigManage ()<GADAdLoaderDelegate,GADBannerViewDelegate,GADFullScreenContentDelegate,GADNativeAdDelegate,GADNativeAdLoaderDelegate,GADVideoControllerDelegate>

@property(nonatomic,strong) ADDataModel *adDataModel;

@property(nonatomic,strong) GADAdLoader *adLoader ;
@property(nonatomic,strong) GADBannerView *bannerView;
@property(nonatomic,strong) GADInterstitialAd *interstitial;

@end

@implementation ADConfigManage
- (void)setConfigModel:(ADConfigModel *)configModel{
    if (configModel) {
        _configModel = configModel;
        
        NSDate *date = [NSDate jk_dateWithHoursBeforeNow:1];
        if (configModel.expert_adSwitch && configModel.expert_adSource.count) {
            if (configModel.model && configModel.requestAD) {
                if ( [configModel.cacheDate jk_isEarlierThanDate:date]) {
                    self.adDataModel = configModel.expert_adSource.firstObject;
                    [self startCreatAD];
                }
            }else{
                self.adDataModel = configModel.expert_adSource.firstObject;
                [self startCreatAD];
            }
        }
    }
}

- (void)startCreatAD{
    
    ADDataType type = [ADConfigSetting getLoadADtype:self.adDataModel.expert_type];
    switch (type) {
        case ADDataType_nav:
        {
            if ([ADConfigSetting isLimitShowADWithAllowForkey:APP_Native_Count]) {
                [self createAndLoadAdLoade:self.adDataModel];
            }
        }
            break;
        case ADDataType_int:
        {
            [self createAndLoadInterstitial:self.adDataModel];
        }
            break;
        case ADDataType_open:
        {
            [self createAppOpenAdLoade:self.adDataModel];
        }
            break;
        case ADDataType_banner:
        {
            if ([ADConfigSetting isLimitShowADWithAllowForkey:APP_Banner_Count]) {
                [self createAppBannerViewLoade:self.adDataModel];
            }
        }
            break;
        default:
            break;
    }
}

- (void)resetStartLoadAD{
    NSInteger index = [self.configModel.expert_adSource indexOfObject:self.adDataModel];
    if (index == self.configModel.expert_adSource.count-1) {
        return;
    }
    self.adDataModel = [self.configModel.expert_adSource jk_objectWithIndex:index+1];
    if (!self.adDataModel) {
        return;
    }
    [self startCreatAD];
}

#pragma mark - ABDMob插屏广告
- (void)createAndLoadInterstitial:(ADDataModel *)model {
    GADRequest *request = [GADRequest request];
    [GADInterstitialAd loadWithAdUnitID:model.expert_placeId request:request completionHandler:^(GADInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
        if (error) {
            NSLog(@"插页广告---加载失败");
            [FIRAnalytics logEventWithName:LoadFinishAds parameters:@{@"status":@"success",@"id":model.expert_placeId}];
            [self resetStartLoadAD];
            return;
        }
        NSLog(@"插页广告---加载成功");
        [FIRAnalytics logEventWithName:LoadFinishAds parameters:@{@"status":@"fail",@"id":model.expert_placeId}];
        self.configModel.model = self.adDataModel;
        self.configModel.requestAD = interstitialAd;
        self.configModel.cacheDate = [NSDate date];
    }];
}

#pragma mark - ABDMob激励视频  / GADRewardedAdDelegate
- (void)createAndLoadRewardedAd:(ADDataModel *)model{
    
    GADRequest *request = [GADRequest request];
    [GADRewardedAd loadWithAdUnitID:model.expert_placeId
                            request:request
                  completionHandler:^(GADRewardedAd *ad, NSError *error) {
        
        if (error) {
            NSLog(@"激励广告---加载失败");
            [self resetStartLoadAD];
            return;
        }
        NSLog(@"激励广告---加载成功");
        self.configModel.model = model;
        self.configModel.requestAD = ad;
        self.configModel.cacheDate = [NSDate date];
    }];
}

#pragma mark - ABDMob原生广告 / GADAdLoader
- (void)createAndLoadAdLoade:(ADDataModel *)model{
    GADMultipleAdsAdLoaderOptions *multipleAdsOptions =
          [[GADMultipleAdsAdLoaderOptions alloc] init];
      multipleAdsOptions.numberOfAds = 1;
    GADAdLoader *adLoader = [[GADAdLoader alloc] initWithAdUnitID:model.expert_placeId
                                       rootViewController:[self currentController]
                                                          adTypes:@[GADAdLoaderAdTypeNative]
                                                  options:@[multipleAdsOptions]];
    self.adLoader = adLoader;
    adLoader.delegate = self;
    [adLoader loadRequest:[GADRequest request]];
}

- (void)adLoader:(nonnull GADAdLoader *)adLoader didFailToReceiveAdWithError:(nonnull NSError *)error{
    NSLog(@"原生广告---加载失败");
    [FIRAnalytics logEventWithName:LoadNativeAds parameters:@{@"status":@"fail",@"id":self.adDataModel.expert_placeId}];
    [self resetStartLoadAD];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    NSLog(@"原生广告---加载成功");
    [FIRAnalytics logEventWithName:LoadNativeAds parameters:@{@"status":@"success",@"id":self.adDataModel.expert_placeId}];
    self.configModel.requestAD = nativeAd;
    self.configModel.model = self.adDataModel;
    self.configModel.cacheDate = [NSDate date];
}

#pragma mark - ABDMob横幅广告
- (void)createAppBannerViewLoade:(ADDataModel *)model{
    
    GADBannerView *bannerView = [[GADBannerView alloc] init];
    self.bannerView = bannerView;
    CGFloat viewWidth = XCScreenW - 30;
    bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);
    bannerView.adUnitID = model.expert_placeId;
    bannerView.rootViewController = [self currentController];
    bannerView.delegate = self;
    [bannerView loadRequest:[GADRequest request]];
}

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"横幅广告---加载成功");
    self.configModel.requestAD = bannerView;
    self.configModel.model = self.adDataModel;
    self.configModel.cacheDate = [NSDate date];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"横幅广告---加载失败");
    [self resetStartLoadAD];
}

#pragma mark - 开屏广告
- (void)createAppOpenAdLoade:(ADDataModel *)model{
    [GADAppOpenAd loadWithAdUnitID:model.expert_placeId
                           request:[GADRequest request]
                       orientation:UIInterfaceOrientationPortrait
                 completionHandler:^(GADAppOpenAd * _Nullable appOpenAd, NSError * _Nullable error) {
        if (appOpenAd) {
            NSLog(@"开屏广告---加载成功");
            [FIRAnalytics logEventWithName:LoadStartAds parameters:@{@"status":@"success",@"id":model.expert_placeId}];
            appOpenAd.fullScreenContentDelegate = self;
            self.configModel.requestAD = appOpenAd;
            self.configModel.model = self.adDataModel;
            self.configModel.cacheDate = [NSDate date];
        }else{
            NSLog(@"开屏广告---加载失败");
            [FIRAnalytics logEventWithName:LoadStartAds parameters:@{@"status":@"fail",@"id":model.expert_placeId}];
            [self resetStartLoadAD];
        }
    }];
}

@end


@implementation ADManage

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static ADManage *adManage;
    dispatch_once(&onceToken, ^{
        adManage = [self new];
    });
    return adManage;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.adConfigs = [NSMutableArray array];
    }
    return self;
}

- (void)resetADConfigManage{
    NSArray<ADConfigManage *> *tempConfigs = [self.adConfigs copy];
    [self.adConfigs removeAllObjects];
    [tempConfigs jk_each:^(ADConfigManage *manage) {
        manage.configModel = manage.configModel;
        [self.adConfigs addObject:manage];
    }];
}

@end
