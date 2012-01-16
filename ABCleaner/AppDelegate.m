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
    NSRect frame = [self.window.contentView frame];
    loadingSpinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(frame.size.width / 2 - 8, frame.size.height / 2 - 8, 16, 16)];
    loadingLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(frame.size.width / 2 - 100, frame.size.height / 2 + 18, 200, 20)];
    
    [loadingLabel setAlignment:NSCenterTextAlignment];
    [loadingLabel setBackgroundColor:[NSColor clearColor]];
    [loadingLabel setSelectable:NO];
    [loadingLabel setEditable:NO];
    [loadingLabel setStringValue:@"Scanning Address Book ..."];
    [loadingLabel setBordered:NO];
    
    [loadingSpinner setControlSize:NSSmallControlSize];
    [loadingSpinner setStyle:NSProgressIndicatorSpinningStyle];
    [loadingSpinner startAnimation:self];
    
    ABDiscrepancyScanner * scanner = [[ABDiscrepancyScanner alloc] initWithDelegate:self];
    [scanner scanInBackground];
    
    [self.window.contentView addSubview:loadingLabel];
    [self.window.contentView addSubview:loadingSpinner];
}

- (void)suggestionScannerDone:(ABDiscrepancyScanner *)scanner discrepancies:(NSArray *)discrepancies {
    discrepancyList = [[ABDiscrepancyListView alloc] initWithFrame:NSMakeRect(0, 0, 280, [self.window.contentView frame].size.height) discrepancies:discrepancies];
    [discrepancyList setDelegate:self];
    if (!personView) {
        personView = [[ABPersonView alloc] initWithFrame:NSMakeRect(290, 40, [self.window.contentView frame].size.width - 300, [self.window.contentView frame].size.height - 50)];
        [personView setAutoresizingMask:(NSViewHeightSizable | NSViewMinXMargin)];
    }
    
    [discrepancyList setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    [self.window.contentView addSubview:discrepancyList];
    [self.window.contentView addSubview:personView];
    
    [loadingLabel removeFromSuperview];
    [loadingSpinner removeFromSuperview];
}

- (void)discrepancyListView:(ABDiscrepancyListView *)listView previewPerson:(ABPerson *)person {
    [personView setPerson:person];
}

@end
