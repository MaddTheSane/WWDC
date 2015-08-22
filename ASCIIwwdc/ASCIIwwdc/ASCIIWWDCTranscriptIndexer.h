//
//  ASCIIWWDCTranscriptIndexer.h
//  ASCIIWWDC Indexer
//
//  Created by Guilherme Rambo on 01/06/15.
//  Copyright (c) 2015 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCIIWWDCTranscriptIndexer : NSObject

+ (ASCIIWWDCTranscriptIndexer  *)sharedIndexer;

- (void)indexSessions:(NSArray *)sessions;

- (BOOL)fullTextSearchFor:(NSString *)query matches:(NSString *)sessionUniqueKey;

@property (nonatomic, copy) void (^__nullable indexCompletionHandler)();

@end

NS_ASSUME_NONNULL_END
