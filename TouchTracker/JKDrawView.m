//
//  JKDrawView.m
//  TouchTracker
//
//  Created by Jonathan Kim on 2/2/15.
//  Copyright (c) 2015 Jonathan Kim. All rights reserved.
//

#import "JKDrawView.h"
#import "JKLine.h"

@interface JKDrawView() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableDictionary *linesInProgress;
@property (nonatomic, strong) NSMutableArray *finishedLines;

// selectedLine property will be set to nil if the line is removed from finishedLines by clearing the screen
@property (nonatomic, weak) JKLine *selectedLine;

@property (nonatomic, strong) UIPanGestureRecognizer *moveRecognizer;

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

        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(tap:)];
        tapRecognizer.delaysTouchesBegan = YES;
        [tapRecognizer requireGestureRecognizerToFail:doubleTapGesture];
        [self addGestureRecognizer:tapRecognizer];

        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(longPress:)];
        [self addGestureRecognizer:pressRecognizer];

        self.moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(moveLine:)];
        self.moveRecognizer.delegate = self;
        self.moveRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.moveRecognizer];
    }

    return self;
}

- (void)moveLine:(UIPanGestureRecognizer *)gr
{
    // If we have not selected a line, we do not do anything here
    if (!self.selectedLine)
    {
        return;
    }

    // When the pan recognizer changes its position...
    if (gr.state == UIGestureRecognizerStateChanged)
    {
        // How far has the pan moved?
        CGPoint translation = [gr translationInView:self];

        // Add the translation to the current beginning and end points of the line
        CGPoint begin = self.selectedLine.begin;
        CGPoint end = self.selectedLine.end;
        begin.x += translation.x;
        begin.y += translation.y;
        end.x += translation.x;
        end.y += translation.y;

        // Set the new beginning and end points of the line
        self.selectedLine.begin = begin;
        self.selectedLine.end = end;

        // Redraw the screen
        [self setNeedsDisplay];
    }
}

- (void)doubleTap:(UIGestureRecognizer *)gr
{
    NSLog(@"Double tapped!");

    [self.linesInProgress removeAllObjects];
    [self.finishedLines removeAllObjects];

    [self setNeedsDisplay];
}

- (void)tap:(UIGestureRecognizer *)gr
{
    NSLog(@"Tap");

    CGPoint point = [gr locationInView:self];
    self.selectedLine = [self lineAtPoint:point];

    if (self.selectedLine)
    {
        // Make it the target of menu item action message
        [self becomeFirstResponder];

        // Grab the menu controller
        UIMenuController *menu = [UIMenuController sharedMenuController];

        // Create a new delete UIMenuItem
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete"
                                                        action:@selector(deleteLine:)];
        menu.menuItems = @[deleteItem];

        // Tell the menu where it shoudl come from and show it
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2)
                     inView:self];

        [menu setMenuVisible:YES animated:YES];
    }
    else
    {
        // Hide the menu if no line is selected
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }

    [self setNeedsDisplay];
}

- (void)deleteLine:(id)sender
{
    // Remove the selected line from the list of _finishedLines
    [self.finishedLines removeObject:self.selectedLine];

    // Redraw everything
    [self setNeedsDisplay];
}

- (void)longPress:(UIGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gr locationInView:self];
        self.selectedLine = [self lineAtPoint:point];

        if (self.selectedLine)
        {
            [self.linesInProgress removeAllObjects];
        }
    }
    else if (gr.state == UIGestureRecognizerStateEnded)
    {
        self.selectedLine = nil;
    }

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

    if (self.selectedLine)
    {
        [[UIColor greenColor] set];
        [self strokeLine:self.selectedLine];
    }
}

- (JKLine *)lineAtPoint:(CGPoint)p
{
    // Find a line close to p
    for (JKLine *l in self.finishedLines)
    {
        CGPoint start = l.begin;
        CGPoint end = l.end;

        // Check a few points on the line
        for (float t = 0.0; t <= 1.0; t += 0.05)
        {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y - start.y);

            // If the tapped point is within 20 points, let's return this line
            if (hypot(x - p.x, y - p.y) < 20.0)
            {
                return l;
            }
        }
    }

    // If nothing is close enough to the tapped point, then we did not select a line
    return nil;
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

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.moveRecognizer)
    {
        return YES;
    }

    return NO;
}

@end
