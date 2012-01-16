//
//  ABDiscrepancyListView.h
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "ABDiscrepancyView.h"

@class ABDiscrepancyListView;

@protocol ABDiscrepancyListViewDelegate <NSObject>

- (void)discrepancyListView:(ABDiscrepancyListView *)listView previewPerson:(ABPerson *)person;

@end

@interface ABDiscrepancyListView : NSScrollView <ABDiscrepancyViewDelegate> {
    NSArray * discrepancyViews;
    __weak id<ABDiscrepancyListViewDelegate> delegate;
    NSClipView * clipView;
    NSView * contentView;
    NSTextField * noDiscrepanciesLabel;
}

@property (nonatomic, weak) id<ABDiscrepancyListViewDelegate> delegate;

- (id)initWithFrame:(NSRect)frameRect discrepancies:(NSArray *)discrepancies;
- (void)layoutContentView;

- (NSOperationQueue *)discrepancyResolutionQueue;

@end
