//
//  AppDelegate.h
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBookUI.h>
#import "ABDiscrepancyScanner.h"
#import "ABDiscrepancyListView.h"
#import "ResolvingWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, ABDiscrepancyScannerDelegate, ABDiscrepancyListViewDelegate> {
    ABDiscrepancyListView * discrepancyList;
    ABPersonView * personView;
    
    NSProgressIndicator * loadingSpinner;
    NSTextField * loadingLabel;
    NSButton * resolveButton;
    NSButton * reloadButton;
}

@property (assign) IBOutlet NSWindow * window;

- (void)resolve:(id)sender;
- (void)reload:(id)sender;
- (void)reloadDiscrepancies;

@end
