//
//  XCClient.m
//  startvpn
//
//  Created by 李光尧 on 2020/11/18.
//

#import "XCClient.h"
#import "NSObject+JKAppInfo.h"
#import "NSDictionary+JKSafeAccess.h"
#import "NSDictionary+JKJSONString.h"
#import "Szero_AESencrytDecrypt.h"


@interface XCClient ()

@property(nonatomic,strong) NSMutableDictionary *headerField;
@property(nonatomic,strong) AFHTTPSessionManager *manager;

@end


@implementation XCClient

-(NSMutableDictionary *)headerField{
    if (!_headerField) {
        _headerField = [NSMutableDictionary dictionary];
    }
    return _headerField;;
}


+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^
                  {
                      sharedInstance = [[self alloc] init];
                  });
    
    return sharedInstance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.manager = [[AFHTTPSessionManager alloc] init];
        self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.manager.requestSerializer.timeoutInterval = 5.f;
        self.manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD",@"POST", nil];
        [self.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Encoding"];
        
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    }
    return self;
}

/**
 判断网络状态
 */
- (void)judgeNetWorkingWithStatusHandler:(void(^)(BOOL status))statusHandler{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == 0) {
            statusHandler(NO);
        }
        statusHandler(YES);
    }];
}


- (void)get:(NSString *)api
                       params:(id _Nullable)params
                      success:(void(^)(id response))success
                      failure:(void(^)(NSError*error))failure{
    [self.manager GET:api parameters:params headers:self.headerField progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)post:(NSString *)api
      params:(id _Nullable)params
     success:(void(^)(id response))success
     failure:(void(^)(NSError*error))failure{
    
    // 加密操作
    NSString *dataString = [Szero_AESencrytDecrypt aesPostWithDict:params];
    NSData *encrytData = [Szero_AESencrytDecrypt encryptAES:dataString key:XC_EncryptKey vector:XC_EncryptInitVector keySize:kCCKeySizeAES128];
    NSData *zipData = [encrytData jk_gzippedData];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:api] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:zipData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFHTTPSessionManager *requestManager = [AFHTTPSessionManager manager];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [requestManager.requestSerializer setValue:@"test" forHTTPHeaderField:@"domain"];
    
    NSURLSessionDataTask * task = [requestManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //解密
        NSData *unZipData = [responseObject jk_gunzippedData];
        NSData *responseData = [Szero_AESencrytDecrypt decryptAES:unZipData key:XC_DecryptKey vector:XC_DecryptInitVector keySize:kCCKeySizeAES128];
        NSDictionary *responseDic = [responseData mj_JSONObject];
        NSInteger code = [responseDic jk_integerForKey:@"code"];
        NSLog(@"请求接口--%@",api);
        if ([api jk_containsaString:BASE_VPNStatus_UpLoad]) {
            NSLog(@"");
        }
        if (code == 200) {
            success(responseDic);
        }else {
            failure(error);
        }
    }];
    [task resume];
}

/**
 苹果本地校验
 */
+ (void)requestBaseWithUrl:(NSString *)url
                    method:(NSString *)method
                      body:(NSData *)postData
           timeoutInterval:(NSTimeInterval)timeoutInterval
           callBackHandler:(CallBackHandler)callBackHandler {
    NSURL *requestUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:timeoutInterval];
    [request setHTTPMethod:method];
    [request setHTTPBody:postData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFHTTPSessionManager *requestManager = [AFHTTPSessionManager manager];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionDataTask *task = [requestManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        !callBackHandler ? : callBackHandler(responseObject, error);
    }];
    [task resume];
}

@end
