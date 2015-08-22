//
//  WWDCTranscriptLine.h
//  ASCIIwwdc
//
//  Created by Guilherme Rambo on 23/04/15.
//  Copyright (c) 2015 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WWDCTranscriptLine : NSObject <NSSecureCoding>

@property (copy) NSString *text;
@property (nonatomic, assign) double timecode;

+ (NSString *)roundedStringFromTimecode:(double)timecode;
@property (readonly) NSString *timecodeAsRoundedString;

@end

NS_ASSUME_NONNULL_END
