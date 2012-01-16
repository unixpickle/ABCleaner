//
//  ABDiscrepancy.h
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface ABDiscrepancy : NSObject {
    NSArray * people;
    NSString * summary;
    ABAddressBook * addressBook;
}

@property (readonly) NSArray * people;
@property (readonly) NSString * summary;
@property (readonly) ABAddressBook * addressBook;

+ (NSString *)shortSummary;
+ (NSArray *)discrepanciesForAddressBook:(ABAddressBook *)book;

- (id)initWithAddressBook:(ABAddressBook *)book;

- (NSUInteger)numberOfResolutions;
- (NSString *)titleForResolutionAtIndex:(NSUInteger)resolutionIndex;
- (void)resolveWithResolutionAtIndex:(NSUInteger)resolutionIndex;

@end
