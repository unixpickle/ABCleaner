//
//  ABDiscrepancyListView.m
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABDiscrepancyListView.h"

@implementation ABDiscrepancyListView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frameRect discrepancies:(NSArray *)discrepancies {
    if ((self = [super initWithFrame:frameRect])) {
        [self setHasVerticalScroller:YES];
        [self setBorderType:NSNoBorder];
        clipView = [[NSClipView alloc] initWithFrame:frameRect];
        [self setDocumentView:clipView];
        
        NSMutableArray * mDiscrepancyViews = [[NSMutableArray alloc] initWithCapacity:[discrepancies count]];
        for (NSUInteger i = 0; i < [discrepancies count]; i++) {
            ABDiscrepancy * discrepancy = [discrepancies objectAtIndex:i];
            ABDiscrepancyView * discrepancyView = [[ABDiscrepancyView alloc] initWithFrame:NSMakeRect(0, 0, frameRect.size.width - 20, 23) discrepancy:discrepancy];
            [mDiscrepancyViews addObject:discrepancyView];
            [discrepancyView setDelegate:self];
        }
        
        discrepancyViews = [[NSArray alloc] initWithArray:mDiscrepancyViews];
        contentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, frameRect.size.width, 10)];
        [clipView setDocumentView:contentView];
        [self layoutContentView];
        [clipView setCopiesOnScroll:NO];
    }
    return self;
}

- (void)setFrame:(NSRect)aRect {
    [super setFrame:aRect];
    [clipView setFrame:NSMakeRect(0, 0, aRect.size.width, aRect.size.height)];
    [self layoutContentView];
    [self reflectScrolledClipView:self.documentView];
}

- (void)layoutContentView {
    CGFloat height = 10;
    for (ABDiscrepancyView * discrepancyView in discrepancyViews) {
        NSRect frame = discrepancyView.frame;
        height += frame.size.height + 10;
    }
    
    if (height < self.frame.size.height) height = self.frame.size.height;
    [clipView setFrame:NSMakeRect(0, 0, self.frame.size.width, height)];
    [contentView setFrame:NSMakeRect(0, 0, self.frame.size.width, height)];
    
    CGFloat y = height;
    for (ABDiscrepancyView * discrepancyView in discrepancyViews) {
        NSRect frame = discrepancyView.frame;
        y -= frame.size.height + 10;
        
        frame.origin.y = y;
        frame.size.width = self.frame.size.width - 20;
        frame.origin.x = 10;
        discrepancyView.frame = frame;
        
        if (![discrepancyView superview]) {
            [contentView addSubview:discrepancyView];
        }
    }
}

- (NSOperationQueue *)discrepancyResolutionQueue {
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    [queue setSuspended:YES];
    for (ABDiscrepancyView * view in discrepancyViews) {
        NSOperation * operation = [view discrepancyResolutionOperation];
        if (operation) {
            [queue addOperation:operation];
        }
    }
    return queue;
}

#pragma mark ABDiscrepancyViewDelegate

- (void)discrepancyView:(ABDiscrepancyView *)discrepancyView previewPerson:(ABPerson *)person {
    [delegate discrepancyListView:self previewPerson:person];
}

- (void)discrepancyViewResizedInternally:(ABDiscrepancyView *)discrepancyView {
    [self layoutContentView];
    [self reflectScrolledClipView:self.documentView];
    
    NSRect biggerFrame = discrepancyView.frame;
    biggerFrame.size.height += 20;
    biggerFrame.origin.x -= 10;
    [self.contentView scrollRectToVisible:biggerFrame];
}

@end
