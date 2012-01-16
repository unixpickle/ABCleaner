//
//  ResolvingWindow.h
//  ABCleaner
//
//  Created by Alex Nichol on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface ResolvingWindow : NSWindow {
    NSOperationQueue * queue;
}

- (id)initWithWidth:(CGFloat)width operations:(NSOperationQueue *)aQueue;
- (void)operationComplete;

@end
