//
//  Sport_GlobalConfigModel.h
//  sportqr
//
//  Created by Hoho Wu on 2022/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Sport_GlobalConfigModel : NSObject

@property(nonatomic,assign) long qdTime;
@property(nonatomic,strong) NSString *vpCountryFirst;
@property(nonatomic,assign) long reLoadTime;


@end

NS_ASSUME_NONNULL_END
