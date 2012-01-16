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
        
        [self addSubview:disclosureIndicator];
    }
    return self;
}

#pragma mark - UI -

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
    __unused CGFloat topGradient = (isFocused ? 227.0 / 255.0 : 241.0 / 255.0);
    __unused CGFloat bottomGradient = (isFocused ? 199.0 / 255.0 : 214.0 / 255.0);
    __unused CGFloat borderColor = 153.0 / 255.0;
    __unused CGFloat separatorColor = 168.0 / 255.0;
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
