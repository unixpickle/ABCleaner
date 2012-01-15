//
//  ABDiscrepancy.m
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABDiscrepancy.h"

@implementation ABDiscrepancy

@synthesize people, summary;
@synthesize addressBook;

+ (NSString *)shortSummary {
    return nil;
}

+ (NSArray *)discrepanciesForAddressBook:(ABAddressBook *)book {
    return nil;
}

- (id)initWithAddressBook:(ABAddressBook *)book {
    if ((self = [super init])) {
        addressBook = book;
    }
    return self;
}

- (NSUInteger)numberOfResolutions {
    return 0;
}

- (NSString *)titleForResolutionAtIndex:(NSUInteger)resolutionIndex {
    return nil;
}

- (void)resolveWithResolutionAtIndex:(NSUInteger)resolutionIndex {
    [self doesNotRecognizeSelector:@selector(resolveWithResolutionAtIndex:)];
}

- (id)description {
    return [NSString stringWithFormat:@"<%@: %p: %@>", NSStringFromClass([self class]), self, self.summary];
}

@end
