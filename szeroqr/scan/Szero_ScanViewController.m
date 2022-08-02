//
//  Szero_ScanViewController.m
//  sportqr
//
//  Created by Hoho Wu on 2022/2/27.
//

#import "Szero_ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Szero_QRManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "XKConsoleBoard.h"
#import "Szero_ScanResultController.h"


@interface Szero_ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,GADBannerViewDelegate>
{
    CGFloat layout_W;
    CGFloat TOP;
    CGFloat LEFT;
    CGRect kScanRect;
    CGRect kContRect;
    int num;
    CAShapeLayer *cropLayer;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (strong,nonatomic)AVCaptureConnection * connection;

@property (nonatomic, strong) UIImageView * line;
@property (nonatomic, strong) NSTimer *timer;
@property(nonatomic,strong) UIButton *localImage;
@property(nonatomic,strong) UIButton *flashBtn;

@property(nonatomic,assign) BOOL isDidLoad;
@property(nonatomic,strong) UISlider *slider;
@property(nonatomic,assign) BOOL isShowAlter;


//底部横幅广告
@property(nonatomic,strong) ADConfigModel *bannerModel;
@property(nonatomic,strong) GADBannerView *bannerView;
@property(nonatomic,strong) NSTimer *loadTimer;
@property(nonatomic,assign) NSInteger longTime; //检测广告时长 30s
@property(nonatomic,assign) BOOL isClickNative;  //点击底部原生广告

@end

@implementation Szero_ScanViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [FIRAnalytics logEventWithName:Show_Home parameters:nil];
    if (self.session != nil && self.timer != nil) {
        [self.session startRunning];
        [self.timer setFireDate:[NSDate date]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:App_CloseFlash object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.slider.value = 0;
    if (APP_CONFIG.isLoadCamera) {
        [self extracted];
    }
    [self showBannerAD];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //页面消失，采集关闭
    [self backConfig];
    [self.session stopRunning];
    if (self.flashBtn.selected) {
        [self openFlash:self.flashBtn];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //UI 部分
    [self changeIpadLayout];
    [self setCropRect:kScanRect];
    [self addSubView_layout];
    [self configView];
    [self firstSetupCamera];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

- (void)becomBackground{
    self.flashBtn.selected = NO;
}

- (void)topSelectPhotClick:(UIButton *)button{
    [self isCanVisitPhotoLibrary:^(BOOL isAllow) {
        if (isAllow) {
            [self selectPhoto];
        }else{
            NSLog(@"去设置中打开权限");
        }
    }];
}

- (void)firstSetupCamera{
    if (!self.device) {
        [self scanConfig];
        APP_CONFIG.isLoadCamera = YES;
        AVAuthorizationStatus status =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
            [self performSelector:@selector(showAlterPrivacy) withObject:nil afterDelay:1];
        }
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APP_Camera_Alert];
    }
}

- (void)showAlterPrivacy{
    if (self.isShowAlter) {
        self.isShowAlter = NO;
        return;
    }
    [TOOL_MANAGE showAlterToPrivacy:APP_Camera_Alert];
}

- (void)extracted {
    [self isCanVisitCamera:^(BOOL isAllow, BOOL isShow) {
        if (![NSUserDefaults jk_boolForKey:APP_Camera]) {
            [self scanConfig];
            return;
        }
        if (isAllow) {
            [self scanConfig];
        }
        if (isShow) {
            self.isShowAlter = YES;
            [TOOL_MANAGE showAlterToPrivacy:APP_Camera_Alert];
        }
    }];
}

- (void)scanConfig{
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device==nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tips" message:@"The device does not have a camera" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    // Device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    
    //设置扫描区域
//    CGFloat top = TOP/XCScreenH;
//    CGFloat left = LEFT/XCScreenW;
//    CGFloat width = layout_W/XCScreenW;
//    CGFloat height = layout_W/XCScreenH;
    ///top 与 left 互换  width 与 height 互换
//    [self.output setRectOfInterest:CGRectMake(TOP,LEFT, layout_W, layout_W)];
    [self.output setRectOfInterest:CGRectMake(0, 0, 1, 1)]; //这里是百分比

   
    // Session
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input]){
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output]){
        [self.session addOutput:self.output];
    }
    
    AVCapturePhotoOutput *outPut = (AVCapturePhotoOutput *)[self.session.outputs objectAtIndex:0];
    self.connection = [outPut connectionWithMediaType:AVMediaTypeVideo];
    
    AVAuthorizationStatus status =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined || status == AVAuthorizationStatusAuthorized){
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                            AVMetadataObjectTypeEAN13Code,
                                            AVMetadataObjectTypeEAN8Code,
                                            AVMetadataObjectTypeCode128Code];
        
        // Preview
        self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.preview.frame =self.view.layer.bounds;
        [self.view.layer insertSublayer:self.preview atIndex:0];
        
//        // Start 这里是垃圾代码
        [self.session startRunning];
    }
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *stringValue;
    if ([metadataObjects count] >0){
        AVMetadataMachineReadableCodeObject *av = metadataObjects.firstObject;
        NSDictionary *dict = [av mj_JSONObject];

        //停止扫描
        [self.session stopRunning];
        //暂停扫描动画
        [self.timer setFireDate:[NSDate distantFuture]];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        if (![[dict objectForKey:@"type"] jk_containsaString:@"QR"] && [Szero_GlobalMananger deptNumInputShouldNumber:stringValue]) {
            stringValue = [NSString stringWithFormat:@"Product:%@",stringValue];
        }
        [self pushResultVC:stringValue];
        
    } else {
        [self.view makeToast:@"Unable to read information"];
        return;
    }
}

/**
 跳转到结果界面
 */
- (void)pushResultVC:(NSString *)stringValue{
   
    DataStringQRType type = [Szero_GlobalMananger qrDataAnalysisType:stringValue];
    [FIRAnalytics logEventWithName:ScanSucceed parameters:@{@"type":[Szero_GlobalMananger qrTypeString:type]}];
    
    [TOOL_MANAGE saveScan:stringValue];
    
    NSString *dateStr = [NSDate jk_currentDateStringWithFormat:@"MM/dd/YYYY HH:mm:ss"];
    Szero_ScanResultController *vc = [[Szero_ScanResultController alloc] init];
    vc.resultStr = stringValue;
    vc.dateStr = dateStr;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openFlash:(UIButton *)sender{
    if ([Szero_GlobalMananger checkoutDeviceIsiPad]) {
        return;
    }
    //获取当前相机的方向（前/后）
    AVCaptureDevicePosition position = [[self.input device] position];
    if (position == AVCaptureDevicePositionFront) {
        return;
    }
    sender.selected = !sender.selected;
    if (sender.isSelected == YES) {
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

-(AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
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

#pragma mark - 相机权限检测
- (void)isCanVisitCamera:(void(^)(BOOL isAllow, BOOL isShow))result {

//    AVAuthorizationStatusNotDetermined = 0, 用户尚未做出选择
//    AVAuthorizationStatusRestricted    = 1, 此应用程序没有被授权，可能是家长控制权限
//    AVAuthorizationStatusDenied        = 2, 用户已经明确否认了权限
//    AVAuthorizationStatusAuthorized    = 3, 用户已经授权
    
    AVAuthorizationStatus status =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        result(NO,NO);
        return;
    }else if (status == AVAuthorizationStatusRestricted || status ==AVAuthorizationStatusDenied ) {
        result(NO,YES);
        return ;
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APP_Camera];
        result(NO,NO);
    }
}

#pragma mark - 从相册中选择
- (void)selectPhoto{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
          UIImagePickerController *picker = [[UIImagePickerController alloc] init];
          picker.delegate = self;
          picker.allowsEditing = NO;
          picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
          [self presentViewController:picker animated:YES completion:nil];
      }
}

//获取到图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSString *result = [Szero_QRManager readQRCodeFromImage:image];
        if (result.length) {
            [self pushResultVC:result];
        }else{
            [self.view makeToast:@"Unable to read information" duration:1.0 position:CSToastPositionCenter];
        }
       
    }];
}


- (void)addSubView_layout{
    [self hideBackItem];
    
    UIView *hearView = [[UIView alloc] init];
    hearView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:hearView];
    [hearView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScaleWidth(250));
        make.height.mas_equalTo(44);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(TOP_HEIGHT);
    }];
    hearView.layer.cornerRadius = 10.f;
    hearView.layer.masksToBounds = YES;
    
    UIButton *flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashBtn setImage:[UIImage imageNamed:@"i_flash_off"] forState:UIControlStateNormal];
    [flashBtn setImage:[UIImage imageNamed:@"i_flash"] forState:UIControlStateSelected];
    [flashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
    [hearView addSubview:flashBtn];
    self.flashBtn = flashBtn;
    [flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(hearView.mas_centerX).offset(-kScaleWidth(50));
        make.centerY.equalTo(hearView);
        make.width.height.mas_equalTo(24);
    }];
 
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoBtn setImage:[UIImage imageNamed:@"i_photo"] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(topSelectPhotClick:) forControlEvents:UIControlEventTouchUpInside];
    [hearView addSubview:photoBtn];
    [photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(hearView.mas_centerX).offset(kScaleWidth(50));
        make.centerY.equalTo(hearView);
        make.width.height.mas_equalTo(24);
    }];
}


-(void)configView{
    
    UIView *bgView = [[UIView alloc] initWithFrame:kContRect];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    
    UIImageView * imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"scanner_boder"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [bgView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bgView);
    }];

    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT, TOP+TOP_HEIGHT, layout_W, 0.513*layout_W)];
    _line.image = [UIImage imageNamed:@"pic_scan_link"];
    _line.contentMode = UIViewContentModeScaleAspectFill;
    _line.clipsToBounds = YES;
    [self.view addSubview:_line];
    
    self.slider = [[UISlider alloc] init];
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 1;
    self.slider.maximumTrackTintColor = [UIColor colorWithString:@"#52CCBB"];
    self.slider.minimumTrackTintColor = [UIColor colorWithString:@"#52CCBB"];
    self.slider.thumbTintColor = [UIColor colorWithString:@"#52CCBB"];
    [self.slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(self.view);
        make.top.equalTo(imageView.mas_bottom).offset(55);
    }];
    
    UIImageView *leftImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_jian"]];
    [self.view addSubview:leftImg];
    [leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(2);
        make.centerY.equalTo(self.slider);
        make.right.equalTo(self.slider.mas_left).offset(-5);
    }];
    
    UIImageView *rightImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_jia"]];
    [self.view addSubview:rightImg];
    [rightImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(15);
        make.centerY.equalTo(self.slider);
        make.left.equalTo(self.slider.mas_right).offset(5);
    }];
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animationLink) userInfo:nil repeats:YES];
}

- (void)sliderChange:(UISlider *)slider{
    [self.preview setAffineTransform:CGAffineTransformMakeScale(slider.value+1, slider.value+1)];
    self.connection.videoScaleAndCropFactor = slider.value+1;
}

- (void)backConfig{
    [self.preview setAffineTransform:CGAffineTransformMakeScale(1, 1)];
    self.connection.videoScaleAndCropFactor = 1;
}

-(void)animationLink{
    num = num+2;
    _line.frame = CGRectMake(LEFT, TOP+num , layout_W, 0.513*layout_W);
    if (num > layout_W-78) {
        CGFloat alpha = ((layout_W-38)-num)/40;
        _line.alpha = alpha;
    }
    if (num >= layout_W - 38) {
        _line.frame = CGRectMake(LEFT, TOP, layout_W, 0.513*layout_W);
        _line.alpha = 1;
        num = 0;
    }
}

- (void)setCropRect:(CGRect)cropRect{
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-TABBAR_HEIGHT);
    }];
    
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);

    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.5];
    [cropLayer setNeedsDisplay];
    [contentView.layer addSublayer:cropLayer];
}

- (void)changeIpadLayout{
    layout_W = kScaleWidth(230);
    TOP = (XCScreenH - layout_W )/2-TOP_HEIGHT;
    LEFT = (XCScreenW-layout_W)/2;
    kScanRect = CGRectMake(LEFT, TOP , layout_W, layout_W);
    kContRect = CGRectMake(LEFT-15, TOP-15, layout_W + 30, layout_W+30);
}

#pragma mark - 底部广告
- (void)showBannerAD{
    if (!self.loadTimer) {
        self.longTime = 0;
        self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadShowBannerAD) userInfo:nil repeats:YES];
    }
}

- (void)loadShowBannerAD{
    self.longTime = +2;
    if (self.longTime > 30 && self.loadTimer) {
        [self.loadTimer invalidate];
        self.loadTimer = nil;
    }
    
    self.bannerModel = [ADConfigSetting filterADPosition:ADPositionType_home];
    if (!self.bannerModel) {
        return;
    }
    [self.loadTimer invalidate];
    self.loadTimer = nil;
    ADDataType temp = [ADConfigSetting getLoadADtype:self.bannerModel.model.expert_type];
    if(temp == ADDataType_banner &&
       [NSStringFromClass([self.bannerModel.requestAD class]) isEqualToString:@"GADBannerView"]){
        self.bannerView = (GADBannerView *)self.bannerModel.requestAD;
        self.bannerView.rootViewController = self;
        self.bannerView.delegate = self;
        [self.view addSubview:self.bannerView];
        [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-10);
            make.height.mas_equalTo(50);
        }];
    }
}

- (void)bannerViewDidRecordClick:(nonnull GADBannerView *)bannerView{
    [ADConfigSetting clickADWithAddLimitForkey:APP_Banner_Count];
    if (![ADConfigSetting isLimitShowADWithAllowForkey:APP_Banner_Count]) {
        self.bannerView.hidden = YES;
        [self.bannerView removeFromSuperview];
    }
}

//-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
//   [[XKConsoleBoard borad] show];
//}

@end

