//
//  Szero_BaseViewController.h
//  camera
//
//  Created by 李光尧 on 2021/12/21.
//

#import <UIKit/UIKit.h>
#import "Szero_BaseNavController.h"

NS_ASSUME_NONNULL_BEGIN

@interface Szero_BaseViewController : UIViewController

- (void)hideBackItem;
- (void)setTitleStr:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
