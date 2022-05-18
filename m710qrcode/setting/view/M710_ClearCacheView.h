//
//  M710_ClearCacheView.h
//  m710qrcode
//
//  Created by xc-76 on 2022/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^YesCompletionHandler)(void);
@interface M710_ClearCacheView : UIView

@property (nonatomic ,copy) YesCompletionHandler yesCompletionHandler;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title des:(NSString *)des btns:(BOOL)btns;
- (void)show;

@end

NS_ASSUME_NONNULL_END
