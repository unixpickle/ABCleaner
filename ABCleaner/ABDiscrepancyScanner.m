//
//  ABSuggestionScanner.m
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABDiscrepancyScanner.h"

@interface ABDiscrepancyScanner (Private)

- (void)scanAndCall:(void (^)(NSArray * suggestions))callback;
- (void)giveDelegateArray:(NSArray *)theArray;

@end

@implementation ABDiscrepancyScanner

@synthesize delegate;

- (id)initWithDelegate:(id<ABDiscrepancyScannerDelegate>)theDelegate {
    if ((self = [super init])) {
        delegate = theDelegate;
    }
    return self;
}

- (void)scanInBackground {
    if (scanningThread) {
        [self cancelScan];
    }
    __weak __block NSThread * callbackThread = [NSThread currentThread];
    void (^callbackBlock)(NSArray * suggestions) = ^ (NSArray * suggestions) {
        [self performSelector:@selector(giveDelegateArray:) onThread:callbackThread
                   withObject:suggestions waitUntilDone:NO];
    };
    scanningThread = [[NSThread alloc] initWithTarget:self selector:@selector(scanAndCall:) object:callbackBlock];
    [scanningThread start];
}

- (void)cancelScan {
    if (scanningThread) {
        [scanningThread cancel];
        scanningThread = nil;
    }
}

#pragma mark - BG Thread -

- (void)scanAndCall:(void (^)(NSArray * suggestions))callback {
    @autoreleasepool {
        NSMutableArray * discrepanciesMutable = [[NSMutableArray alloc] init];
        ABAddressBook * book = [ABAddressBook sharedAddressBook];
        
        [discrepanciesMutable addObjectsFromArray:[ABDuplicateDiscrepancy discrepanciesForAddressBook:book]];
        
        NSArray * discrepancies = [NSArray arrayWithArray:discrepanciesMutable];
        if ([[NSThread currentThread] isCancelled]) return;
        
        callback(discrepancies);
    }
}

- (void)giveDelegateArray:(NSArray *)theArray {
    scanningThread = nil;
    [delegate suggestionScannerDone:self suggestions:theArray];
}

@end
