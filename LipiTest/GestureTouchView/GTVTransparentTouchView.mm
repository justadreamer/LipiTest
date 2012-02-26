//
//  TransparentTouchView.m
//  LifelikeClassifieds
//
//  Created by Eugene Dorfman on 4/15/11.
//  Copyright 2011 Postindustria. All rights reserved.
//

#import "GTVGlobals.h"
#import "GTVTransparentTouchView.h"

@interface GTVTransparentTouchView ()
@property (nonatomic,retain) NSTimer* timer;
@property (nonatomic,retain) NSMutableArray* pointGroups;

- (void) curveControlPoints:(NSArray*)points first:(NSArray**) firstControlPoints second:(NSArray**)secondControlPoints;
- (void) firstControlPoints:(double*)x rhs:(double*)rhs n:(int)n;
- (void) doResetPoints;
- (void) addPoint:(CGPoint)point;
- (void) addPointGroup;
- (void) drawCurveForPoints:(NSArray*)points inRect:(CGRect)rect;
@end 

@implementation GTVTransparentTouchView
@synthesize pointGroups;
@synthesize strokeColor;
@synthesize delegate;
@synthesize timer;
@synthesize resetTimeInterval;

- (void)dealloc {
    self.pointGroups = nil;
    self.delegate = nil;
    self.timer = nil;
    [super dealloc];
}

- (void) initPointGroups {
    self.pointGroups = [NSMutableArray array];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.resetTimeInterval = 1;
        self.strokeColor = [UIColor redColor];
        [self initPointGroups];
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    for (NSArray* points in self.pointGroups) {
        [self drawCurveForPoints:points inRect:rect];
    }
}

- (void) drawCurveForPoints:(NSArray*)points inRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    const CGFloat* components = CGColorGetComponents(self.strokeColor.CGColor);
    CGContextSetRGBStrokeColor(context, components[0], components[1], components[2], components[3]);
    CGContextSetLineWidth(context, 5);
    NSUInteger idx = 0;
    NSArray* firstControlPoints = nil;
    NSArray* secondControlPoints = nil;
    [self curveControlPoints:points first:&firstControlPoints second:&secondControlPoints];
    CGContextBeginPath(context);
    for (NSValue* val in points) {
        CGPoint point = [val CGPointValue];
        if (0==idx) {
            CGContextMoveToPoint(context, point.x, point.y);
        } else {
            CGPoint cp1 = [[firstControlPoints objectAtIndex:idx-1] CGPointValue];
            CGPoint cp2 = [[secondControlPoints objectAtIndex:idx-1] CGPointValue];
            CGContextAddCurveToPoint(context, cp1.x, cp1.y, cp2.x, cp2.y, point.x, point.y);
        }
        idx++;
    }
    CGContextStrokePath(context);
}

- (void) curveControlPoints:(NSArray*)_points first:(NSArray**) firstControlPoints second:(NSArray**)secondControlPoints {
    if ([_points count]<2)
        return;
    CGPoint* knots = new CGPoint [[_points count]];
    NSUInteger idx = 0;
    for (NSValue* val in _points) {
        knots[idx] = [val CGPointValue];
        idx++;
    }
    int n = [_points count]-1;

    if (n == 1)
    { // Special case: Bezier curve should be a straight line.
        CGPoint pt1;
        pt1.x = (2 * knots[0].x + knots[1].x) / 3;
        pt1.y = (2 * knots[0].y + knots[1].y) / 3;
        *firstControlPoints = [NSArray arrayWithObject:[NSValue valueWithCGPoint:pt1]];

        CGPoint pt2;
        pt2.x = 2 * pt1.x - knots[0].x;
        pt2.y = 2 * pt1.y - knots[0].y;

        *secondControlPoints = [NSArray arrayWithObject:[NSValue valueWithCGPoint:pt2]];
        return;
    }
    
    // Calculate first Bezier control points
    // Right hand side vector
    double* rhs = new double[n];
    
    // Set right hand side X values
    for (int i = 1; i < n - 1; ++i)
        rhs[i] = 4 * knots[i].x + 2 * knots[i + 1].x;
    rhs[0] = knots[0].x + 2 * knots[1].x;
    rhs[n - 1] = (8 * knots[n - 1].x + knots[n].x) / 2.0;

    // Get first control points X-values
    double* x = new double[n];
    [self firstControlPoints:x rhs:rhs n:n];
    
    // Set right hand side Y values
    for (int i = 1; i < n - 1; ++i)
        rhs[i] = 4 * knots[i].y + 2 * knots[i + 1].y;
    rhs[0] = knots[0].y + 2 * knots[1].y;
    rhs[n - 1] = (8 * knots[n - 1].y + knots[n].y) / 2.0;

    // Get first control points Y-values
    double* y = new double[n];
    [self firstControlPoints:y rhs:rhs n:n];

    // Fill output arrays.
    NSMutableArray* _firstControlPoints = [NSMutableArray array];
    NSMutableArray* _secondControlPoints = [NSMutableArray array];
    for (int i = 0; i < n; ++i) {
        // First control point
        CGPoint pt1 = CGPointMake(x[i], y[i]);
        [_firstControlPoints addObject:[NSValue valueWithCGPoint:pt1]];
        // Second control point
        CGPoint pt2;
        if (i < n - 1) {
            pt2 = CGPointMake(2 * knots[i + 1].x - x[i + 1], 2 * knots[i + 1].y - y[i + 1]);
        } else {
            pt2 = CGPointMake((knots[n].x + x[n - 1]) / 2,(knots[n].y + y[n - 1]) / 2);
        }
        [_secondControlPoints addObject:[NSValue valueWithCGPoint:pt2]];
    }
    *firstControlPoints = [NSArray arrayWithArray:_firstControlPoints];
    *secondControlPoints = [NSArray arrayWithArray:_secondControlPoints];
    delete [] rhs;
    delete [] x;
    delete [] y;
    delete [] knots;
}

/// <summary>
/// Solves a tridiagonal system for one of coordinates (x or y)
/// of first Bezier control points.
/// </summary>
/// <param name="rhs">Right hand side vector.</param>
/// <returns>Solution vector.</returns>
- (void) firstControlPoints:(double*)x rhs:(double*)rhs n:(int)n {
    double* tmp = new double[n]; // Temp workspace.
    
    double b = 2.0;
    x[0] = rhs[0] / b;
    for (int i = 1; i < n; i++) // Decomposition and forward substitution.
    {
        tmp[i] = 1 / b;
        b = (i < n - 1 ? 4.0 : 3.5) - tmp[i];
        x[i] = (rhs[i] - x[i - 1]) / b;
    }
    for (int i = 1; i < n; i++)
        x[n - i - 1] -= tmp[n - i] * x[n - i]; // Backsubstitution.
    
    delete [] tmp;
}              

- (void) notifyDelegatePointGroupsDidChange {
    [self.delegate touchView:self pointGroupsDidChange:self.pointGroups];
}

- (void) doResetPoints {
    if ([self.delegate touchView:self shouldTimerResetPointGroups:self.pointGroups]) {
        [self notifyDelegatePointGroupsDidChange];
        [self initPointGroups];
        [self setNeedsDisplay];
    }
}

- (void) startResetPointsTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.resetTimeInterval target:self selector:@selector(doResetPoints) userInfo:nil repeats:NO];
}

- (void) stopResetPointsTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void) addPoint:(CGPoint)point {
    [self stopResetPointsTimer];
    [[self.pointGroups lastObject] addObject:[NSValue valueWithCGPoint:point]];
    [self setNeedsDisplay];
    [self notifyDelegatePointGroupsDidChange];
}

- (void) addPointGroup {
    [self.pointGroups addObject:[NSMutableArray array]];
}

- (void) addPointsFromTouches:(NSSet*)touches {
    [self addPoint:[[touches anyObject] locationInView:self]];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self addPointGroup];
    [self addPointsFromTouches:touches];
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self addPointsFromTouches:touches];
    [[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self addPointsFromTouches:touches];
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [self startResetPointsTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesCancelled:touches withEvent:event];
    [self startResetPointsTimer];
}

@end