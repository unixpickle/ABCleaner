//
//  AppDelegate.h
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABDiscrepancyScanner.h"
#import "ABDiscrepancyView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, ABDiscrepancyScannerDelegate>

@property (assign) IBOutlet NSWindow * window;

@end
