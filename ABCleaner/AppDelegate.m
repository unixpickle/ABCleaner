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

- (void)suggestionScannerDone:(ABDiscrepancyScanner *)scanner suggestions:(NSArray *)theSuggestions {
    NSLog(@"Suggestions: %@", theSuggestions);
}

@end
