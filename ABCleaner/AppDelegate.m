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
        personView = [[ABPersonView alloc] initWithFrame:NSMakeRect(290, 45, [self.window.contentView frame].size.width - 300,
                                                                    [self.window.contentView frame].size.height - 55)];
        [personView setAutoresizingMask:(NSViewHeightSizable | NSViewMinXMargin)];
    } else {
        [personView setFrame:NSMakeRect(290, 45, [self.window.contentView frame].size.width - 300,
                                        [self.window.contentView frame].size.height - 55)];
        [personView setPerson:nil];
    }
    
    if (!resolveButton) {
        resolveButton = [[NSButton alloc] initWithFrame:NSMakeRect([self.window.contentView frame].size.width - 105, 10, 100, 32)];
        [resolveButton setTitle:@"Resolve"];
        [resolveButton setBezelStyle:NSRoundedBezelStyle];
        [resolveButton setTarget:self];
        [resolveButton setAction:@selector(resolve:)];
        [resolveButton setAutoresizingMask:(NSViewMinXMargin | NSViewMaxYMargin)];
    } else {
        [resolveButton setFrame:NSMakeRect([self.window.contentView frame].size.width - 105, 10, 100, 32)];
    }
    
    if (!reloadButton) {
        reloadButton = [[NSButton alloc] initWithFrame:NSMakeRect([self.window.contentView frame].size.width - 205, 10, 100, 32)];
        [reloadButton setTitle:@"Reload"];
        [reloadButton setBezelStyle:NSRoundedBezelStyle];
        [reloadButton setTarget:self];
        [reloadButton setAction:@selector(reload:)];
        [reloadButton setAutoresizingMask:(NSViewMinXMargin | NSViewMaxYMargin)];
    } else {
        [reloadButton setFrame:NSMakeRect([self.window.contentView frame].size.width - 210, 10, 100, 32)];
    }
    
    [discrepancyList setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
    [self.window.contentView addSubview:discrepancyList];
    [self.window.contentView addSubview:personView];
    [self.window.contentView addSubview:resolveButton];
    [self.window.contentView addSubview:reloadButton];
    
    [loadingLabel removeFromSuperview];
    [loadingSpinner removeFromSuperview];
}

- (void)reloadDiscrepancies {
    [discrepancyList removeFromSuperview];
    [resolveButton removeFromSuperview];
    [personView removeFromSuperview];
    [reloadButton removeFromSuperview];
    
    NSRect frame = [self.window.contentView frame];
    [loadingSpinner setFrame:NSMakeRect(frame.size.width / 2 - 8, frame.size.height / 2 - 8, 16, 16)];
    [loadingLabel setFrame:NSMakeRect(frame.size.width / 2 - 100, frame.size.height / 2 + 18, 200, 20)];
    [self.window.contentView addSubview:loadingSpinner];
    [self.window.contentView addSubview:loadingLabel];
    
    ABDiscrepancyScanner * scanner = [[ABDiscrepancyScanner alloc] initWithDelegate:self];
    [scanner scanInBackground];
}

#pragma mark Actions

- (void)resolve:(id)sender {
    NSOperationQueue * queue = [discrepancyList discrepancyResolutionQueue];
    ResolvingWindow * resolveWindow = [[ResolvingWindow alloc] initWithWidth:500 operations:queue];
    
    [NSApp beginSheet:resolveWindow modalForWindow:self.window modalDelegate:self didEndSelector:NULL contextInfo:NULL];
    //[NSApp runModalForWindow:resolveWindow];
    
    /*
     [NSApp endSheet:resolveWindow];
     [resolveWindow orderOut:nil];
     */
    
}

- (void)reload:(id)sender {
    [self reloadDiscrepancies];
}

- (void)discrepancyListView:(ABDiscrepancyListView *)listView previewPerson:(ABPerson *)person {
    [personView setPerson:person];
}

@end
