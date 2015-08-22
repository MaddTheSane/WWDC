//
//  WWDCSessionTranscript.h
//  ASCIIwwdc
//
//  Created by Guilherme Rambo on 23/04/15.
//  Copyright (c) 2015 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WWDCTranscriptLine;

NS_ASSUME_NONNULL_BEGIN

@interface WWDCSessionTranscript : NSObject <NSSecureCoding>

@property (assign) int year;
@property (assign) int session;
@property (strong) NSArray<WWDCTranscriptLine*> *lines;

@property (readonly) NSString *fullText;
@property (readonly) NSString *htmlString;

@property (readonly) NSArray<NSValue*> *timecodes;

@end

NS_ASSUME_NONNULL_END
