//
//  AppDelegate.m
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    ABDiscrepancyScanner * scanner = [[ABDiscrepancyScanner alloc] initWithDelegate:self];
    [scanner scanInBackground];
}

- (void)suggestionScannerDone:(ABDiscrepancyScanner *)scanner discrepancies:(NSArray *)theSuggestions {
    NSLog(@"Discrepancies: %@", theSuggestions);
    if ([theSuggestions count] > 0) {
        ABDiscrepancyView * dv = [[ABDiscrepancyView alloc] initWithFrame:NSMakeRect(10, 110, 300, 23) discrepancy:[theSuggestions objectAtIndex:0]];
        [self.window.contentView addSubview:dv];
    }
}

@end
