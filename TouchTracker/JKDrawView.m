//
//  JKDrawView.m
//  TouchTracker
//
//  Created by Jonathan Kim on 2/2/15.
//  Copyright (c) 2015 Jonathan Kim. All rights reserved.
//

#import "JKDrawView.h"
#import "JKLine.h"

@interface JKDrawView()

@property (nonatomic, strong) JKLine *currentLine;
@property (nonatomic, strong) NSMutableArray *finishedLines;

@end

@implementation JKDrawView

- (instancetype)initWithFrame:(CGRect)r
{
    self = [super initWithFrame:r];

    if (self)
    {
        self.finishedLines = [@[] mutableCopy];
        self.backgroundColor = [UIColor grayColor];
    }

    return self;
}

- (void)strokeLine:(JKLine *)line
{
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;

    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void)drawRect:(CGRect)rect
{
    // Draw finished lines in black
    [[UIColor blackColor] set];
    for (JKLine *line in self.finishedLines)
    {
        [self strokeLine:line];
    }

    if (self.currentLine)
    {
        // If there is a line currently being drawn, do it in red
        [[UIColor redColor] set];
        [self strokeLine:self.currentLine];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];

    // Get location of the touch in view's coordinate system
    CGPoint location = [t locationInView:self];

    self.currentLine = [[JKLine alloc] init];
    self.currentLine.begin = location;
    self.currentLine.end = location;

    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint location = [t locationInView:self];

    self.currentLine.end = location;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.finishedLines addObject:self.currentLine];
    self.currentLine = nil;

    [self setNeedsDisplay];
}

@end
