//
//  ABDiscrepancyView.m
//  ABCleaner
//
//  Created by Alex Nichol on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABDiscrepancyView.h"

@interface ABDiscrepancyView (Drawing)

- (void)drawClosed:(CGContextRef)context;
- (void)drawOpen:(CGContextRef)context;

- (void)drawTitleAtPoint:(CGPoint)aPoint;

@end

@implementation ABDiscrepancyView

@synthesize discrepancy;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frameRect discrepancy:(ABDiscrepancy *)aDiscrepancy {
    frameRect.size.height = kTitleHeight + 2;
    if ((self = [super initWithFrame:frameRect])) {
        discrepancy = aDiscrepancy;
        isFocused = YES;
        
        disclosureIndicator = [[NSButton alloc] initWithFrame:NSMakeRect(5, kTitleHeight / 2 - 5, 13, 13)];
        [disclosureIndicator setBezelStyle:NSDisclosureBezelStyle];
        [disclosureIndicator setButtonType:NSOnOffButton];
        [disclosureIndicator setTitle:@""];
        [disclosureIndicator setTarget:self];
        [disclosureIndicator setAction:@selector(disclosurePressed:)];
        
        solutionLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 15)];
        [solutionLabel setBackgroundColor:[NSColor clearColor]];
        [solutionLabel setSelectable:NO];
        [solutionLabel setEditable:NO];
        [solutionLabel setBordered:NO];
        [solutionLabel setAlignment:NSRightTextAlignment];
        [solutionLabel setStringValue:@"Action: "];
        
        solutionOptions = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 100, 26) pullsDown:NO];
        for (NSUInteger i = 0; i < [aDiscrepancy numberOfResolutions]; i++) {
            [solutionOptions addItemWithTitle:[aDiscrepancy titleForResolutionAtIndex:i]];
        }
        [[solutionOptions menu] addItem:[NSMenuItem separatorItem]];
        [solutionOptions addItemWithTitle:@"No action"];
        [solutionOptions setTarget:self];
        [solutionOptions setAction:@selector(solutionChanged:)];
        [solutionOptions selectItemAtIndex:0];
        [self setOperationNumber:0];
        
        peopleTable = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width - 20, 20)];
        NSTableColumn * firstColumn = [[NSTableColumn alloc] initWithIdentifier:@"First"];
        NSTableColumn * lastColumn = [[NSTableColumn alloc] initWithIdentifier:@"Last"];
        [firstColumn setWidth:100];
        [lastColumn setWidth:100];
        [[firstColumn headerCell] setTitle:@"First Name"];
        [[lastColumn headerCell] setTitle:@"Last Name"];
        [peopleTable addTableColumn:firstColumn];
        [peopleTable addTableColumn:lastColumn];
        [peopleTable setDataSource:self];
        [peopleTable setDelegate:self];
        
        tableScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width - 20, 20)];
        [tableScrollView setBorderType:NSBezelBorder];
        [tableScrollView setDocumentView:peopleTable];
        [tableScrollView setHasVerticalScroller:YES];
         
        [self addSubview:disclosureIndicator];
    }
    return self;
}

- (NSInteger)operationNumber {
    @synchronized (self) {
        return operationNumber;
    }
}

- (void)setOperationNumber:(NSInteger)aNumber {
    @synchronized (self) {
        operationNumber = aNumber;
    }
}

- (NSOperation *)discrepancyResolutionOperation {
    if ([self operationNumber] < 0) return nil;
    NSUInteger resolutionIndex = (NSUInteger)[self operationNumber];
    NSMethodSignature * signature = [discrepancy methodSignatureForSelector:@selector(resolveWithResolutionAtIndex:)];
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:discrepancy];
    [invocation setSelector:@selector(resolveWithResolutionAtIndex:)];
    [invocation setArgument:&resolutionIndex atIndex:2];
    return [[NSInvocationOperation alloc] initWithInvocation:invocation];
}

#pragma mark - UI -

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    [disclosureIndicator setFrame:NSMakeRect(5, frameRect.size.height - (kTitleHeight / 2) - 8, 13, 13)];
    if ([tableScrollView superview]) {
        [tableScrollView setFrame:NSMakeRect(10, 10, self.frame.size.width - 20, self.frame.size.height - (kTitleHeight + 49))];
    }
}

#pragma mark Focus

- (BOOL)isFocused {
    return isFocused;
}

- (void)setIsFocused:(BOOL)aFlag {
    isFocused = aFlag;
    [self setNeedsDisplay:YES];
}

- (BOOL)canBecomeKeyView {
    return YES;
}

- (BOOL)becomeFirstResponder {
    isHighlighted = YES;
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)resignFirstResponder {
    isHighlighted = NO;
    [self setNeedsDisplay:YES];
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
    [[self window] makeFirstResponder:self];
}

#pragma mark Actions

- (void)disclosurePressed:(id)sender {
    NSRect frame = self.frame;
    if ([disclosureIndicator state] == 0) {
        frame.size.height = kTitleHeight + 2;
        self.frame = frame;
        // remove the additional UI components
        [solutionOptions removeFromSuperview];
        [solutionLabel removeFromSuperview];
        [tableScrollView removeFromSuperview];
    } else {
        frame.size.height = kExpandedHeight;
        self.frame = frame;
        // add the additional UI components
        [solutionLabel setFrame:NSMakeRect(10, self.frame.size.height - (kTitleHeight + 27), 45, 15)];
        [solutionOptions setFrame:NSMakeRect(55, self.frame.size.height - (kTitleHeight + 34), 150, 26)];
        [tableScrollView setFrame:NSMakeRect(10, 10, self.frame.size.width - 20, self.frame.size.height - (kTitleHeight + 49))];
        [self addSubview:solutionLabel];
        [self addSubview:solutionOptions];
        [self addSubview:tableScrollView];
    }
    if ([delegate respondsToSelector:@selector(discrepancyViewResizedInternally:)]) {
        [delegate discrepancyViewResizedInternally:self];
    }
    [self setNeedsDisplay:YES];
}

- (void)solutionChanged:(id)sender {
    if ([solutionOptions indexOfSelectedItem] >= [discrepancy numberOfResolutions]) {
        [self setOperationNumber:-1];
    } else {
        [self setOperationNumber:[solutionOptions indexOfSelectedItem]];
    }
}

#pragma mark - Drawing -

- (void)drawRect:(NSRect)dirtyRect {
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    if ([disclosureIndicator state] == 0) [self drawClosed:context];
    else [self drawOpen:context];
}

- (void)drawClosed:(CGContextRef)context {
    CGFloat topGradient = (isFocused ? 227.0 / 255.0 : 241.0 / 255.0);
    CGFloat bottomGradient = (isFocused ? 199.0 / 255.0 : 214.0 / 255.0);
    CGFloat borderColor = 153.0 / 255.0;
    
    CGRect frame = NSRectToCGRect(self.bounds);
    
    // create the gradient to be drawn as the background
    CGFloat colors[8] = {topGradient, 1, bottomGradient, 1};
    CGFloat locations[2] = {0, 1};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);
    CGColorSpaceRelease(colorSpace);
    
    // create the path for the rounded corners
    CGFloat minX = CGRectGetMinX(frame) + 1, minY = CGRectGetMinY(frame) + 1;
    CGFloat maxX = CGRectGetMaxX(frame) - 1, maxY = CGRectGetMaxY(frame) - 1;
    
    CGFloat cornerRadius = 7;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minX + cornerRadius, minY);
    CGPathAddArcToPoint(path, NULL, minX, minY, minX, maxY - cornerRadius, cornerRadius);
    CGPathAddArcToPoint(path, NULL, minX, maxY, maxX - cornerRadius, maxY, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxX, maxY, maxX, minY + cornerRadius, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxX, minY, minX + cornerRadius, minY, cornerRadius);
    CGPathCloseSubpath(path);
    
    // stroke the border of the view
    if (!isHighlighted) {
        CGContextSetGrayStrokeColor(context, borderColor, 1);
    } else {
        CGContextSetRGBStrokeColor(context, 72.0 / 255.0, 139.0 / 255.0, 208.0 / 255.0, 1);
    }
    CGContextSetLineWidth(context, 2);
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    // fill the gradient background
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, frame.size.height - 1), CGPointMake(0, 1), 0);
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    
    CGPathRelease(path);
    
    [self drawTitleAtPoint:CGPointMake(22, self.frame.size.height - (kTitleHeight / 2) - 8)];
}

- (void)drawOpen:(CGContextRef)context {
    CGFloat topGradient = (isFocused ? 227.0 / 255.0 : 241.0 / 255.0);
    CGFloat bottomGradient = (isFocused ? 199.0 / 255.0 : 214.0 / 255.0);
    CGFloat borderColor = 153.0 / 255.0;
    CGFloat separatorColor = 168.0 / 255.0;
    
    CGRect frame = NSRectToCGRect(self.bounds);
    
    // create the gradient to be drawn as the background
    CGFloat colors[8] = {topGradient, 1, bottomGradient, 1};
    CGFloat locations[2] = {0, 1};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);
    CGColorSpaceRelease(colorSpace);
    
    // variables used for the path
    CGFloat minX = CGRectGetMinX(frame) + 1, minY = CGRectGetMinY(frame) + 1;
    CGFloat maxX = CGRectGetMaxX(frame) - 1, maxY = CGRectGetMaxY(frame) - 1;
    CGFloat cornerRadius = 7;
    
    // path covering the entire view (with rounded top corners)
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minX + cornerRadius, maxY);
    CGPathAddArcToPoint(path, NULL, minX, maxY, minX, maxY - cornerRadius, cornerRadius);
    CGPathAddLineToPoint(path, NULL, minX, minY);
    CGPathAddLineToPoint(path, NULL, maxX, minY);
    CGPathAddArcToPoint(path, NULL, maxX, maxY, minX + cornerRadius, maxY, cornerRadius);
    
    // stroke the view's border
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextClosePath(context);
    if (!isHighlighted) {
        CGContextSetGrayStrokeColor(context, borderColor, 1);
    } else {
        CGContextSetRGBStrokeColor(context, 72.0 / 255.0, 139.0 / 255.0, 208.0 / 255.0, 1);
    }
    CGContextSetLineWidth(context, 2);
    CGContextStrokePath(context);
    
    // fill the view's content
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextSetGrayFillColor(context, 0.91, 1);
    CGContextFillRect(context, frame);
    CGContextRestoreGState(context);

    // draw the title gradient
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, minX + cornerRadius, maxY);
    CGContextAddArcToPoint(context, minX, maxY, minX, maxY - cornerRadius, cornerRadius);
    CGContextAddLineToPoint(context, minX, maxY - kTitleHeight);
    CGContextAddLineToPoint(context, maxX, maxY - kTitleHeight);
    CGContextAddLineToPoint(context, maxX, maxY - cornerRadius);
    CGContextAddArcToPoint(context, maxX, maxY, minX + cornerRadius, maxY, cornerRadius);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, maxY), CGPointMake(0, maxY - kTitleHeight), 0);
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    
    // draw the title border
    CGPoint titleSeparatorPoints[] = {CGPointMake(minX, maxY - kTitleHeight - 0.5),
        CGPointMake(maxX, maxY - kTitleHeight - 0.5)};
    CGContextSetGrayStrokeColor(context, separatorColor, 1);
    CGContextSetLineWidth(context, 1);
    CGContextStrokeLineSegments(context, titleSeparatorPoints, 2);
    
    [self drawTitleAtPoint:CGPointMake(22, self.frame.size.height - (kTitleHeight / 2) - 8)];
}

- (void)drawTitleAtPoint:(CGPoint)aPoint {
    NSShadow * textShadow = [[NSShadow alloc] init];
    textShadow.shadowColor = [NSColor whiteColor];
    textShadow.shadowOffset = NSMakeSize(0, -1);
    textShadow.shadowBlurRadius = 0.5;
    NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSFont boldSystemFontOfSize:11], NSFontAttributeName,
                                 textShadow, NSShadowAttributeName, 
                                 [NSColor colorWithDeviceWhite:0.224 alpha:1], NSForegroundColorAttributeName, nil];
    
    NSMutableAttributedString * title = [[NSMutableAttributedString alloc] initWithString:[discrepancy summary]
                                                                               attributes:attributes];
    [title drawAtPoint:NSMakePoint(aPoint.x, aPoint.y)];
}

#pragma mark - Table View -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[discrepancy people] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ABPerson * person = [[discrepancy people] objectAtIndex:row];
    NSString * name;
    if ([[tableColumn identifier] isEqualToString:@"First"]) {
        name = [person valueForProperty:kABFirstNameProperty];
    } else {
        name = [person valueForProperty:kABLastNameProperty];
    }
    return (name == nil ? @"" : name);
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selected = [peopleTable selectedRow];
    if (selected < 0) {
        if ([delegate respondsToSelector:@selector(discrepancyView:previewPerson:)]) {
            [delegate discrepancyView:self previewPerson:nil];
        }
        return;
    }
    ABPerson * person = [[discrepancy people] objectAtIndex:selected];
    if ([delegate respondsToSelector:@selector(discrepancyView:previewPerson:)]) {
        [delegate discrepancyView:self previewPerson:person];
    }
}

@end
