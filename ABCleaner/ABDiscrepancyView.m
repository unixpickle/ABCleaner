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
        [solutionLabel setAlignment:NSCenterTextAlignment];
        [solutionLabel setStringValue:@"Action: "];
        
        solutionOptions = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 100, 26) pullsDown:NO];
        NSMutableArray * options = [NSMutableArray arrayWithCapacity:[aDiscrepancy numberOfResolutions] + 1];
        for (NSUInteger i = 0; i < [aDiscrepancy numberOfResolutions]; i++) {
            [options addObject:[aDiscrepancy titleForResolutionAtIndex:i]];
        }
        [options addObject:@"Take no action"];
        
        [self addSubview:disclosureIndicator];
    }
    return self;
}

#pragma mark - UI -

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    [disclosureIndicator setFrame:NSMakeRect(5, frameRect.size.height - (kTitleHeight / 2) - 8, 13, 13)];
}

#pragma mark Focus

- (BOOL)isFocused {
    return isFocused;
}

- (void)setIsFocused:(BOOL)aFlag {
    isFocused = aFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark Actions

- (void)disclosurePressed:(id)sender {
    NSRect frame = self.frame;
    if ([disclosureIndicator state] == 0) {
        frame.size.height = kTitleHeight + 2;
        self.frame = frame;
        // remote the additional UI components
    } else {
        frame.size.height = 100;
        self.frame = frame;
        // add the additional UI components
    }
    [self setNeedsDisplay:YES];
}

#pragma mark - Drawing -

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    // bg: 232
    
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
    CGContextSetRGBStrokeColor(context, borderColor, borderColor, borderColor, 1);
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
    CGContextSetGrayStrokeColor(context, borderColor, 1);
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

@end
