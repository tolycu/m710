//
//  BaseNavController.m
//  m208vpm
//
//  Created by hf on 2021/5/11.
//

#import "BaseNavController.h"
#import "M710_BaseViewController.h"


@interface BaseNavController ()

@end

@implementation BaseNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarHidden:YES];
    
    __weak typeof(self) weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = (id)weakSelf;
    }
}

- (NSArray *)noEnablePopGestureArray {
    return @[];
}

- (NSArray *)extraControllersArray {
    return @[];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if(gestureRecognizer == self.interactivePopGestureRecognizer) {
        // 如果当前展示的控制器是根控制器就不让其响应
        if (self.viewControllers.count < 2 ||
            self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
        
        __block BOOL enable = YES;
        [[self noEnablePopGestureArray] enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([NSStringFromClass([self.topViewController class]) isEqualToString: obj]) {
                enable = NO;
                *stop = YES;
            }
        }];
        
        return enable;
    }
    return YES;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    M710_BaseViewController *vc = self.viewControllers.lastObject;
    for (int i = 0; i < self.extraControllersArray.count; i ++) {
        NSString *vcName = self.extraControllersArray[i];
        if ([vcName isEqualToString:NSStringFromClass(vc.class)]) {
            break;
        }
    }
    return [super popViewControllerAnimated:animated];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (gestureRecognizer == self.interactivePopGestureRecognizer
        && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
           UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:self.view];
        // 判断手势的方向是侧滑的方向（向右）让多个手势共存
        if (point.x > 0) {
            return YES;
        }
    }
    return NO;
}

@end
