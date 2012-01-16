//
//  ABSuggestionScanner.h
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABDuplicateDiscrepancy.h"

@class ABDiscrepancyScanner;

@protocol ABDiscrepancyScannerDelegate <NSObject>

- (void)suggestionScannerDone:(ABDiscrepancyScanner *)scanner discrepancies:(NSArray *)discrepancies;

@end

@interface ABDiscrepancyScanner : NSObject {
    __weak id<ABDiscrepancyScannerDelegate> delegate;
    NSThread * scanningThread;
}

@property (readonly) id<ABDiscrepancyScannerDelegate> delegate;

- (id)initWithDelegate:(id<ABDiscrepancyScannerDelegate>)theDelegate;

- (void)scanInBackground;
- (void)cancelScan;

@end
