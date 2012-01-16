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

@class ABDiscrepancyView;

@protocol ABDiscrepancyViewDelegate <NSObject>

@optional
- (void)discrepancyViewResizedInternally:(ABDiscrepancyView *)discrepancyView;
- (void)discrepancyView:(ABDiscrepancyView *)discrepancyView previewPerson:(ABPerson *)person;

@end

@interface ABDiscrepancyView : NSView {
    ABDiscrepancy * discrepancy;
    
    NSTextField * descriptionTextField;
    NSButton * disclosureIndicator;
    NSTableView * peopleTable;
    
    BOOL isFocused;
}

@property (readonly) ABDiscrepancy * discrepancy;
@property (readwrite) BOOL isFocused;

- (id)initWithFrame:(NSRect)frameRect discrepancy:(ABDiscrepancy *)aDiscrepancy;

- (void)disclosurePressed:(id)sender;

@end
