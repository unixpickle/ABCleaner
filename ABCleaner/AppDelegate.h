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

@interface AppDelegate : NSObject <NSApplicationDelegate, ABDiscrepancyScannerDelegate, ABDiscrepancyListViewDelegate> {
    ABDiscrepancyListView * discrepancyList;
    ABPersonView * personView;
    
    NSProgressIndicator * loadingSpinner;
}

@property (assign) IBOutlet NSWindow * window;

@end
