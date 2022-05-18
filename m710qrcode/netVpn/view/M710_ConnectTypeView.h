//
//  M710_ConnectTypeView.h
//  m710qrcode
//
//  Created by xc-76 on 2022/4/25.
//

#import <UIKit/UIKit.h>
#import "SOneVPMacros.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^SelectCompletionHandler)(VPConnectMode mode);
@interface M710_ConnectTypeView : UIView

@property (nonatomic ,copy) SelectCompletionHandler selectCompletionHandler;

@end

NS_ASSUME_NONNULL_END
