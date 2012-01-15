//
//  ABDuplicateDiscrepancy.m
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABDuplicateDiscrepancy.h"

@interface ABDuplicateDiscrepancy (Private)

- (void)mergeProperty:(NSString *)property original:(ABPerson *)original merging:(ABPerson *)merging;
- (ABMultiValue *)mergeMultiValue:(ABMultiValue *)original withNewMultiValue:(ABMultiValue *)additional;

@end

@implementation ABDuplicateDiscrepancy

+ (NSString *)shortSummary {
    return @"duplicate";
}

- (id)initWithAddressBook:(ABAddressBook *)book people:(NSArray *)thePeople {
    if ((self = [super initWithAddressBook:book])) {
        people = thePeople;
        ABPerson * person = ([thePeople count] > 0 ? [thePeople lastObject] : nil);
        
        // generate summary
        NSString * firstName = [person valueForProperty:kABFirstNameProperty];
        NSString * lastName = [person valueForProperty:kABLastNameProperty];
        NSString * fullname = [NSString stringWithFormat:@"%@%@%@", (firstName ? firstName : @""),
                               ((lastName != nil && firstName != nil) ? @" " : @""),
                               (lastName ? lastName : @"")];
        summary = [NSString stringWithFormat:@"%ld contacts named \"%@\"", [thePeople count], fullname];
    }
    return self;
}

+ (NSArray *)discrepanciesForAddressBook:(ABAddressBook *)book {
    NSMutableArray * mutable = [[NSMutableArray alloc] init];
    NSMutableArray * touchedPeople = [NSMutableArray array];
    
    for (ABPerson * person in [book people]) {
        if ([touchedPeople containsObject:person]) continue;
        ABDuplicateDiscrepancy * discrepancy = [self discrepancyForPerson:person inAddressBook:book];
        if (discrepancy) {
            [mutable addObject:discrepancy];
            [touchedPeople addObjectsFromArray:[discrepancy people]];
        }
    }
    
    return [NSArray arrayWithArray:mutable];
}

+ (ABDuplicateDiscrepancy *)discrepancyForPerson:(ABPerson *)person inAddressBook:(ABAddressBook *)book {
    NSString * firstName = [person valueForProperty:kABFirstNameProperty];
    NSString * lastName = [person valueForProperty:kABLastNameProperty];
    
    NSMutableArray * searchElements = [NSMutableArray array];
    [searchElements addObject:[ABPerson searchElementForProperty:kABFirstNameProperty label:nil key:nil
                                                               value:firstName comparison:kABEqual]];

    [searchElements addObject:[ABPerson searchElementForProperty:kABLastNameProperty label:nil key:nil
                                                               value:lastName comparison:kABEqual]];
    
    if ([searchElements count] == 0 || (!firstName && !lastName)) return nil;
    
    ABSearchElement * search = [ABSearchElement searchElementForConjunction:kABSearchAnd children:searchElements];
    NSArray * results = [book recordsMatchingSearchElement:search];
    
    if ([results count] > 1) {
        ABDuplicateDiscrepancy * merge = [[ABDuplicateDiscrepancy alloc] initWithAddressBook:book people:results];
        return merge;
    }
    
    return nil;
}

#pragma mark - Resolutions -

- (NSUInteger)numberOfResolutions {
    return 2;
}

- (NSString *)titleForResolutionAtIndex:(NSUInteger)resolutionIndex {
    NSString * titles[] = {@"Merge", @"Delete All"};
    return titles[resolutionIndex];
}

- (void)resolveWithResolutionAtIndex:(NSUInteger)resolutionIndex {
    if (resolutionIndex == 0) {
        [self resolveByMerging];
    } else if (resolutionIndex == 1) {
        [self resolveByDeletion];
    }
}

#pragma mark Merging

- (void)resolveByMerging {
    if ([people count] < 2) return;
    
    // we'll modify the first contact, and delete the others
    ABPerson * changing = [people objectAtIndex:0];
    NSArray * properties = [ABPerson properties];
    
    for (NSUInteger i = 1; i < [people count]; i++) {
        ABPerson * person = [people objectAtIndex:i];
        
        // merge properties
        for (NSString * property in properties) {
            [self mergeProperty:property original:changing merging:person];
        }
        
        // merge picture (if one isn't already present)
        if (![changing imageData] && [person imageData]) {
            [changing setImageData:[person imageData]];
        }
        
        // merge groups
        for (ABGroup * group in [person parentGroups]) {
            if (![[group members] containsObject:changing]) {
                [group addMember:changing];
            }
        }
        
        // remove the duplicate record
        [addressBook removeRecord:person];
    }
    
    [addressBook save];
}

- (void)mergeProperty:(NSString *)property original:(ABPerson *)original merging:(ABPerson *)merging {
    id mergingValue = [merging valueForProperty:property];
    id originalValue = [original valueForProperty:property];
    if (!originalValue && mergingValue) {
        [original setValue:mergingValue forProperty:property];
    } else if (originalValue && mergingValue) {
        if (([ABPerson typeOfProperty:property] & 0x100) == 0x100) {
            // it is a multi-value record, so we can still merge it.
            ABMultiValue * merged = [self mergeMultiValue:originalValue withNewMultiValue:mergingValue];
            [original setValue:merged forProperty:property];
        }
    }
}

- (ABMultiValue *)mergeMultiValue:(ABMultiValue *)original withNewMultiValue:(ABMultiValue *)additional {
    ABMutableMultiValue * mutable = [original mutableCopy];
    
    // Add numbers to label names if needed to avoid naming conflicts.
    // NOTE: if the label doesn't already exist, no number will be appended and the label will be used as-is
    for (NSUInteger i = 0; i < [additional count]; i++) {
        NSString * label = [additional labelAtIndex:i];
        id value = [additional valueAtIndex:i];
        
        NSString * changedLabel = label;
        NSUInteger appendedNumber = 1;
        
        BOOL exists = NO;
        do {
            if (exists) changedLabel = [NSString stringWithFormat:@"%@ %lld", label, appendedNumber];
            exists = NO;
            for (NSUInteger j = 0; j < [mutable count]; j++) {
                if ([[mutable labelAtIndex:j] isEqualToString:changedLabel]) {
                    exists = YES;
                    break;
                }
            }
        } while (exists);
        
        [mutable setValue:value forKey:changedLabel];
    }
    
    return mutable;
}

#pragma mark Deletion

- (void)resolveByDeletion {
    for (ABPerson * person in people) {
        [addressBook removeRecord:person];
    }
    [addressBook save];
}

@end
