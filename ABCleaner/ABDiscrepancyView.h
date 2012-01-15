//
//  ABDiscrepancyView.h
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABDiscrepancy.h"

@class ABDiscrepancyView;

@protocol ABDiscrepancyViewDelegate <NSObject>

@optional
- (void)discrepancyViewResizedInternally:(ABDiscrepancyView *)discrepancyView;
- (void)discrepancyView:(ABDiscrepancyView *)discrepancyView previewPerson:(ABPerson *)person;

@end

@interface ABDiscrepancyView : NSView {
    ABDiscrepancy * discrepancy;
}

@property (readonly) ABDiscrepancy * discrepancy;

- (id)initWithFrame:(NSRect)frameRect discrepancy:(ANDiscrepancy *)aDiscrepancy;

@end
