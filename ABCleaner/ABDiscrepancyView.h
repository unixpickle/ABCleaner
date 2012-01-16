//
//  ABDiscrepancyView.h
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABDiscrepancy.h"

#define kTitleHeight 21
#define kExpandedHeight 126

@class ABDiscrepancyView;

@protocol ABDiscrepancyViewDelegate <NSObject>

@optional
- (void)discrepancyViewResizedInternally:(ABDiscrepancyView *)discrepancyView;
- (void)discrepancyView:(ABDiscrepancyView *)discrepancyView previewPerson:(ABPerson *)person;

@end

@interface ABDiscrepancyView : NSView <NSTableViewDataSource, NSTableViewDelegate> {
    ABDiscrepancy * discrepancy;
    
    NSTextField * solutionLabel;
    NSPopUpButton * solutionOptions;
    
    NSButton * disclosureIndicator;
    NSTableView * peopleTable;
    NSScrollView * tableScrollView;
    
    BOOL isFocused;
    BOOL isHighlighted;
    __weak id<ABDiscrepancyViewDelegate> delegate;
}

@property (readonly) ABDiscrepancy * discrepancy;
@property (readwrite) BOOL isFocused;
@property (nonatomic, weak) id<ABDiscrepancyViewDelegate> delegate;

- (id)initWithFrame:(NSRect)frameRect discrepancy:(ABDiscrepancy *)aDiscrepancy;

- (void)disclosurePressed:(id)sender;

@end
