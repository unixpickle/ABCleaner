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
        [self setBorderType:NSBezelBorder];
        clipView = [[NSClipView alloc] initWithFrame:frameRect];
        [self setDocumentView:clipView];
        
        NSMutableArray * mDiscrepancyViews = [[NSMutableArray alloc] initWithCapacity:[discrepancies count]];
        for (NSUInteger i = 0; i < [discrepancies count]; i++) {
            ABDiscrepancy * discrepancy = [discrepancies objectAtIndex:i];
            ABDiscrepancyView * discrepancyView = [[ABDiscrepancyView alloc] initWithFrame:NSMakeRect(0, 0, frameRect.size.width - 20, 23) discrepancy:discrepancy];
            [mDiscrepancyViews addObject:discrepancyView];
        }
        
        discrepancyViews = [[NSArray alloc] initWithArray:mDiscrepancyViews];
        contentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, frameRect.size.width, 10)];
        [self layoutContentView];
    }
    return self;
}

- (void)layoutContentView {
    while ([[contentView subviews] count] > 0) {
        [[[contentView subviews] lastObject] removeFromSuperview];
    }
    
    CGFloat y = 10;
    for (ABDiscrepancyView * discrepancyView in discrepancyViews) {
        NSRect frame = discrepancyView.frame;
        frame.origin.y = y;
        y += frame.size.height + 10;
        discrepancyView.frame = frame;
    }
    [contentView setFrame:NSMakeRect(0, 0, self.frame.size.width, y)];
    
    for (ABDiscrepancyView * discrepancyView in discrepancyViews) {
        [contentView addSubview:discrepancyView];
    }
}

#pragma mark ABDiscrepancyViewDelegate

- (void)discrepancyView:(ABDiscrepancyView *)discrepancyView previewPerson:(ABPerson *)person {
    [delegate discrepancyListView:self previewPerson:person];
}

- (void)discrepancyViewResizedInternally:(ABDiscrepancyView *)discrepancyView {
    [self layoutContentView];
    [self scrollRectToVisible:discrepancyView.frame];
}

@end
