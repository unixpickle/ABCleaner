//
//  ResolvingWindow.m
//  ABCleaner
//
//  Created by Alex Nichol on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResolvingWindow.h"

@implementation ResolvingWindow

- (id)initWithWidth:(CGFloat)width operations:(NSOperationQueue *)aQueue {
    self = [super initWithContentRect:NSMakeRect(0, 0, width, 70) styleMask:NSTitledWindowMask
                              backing:NSBackingStoreBuffered defer:NO];
    if (self) {
        NSProgressIndicator * progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(10, 10, width - 20, 22)];
        [progress setStyle:NSProgressIndicatorBarStyle];
        [progress setIndeterminate:YES];
        [progress startAnimation:self];
        
        NSTextField * activityText = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 35, width - 20, 20)];
        [activityText setStringValue:@"Applying changes to the Address Book..."];
        [activityText setBordered:NO];
        [activityText setBackgroundColor:[NSColor clearColor]];
        [activityText setSelectable:NO];
        [activityText setEditable:NO];
        
        [self.contentView addSubview:progress];
        [self.contentView addSubview:activityText];
        
        queue = aQueue;
        [queue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
        [self performSelector:@selector(startQueue) withObject:nil afterDelay:0.75];
    }
    return self;
}

- (void)startQueue {
    [queue setSuspended:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == queue) {
        if ([queue operationCount] == 0) {
            [self performSelectorOnMainThread:@selector(operationComplete) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)operationComplete {
    [NSApp endSheet:self];
    [self orderOut:nil];
    id appDelegate = [[NSApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(reloadDiscrepancies) withObject:nil afterDelay:0.1];

}

@end
