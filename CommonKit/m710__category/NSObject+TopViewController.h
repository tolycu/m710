//
//  NSObject+TopViewController.h
//  startvpn
//
//  Created by 李光尧 on 2020/11/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TopViewController)

- (UIViewController *)currentController;
- (UIWindow *)viewControllerWindow;

@end

NS_ASSUME_NONNULL_END
