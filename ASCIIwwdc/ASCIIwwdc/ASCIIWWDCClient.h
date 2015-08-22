//
//  ASCIIWWDCClient.h
//  ASCIIwwdc
//
//  Created by Guilherme Rambo on 23/04/15.
//  Copyright (c) 2015 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WWDCSessionTranscript;

NS_ASSUME_NONNULL_BEGIN

@interface ASCIIWWDCClient : NSObject

+ (ASCIIWWDCClient *)sharedClient;

- (void)fetchTranscriptForYear:(int)year session:(int)session completionHandler:(void (^)(BOOL success, WWDCSessionTranscript *__nullable transcript))callback;

@end

NS_ASSUME_NONNULL_END
