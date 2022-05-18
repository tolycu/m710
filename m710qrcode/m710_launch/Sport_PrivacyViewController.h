//
//  Sport_PrivacyViewController.h
//  sportqr
//
//  Created by Hoho Wu on 2022/3/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^CompleteNext)(void);

@interface Sport_PrivacyViewController : UIViewController


@property (nonatomic ,copy) CompleteNext nextBlock;

@end

NS_ASSUME_NONNULL_END
