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

@property (nonatomic, strong) NSMutableDictionary *linesInProgress;
@property (nonatomic, strong) NSMutableArray *finishedLines;

@end

@implementation JKDrawView

- (instancetype)initWithFrame:(CGRect)r
{
    self = [super initWithFrame:r];

    if (self)
    {
        self.linesInProgress = [[NSMutableDictionary alloc] init];

        self.finishedLines = [@[] mutableCopy];
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;

        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(doubleTap:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.delaysTouchesBegan = YES;
        [self addGestureRecognizer:doubleTapGesture];
    }

    return self;
}

- (void)doubleTap:(UIGestureRecognizer *)gr
{
    NSLog(@"Double tapped!");

    [self.linesInProgress removeAllObjects];
    [self.finishedLines removeAllObjects];

    [self setNeedsDisplay];
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

    [[UIColor redColor] set];
    for (NSValue *key in self.linesInProgress)
    {
        [self strokeLine:self.linesInProgress[key]];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
    {
        CGPoint location = [t locationInView:self];
        JKLine *line = [[JKLine alloc] init];
        line.begin = location;
        line.end = location;

        NSValue *key = [NSValue valueWithNonretainedObject:t];
        self.linesInProgress[key] = line;
    }

    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
    {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        JKLine *line = self.linesInProgress[key];
        line.end = [t locationInView:self];
    }

    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
    {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        JKLine *line = self.linesInProgress[key];

        [self.finishedLines addObject:line];
        [self.linesInProgress removeObjectForKey:key];
    }

    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
    {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        [self.linesInProgress removeObjectForKey:key];
    }

    [self setNeedsDisplay];
}

@end
