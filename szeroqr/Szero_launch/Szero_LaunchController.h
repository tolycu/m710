//
//  Szero_LaunchController.h
//  szeroqr
//
//  Created by xc-76 on 2022/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^CompleteNext)(void);
@interface Szero_LaunchController : UIViewController

@property (nonatomic ,copy) CompleteNext nextBlock;

@end

NS_ASSUME_NONNULL_END
