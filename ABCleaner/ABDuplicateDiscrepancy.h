//
//  ABDuplicateDiscrepancy.h
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABDiscrepancy.h"

@interface ABDuplicateDiscrepancy : ABDiscrepancy {
    
}

- (id)initWithAddressBook:(ABAddressBook *)book people:(NSArray *)thePeople;
+ (ABDuplicateDiscrepancy *)discrepancyForPerson:(ABPerson *)person inAddressBook:(ABAddressBook *)book;

- (void)resolveByMerging;
- (void)resolveByDeletion;

@end
