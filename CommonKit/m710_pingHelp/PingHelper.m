//
//  PingHelper.m
//  RealReachability
//
//  Created by Dustturtle on 16/1/19.
//  Copyright © 2016 Dustturtle. All rights reserved.
//

#import "PingHelper.h"
#import "PingFoundtion.h"

#if (!defined(DEBUG))
#define NSLog(...)
#endif

@interface PingHelper() <PingFoundtionDelegate>

@property (nonatomic, strong) NSMutableArray *completionBlocks;
@property(nonatomic, strong) PingFoundtion *PingFoundtion;
@property (nonatomic, assign) BOOL isPinging;
@property (nonatomic, assign) CFAbsoluteTime pingStartTime;

@end

@implementation PingHelper

#pragma mark - Life Circle

- (id)init
{
    if ((self = [super init]))
    {
        _isPinging = NO;
        _timeout = 2.0f;
        _completionBlocks = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    [self.completionBlocks removeAllObjects];
    self.completionBlocks = nil;
    
    [self clearPingFoundtion];
}

#pragma mark - actions

- (void)pingWithBlock:(void (^)(BOOL isSuccess, NSTimeInterval latency))completion
{
    //NSLog(@"pingWithBlock");
    if (completion)
    {
        // copy the block, then added to the blocks array.
        @synchronized(self)
        {
            [self.completionBlocks addObject:[completion copy]];
        }
    }
    
    if (!self.isPinging)
    {
        // MUST make sure PingFoundtion in mainThread
        __weak __typeof(self)weakSelf = self;
        if (![[NSThread currentThread] isMainThread]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf startPing];
            });
        }
        else
        {
            [self startPing];
        }
    }
}

- (void)clearPingFoundtion
{
    //NSLog(@"clearPingFoundtion");
    
    if (self.PingFoundtion)
    {
        [self.PingFoundtion stop];
        self.PingFoundtion.delegate = nil;
        self.PingFoundtion = nil;
    }
}

- (void)startPing
{
    //NSLog(@"startPing");
    [self clearPingFoundtion];
    
    self.isPinging = YES;
    
    self.pingStartTime = CFAbsoluteTimeGetCurrent();

    
    self.PingFoundtion = [[PingFoundtion alloc] initWithHostName:self.host];
    self.PingFoundtion.delegate = self;
    [self.PingFoundtion start];
    
    [self performSelector:@selector(pingTimeOut) withObject:nil afterDelay:self.timeout];
}

- (void)setHost:(NSString *)host
{
    _host = nil;
    _host = [host copy];
    
    self.PingFoundtion.delegate = nil;
    self.PingFoundtion = nil;
    
    self.PingFoundtion = [[PingFoundtion alloc] initWithHostName:_host];
    
    self.PingFoundtion.delegate = self;
}

#pragma mark - inner methods

- (void)doubleCheck
{
    [self clearPingFoundtion];
    
    self.isPinging = YES;
    
    self.PingFoundtion = [[PingFoundtion alloc] initWithHostName:self.hostForCheck];
    self.PingFoundtion.delegate = self;
    [self.PingFoundtion start];
    
}

- (void)endWithFlag:(BOOL)isSuccess
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeOut) object:nil];
    
    if (!self.isPinging)
    {
        return;
    }
    
    self.isPinging = NO;
    
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSTimeInterval latency = isSuccess ? (end - self.pingStartTime) * 1000 : 0;

    [self clearPingFoundtion];
    
    @synchronized(self)
    {
        for (void (^completion)(BOOL, NSTimeInterval) in self.completionBlocks)
        {
            completion(isSuccess, latency);
        }
        [self.completionBlocks removeAllObjects];
    }
}

#pragma mark - PingFoundtion delegate

// When the pinger starts, send the ping immediately
- (void)PingFoundtion:(PingFoundtion *)pinger didStartWithAddress:(NSData *)address
{
    //NSLog(@"didStartWithAddress");
    [self.PingFoundtion sendPingWithData:nil];
}

- (void)PingFoundtion:(PingFoundtion *)pinger didFailWithError:(NSError *)error
{
    //NSLog(@"didFailWithError, error=%@", error);
    [self endWithFlag:NO];
}

- (void)PingFoundtion:(PingFoundtion *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    //NSLog(@"didFailToSendPacket, sequenceNumber = %@, error=%@", @(sequenceNumber), error);
    [self endWithFlag:NO];
}

- (void)PingFoundtion:(PingFoundtion *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    //NSLog(@"didReceivePingResponsePacket, sequenceNumber = %@", @(sequenceNumber));
    [self endWithFlag:YES];
}

#pragma mark - TimeOut handler

- (void)pingTimeOut
{
    if (!self.isPinging)
    {
        return;
    }
    
    self.isPinging = NO;
    [self clearPingFoundtion];
    
    @synchronized(self)
    {
        for (void (^completion)(BOOL, NSTimeInterval) in self.completionBlocks)
        {
            completion(NO, self.timeout);
        }
        [self.completionBlocks removeAllObjects];
    }
}

@end
 
