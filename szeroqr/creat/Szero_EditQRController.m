//
//  Szero_EditQRController.m
//  szeroqr
//
//  Created by xc-76 on 2022/4/26.
//

#import "Szero_EditQRController.h"

#import "Szero_CreatResultController.h"

#import "Szero_TextField.h"
#import "Szero_TextView.h"
#import "SelectNavgidueView.h"
#import "Szero_CreatUrlCell.h"

@interface Szero_EditQRController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic ,strong) UIButton *nextBtn;

//card  Whatsapp
@property (nonatomic ,strong) Szero_TextField *nameTF;
@property (nonatomic ,strong) Szero_TextField *phoneTF;
@property (nonatomic ,strong) Szero_TextField *emailTF;
@property (nonatomic ,strong) Szero_TextField *birthdayTF;

// twitter facebook text
@property (nonatomic ,strong) Szero_TextView *nameView;
@property (nonatomic ,strong) Szero_TextView *urlView;
@property (nonatomic ,assign) NSInteger index;

// bar code
@property (nonatomic ,strong) UILabel *tipsLab;

// urls
@property (nonatomic ,strong) UICollectionView *collectView;
@property (nonatomic ,strong) NSArray *dataList;


@end

@implementation Szero_EditQRController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubView_layout];
}

#pragma mark --- 进入结果页
- (void)nextClick:(UIButton *)button{
    Szero_CreatResultController *vc = [[Szero_CreatResultController alloc] init];
    NSString *tempstr ;
    switch (self.type) {
        case DataStringQRType_card:
        {
            NSString *string = @"BEGIN:VCARD\r\nVERSION:3.0";
            if (self.nameTF.text.length) {
                string = [NSString stringWithFormat:@"%@\r\nN:%@",string,self.nameTF.text];
            }
            if (self.phoneTF.text.length) {
                string = [NSString stringWithFormat:@"%@\r\nTEL:%@",string,self.phoneTF.text];
            }else{
                [self inputInfo];
                return;
            }
            if (self.emailTF.text.length) {
                string = [NSString stringWithFormat:@"%@\r\nEMAIL:%@",string,self.emailTF.text];
            }
            if (self.birthdayTF.text.length) {
                string = [NSString stringWithFormat:@"%@\r\nBDAY:%@",string,self.birthdayTF.text];
            }
            tempstr = string;
        }
            break;
            
        case DataStringQRType_Twitter:
        {
            if (self.index == 0) {
                if (self.nameView.text.length) {
                    tempstr = [NSString stringWithFormat:@"%@%@",QR_TwitterName,self.nameView.text];
                }else{
                    [self inputInfo];
                    return;
                }
            }else{
                if (self.urlView.text.length) {
                    tempstr = [NSString stringWithFormat:@"%@%@",QR_TwitterUrl,self.urlView.text];
                }else{
                    [self inputInfo];
                    return;
                }
            }
        }
            break;
            
        case DataStringQRType_barcode:
            if([Szero_GlobalMananger isBarCodeNumText:self.phoneTF.text]) {
                tempstr = [NSString stringWithFormat:@"Product:%@",self.phoneTF.text];
            }else{
                [self.view makeToast:@"Nothing can be Searched!"];
                return;
            }
            break;
            
        case DataStringQRType_FB:
        {
            if (self.index == 0) {
                if (self.nameView.text.length) {
                    tempstr = [NSString stringWithFormat:@"%@%@",QR_fbID,self.nameView.text];
                }else{
                    [self inputInfo];
                    return;
                }
            }else{
                if (self.urlView.text.length) {
                    tempstr = [NSString stringWithFormat:@"%@%@",QR_fbUrl,self.urlView.text];
                }else{
                    [self inputInfo];
                    return;
                }
            }
        }
            break;
            
        case DataStringQRType_url:
        {
            if (self.urlView.text.length) {
                tempstr = [NSString stringWithFormat:@"%@",self.urlView.text];
            }else{
                [self inputInfo];
                return;
            }
        }
            break;
            
        case DataStringQRType_text:
        {
            if (self.nameView.text.length) {
                tempstr = [NSString stringWithFormat:@"%@",self.nameView.text];
            }else{
                [self inputInfo];
                return;
            }
        }
            break;
            
        case DataStringQRType_wifi:
        {
            NSString *str = @"WIFI:";
            if (self.nameTF.text.length && self.phoneTF.text.length) {
                str = [NSString stringWithFormat:@"%@S:%@;P:%@",str,self.nameTF.text,self.phoneTF.text];
                tempstr = str;
            }else{
                [self inputInfo];
                return;
            }
        }
            break;
            
        case DataStringQRType_whatsapp:
        {
            if (self.phoneTF.text.length) {
                tempstr = [NSString stringWithFormat:@"%@%@%@",QR_Whatsapp,[TOOL_MANAGE getDeviceISOCountryCode],self.phoneTF.text];
            }else{
                [self inputInfo];
                return;
            }
        }
            break;
            
        case DataStringQRType_phone:
        {
            if (self.nameTF.text.length) {
                tempstr = [NSString stringWithFormat:@"tel:%@",self.nameTF.text];
            }else{
                [self inputInfo];
                return;
            }
        }
            break;

        default:
            break;
    }
    
    DataStringQRType type = [Szero_GlobalMananger qrDataAnalysisType:tempstr];
    [FIRAnalytics logEventWithName:GenerateSucceed parameters:@{@"type":[Szero_GlobalMananger qrTypeString:type]}];
    
    [self showFinishAD];
    [TOOL_MANAGE saveCreat:tempstr];
    NSString *dateStr = [NSDate jk_currentDateStringWithFormat:@"MM/dd/YYYY HH:mm:ss"];
    vc.dateStr = dateStr;
    vc.resultStr = tempstr;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addSubView_layout{
    switch (self.type) {
        case DataStringQRType_card:
            [self creatCardView];
            break;
            
        case DataStringQRType_Twitter:
            [self creatTwitterView];
            break;
            
        case DataStringQRType_barcode:
            [self creatBarCodeView];
            break;
            
        case DataStringQRType_FB:
            [self creatFacebookView];
            break;
            
        case DataStringQRType_url:
            [self creatUrlsView];
            break;
            
        case DataStringQRType_text:
            [self creatTextView];
            break;
            
        case DataStringQRType_wifi:
            [self creatwifiView];
            break;
            
        case DataStringQRType_whatsapp:
            [self creatWhatsappView];
            break;
            
        case DataStringQRType_phone:
            [self creatPhoneNumberView];
            break;

        default:
            break;
    }
}

#pragma mark --- 创建Card
- (void)creatCardView{
    [self setTitleStr:@"Create Business cards"];
    
    self.nameTF = [[Szero_TextField alloc] init];
    self.nameTF.placeholder = @"Name";
    [self.view addSubview:self.nameTF];
    [self.nameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
        make.height.mas_equalTo(50);
    }];
    
    self.phoneTF = [[Szero_TextField alloc] init];
    self.phoneTF.placeholder = @"Phone Number";
    [self.view addSubview:self.phoneTF];
    [self.phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.nameTF.mas_bottom).offset(10);
        make.height.mas_equalTo(50);
    }];
    
    self.emailTF = [[Szero_TextField alloc] init];
    self.emailTF.placeholder = @"Email address";
    [self.view addSubview:self.emailTF];
    [self.emailTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.phoneTF.mas_bottom).offset(10);
        make.height.mas_equalTo(50);
    }];
    
    self.birthdayTF = [[Szero_TextField alloc] init];
    self.birthdayTF.placeholder = @"Birthday";
    [self.view addSubview:self.birthdayTF];
    [self.birthdayTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.emailTF.mas_bottom).offset(10);
        make.height.mas_equalTo(50);
    }];
    
    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.birthdayTF.mas_bottom).offset(40);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark --- 创建Twitter
- (void)creatTwitterView{
    
    [self setTitleStr:@"Create Twitter"];
    SelectNavgidueView *headerView = [[SelectNavgidueView alloc] initWithFrame:CGRectZero leftTitle:@"User Name" rightTitle:@"Url"];
    headerView.selectBlock = ^(NSInteger index) {
        NSLog(@"选择index ---- %ld",(long)index);
        self.index = index;
        self.nameView.hidden = index?YES:NO;
        self.urlView.hidden = index?NO:YES;
    };
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(TOP_HEIGHT+10);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(35);
    }];
    
    self.nameView = [[Szero_TextView alloc] init];
    [self.nameView addPlaceHolder:@"User Name"];
    [self.view addSubview:self.nameView];
    [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(headerView.mas_bottom).offset(15);
        make.height.mas_equalTo(100);
    }];
    
    self.urlView = [[Szero_TextView alloc] init];
    self.urlView.hidden = YES;
    [self.urlView addPlaceHolder:@"Url"];
    [self.view addSubview:self.urlView];
    [self.urlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(headerView.mas_bottom).offset(15);
        make.height.mas_equalTo(100);
    }];
    
    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.nameView.mas_bottom).offset(40);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark --- 创建FaceBook
- (void)creatFacebookView{
    
    [self setTitleStr:@"Create FaceBook"];
    SelectNavgidueView *headerView = [[SelectNavgidueView alloc] initWithFrame:CGRectZero leftTitle:@"FaceBook ID" rightTitle:@"Url"];
    headerView.selectBlock = ^(NSInteger index) {
        NSLog(@"选择index ---- %ld",(long)index);
        self.index = index;
        self.nameView.hidden = index?YES:NO;
        self.urlView.hidden = index?NO:YES;
    };
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(TOP_HEIGHT+10);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(35);
    }];
    
    self.nameView = [[Szero_TextView alloc] init];
    [self.nameView addPlaceHolder:@"FaceBook ID"];
    [self.view addSubview:self.nameView];
    [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(headerView.mas_bottom).offset(15);
        make.height.mas_equalTo(100);
    }];
    
    self.urlView = [[Szero_TextView alloc] init];
    self.urlView.hidden = YES;
    [self.urlView addPlaceHolder:@"Url"];
    [self.view addSubview:self.urlView];
    [self.urlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(headerView.mas_bottom).offset(15);
        make.height.mas_equalTo(100);
    }];
    
    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.nameView.mas_bottom).offset(40);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark --- 创建WhatsApp
- (void)creatWhatsappView{
    [self setTitleStr:@"Create WhatsApp"];
    
    self.phoneTF = [[Szero_TextField alloc] init];
    self.phoneTF.placeholder = @"Phone Number";
    [self.view addSubview:self.phoneTF];
    [self.phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
        make.height.mas_equalTo(50);
    }];
    
    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.phoneTF.mas_bottom).offset(40);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark --- 创建Bar Code
- (void)creatBarCodeView{
    
    [self setTitleStr:@"Ceate Bar Code"];
    
    self.phoneTF = [[Szero_TextField alloc] init];
    self.phoneTF.placeholder = @"Number";
    [self.view addSubview:self.phoneTF];
    [self.phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
        make.height.mas_equalTo(50);
    }];
    
//    self.tipsLab = [[UILabel alloc] init];
//    self.tipsLab.text = @"0/12";
//    self.tipsLab.textColor = [UIColor colorWithString:@"#CCCCCC"];
//    self.tipsLab.font = [UIFont systemFontOfSize:12];
//    [self.phoneTF addSubview:self.tipsLab];
//    [self.tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.phoneTF).offset(-15);
//        make.centerY.equalTo(self.phoneTF);
//    }];
    
    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.phoneTF.mas_bottom).offset(40);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark --- 创建URL
- (void)creatUrlsView{
    [self setTitleStr:@"Ceate URLS"];
    self.dataList = @[@"www.",@".com",@".xyz",@".net",@".top",@".tech",
                      @".org",@".gov",@"edu",@".ink",@".pub",@".int",];
    
    self.urlView = [[Szero_TextView alloc] init];
    [self.urlView addPlaceHolder:@"Url"];
    [self.view addSubview:self.urlView];
    [self.urlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
        make.height.mas_equalTo(100);
    }];
    
    [self.view addSubview:self.collectView];
    [self.collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.urlView.mas_bottom).offset(20);
        make.height.mas_equalTo(140);
    }];
    
    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.collectView.mas_bottom).offset(40);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
}

- (NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    Szero_CreatUrlCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Szero_CreatUrlCell" forIndexPath:indexPath];
    cell.desStr = self.dataList[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSString *desStr = self.urlView.text;
    desStr = [NSString stringWithFormat:@"%@%@",desStr,self.dataList[indexPath.item]];
    self.urlView.text = desStr;
    [self.urlView becomeFirstResponder];
}


#pragma mark --- 创建TEXT
- (void)creatTextView{
    
    [self setTitleStr:@"Ceate Text"];
    
    self.nameView = [[Szero_TextView alloc] init];
    [self.nameView addPlaceHolder:@"Text"];
    [self.view addSubview:self.nameView];
    [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
        make.height.mas_equalTo(100);
    }];

    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.nameView.mas_bottom).offset(40);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark --- 创建wifi
- (void)creatwifiView{
    [self setTitleStr:@"Ceate Wifi"];
    
    self.nameTF = [[Szero_TextField alloc] init];
    self.nameTF.placeholder = @"Wifi Name(SSID)";
    [self.view addSubview:self.nameTF];
    [self.nameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
        make.height.mas_equalTo(50);
    }];
    
    self.phoneTF = [[Szero_TextField alloc] init];
    self.phoneTF.placeholder = @"Password";
    [self.view addSubview:self.phoneTF];
    [self.phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.nameTF.mas_bottom).offset(10);
        make.height.mas_equalTo(50);
    }];
    
    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.phoneTF.mas_bottom).offset(40);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark --- 创建Phone number
- (void)creatPhoneNumberView{
    
    [self setTitleStr:@"Ceate Phone Number"];
    
    self.nameTF = [[Szero_TextField alloc] init];
    self.nameTF.placeholder = @"Phone Number";
    [self.view addSubview:self.nameTF];
    [self.nameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(TOP_HEIGHT+20);
        make.height.mas_equalTo(50);
    }];

    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.nameTF.mas_bottom).offset(40);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
}


- (UICollectionView *)collectView{
    if (!_collectView) {
        CGFloat item_w = 90;
        CGFloat item_h = 27;
        CGFloat space = (XCScreenW - 30 - item_w*3)/2;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = space;
        layout.minimumLineSpacing = 10;
        layout.itemSize = CGSizeMake(item_w, item_h);
        _collectView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectView.delegate = self;
        _collectView.dataSource = self;
        _collectView.backgroundColor = [UIColor clearColor];
        [_collectView registerClass:[Szero_CreatUrlCell class] forCellWithReuseIdentifier:@"Szero_CreatUrlCell"];
    }
    return _collectView;
}

- (UIButton *)nextBtn{
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.backgroundColor = [UIColor colorWithString:@"#52CCBB"];
        [_nextBtn setTitle:@"Generate" forState:UIControlStateNormal];
        _nextBtn.layer.cornerRadius = 10.f;
        _nextBtn.layer.masksToBounds = YES;
        [_nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}


- (void)inputInfo{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please input the content before creating." message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 完成广告
- (void)showFinishAD{
    ADConfigModel *configModel = [ADConfigSetting filterADPosition:ADPositionType_finish];
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

@end

