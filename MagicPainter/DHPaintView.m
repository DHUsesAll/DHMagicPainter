//
//  DHPaintView.m
//  MagicPainter
//
//  Created by Mac on 2016/11/21.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "DHPaintView.h"

@interface DHPaintView ()

@property (nonatomic, strong) NSMutableArray * undoStack;


@end

@implementation DHPaintView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.lineArray = [NSMutableArray arrayWithCapacity:0];
        self.undoStack = [NSMutableArray arrayWithCapacity:0];
        
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    NSMutableArray * points = [NSMutableArray arrayWithCapacity:0];
    [points addObject:[NSValue valueWithCGPoint:location]];
    [self.lineArray addObject:points];
    // 每次有新的操作入栈后应清空撤销栈
    [self.undoStack removeAllObjects];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    NSMutableArray * points = self.lineArray.lastObject;
    [points addObject:[NSValue valueWithCGPoint:location]];
    
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    
    [self.lineArray enumerateObjectsUsingBlock:^(NSArray<NSValue *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [obj enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGPoint point = [obj CGPointValue];
            if (idx == 0) {
                CGContextMoveToPoint(ctx, point.x, point.y);
            } else {
                CGContextAddLineToPoint(ctx, point.x, point.y);
            }
            
        }];
        
        CGContextStrokePath(ctx);
        
    }];
}


- (void)undo
{
    if (self.lineArray.count == 0) {
        return;
    }
    // 从操作栈取出元素压入撤销栈
    NSMutableArray * points = self.lineArray.lastObject;
    [self.lineArray removeLastObject];
    [self.undoStack addObject:points];
    [self setNeedsDisplay];
}

- (void)redo
{
    if (self.undoStack.count == 0) {
        return;
    }
    // 从撤销栈取出元素压入操作栈
    NSMutableArray * points = self.undoStack.lastObject;
    [self.undoStack removeLastObject];
    [self.lineArray addObject:points];
    [self setNeedsDisplay];
}

- (void)clear
{
    [self.lineArray removeAllObjects];
    [self.undoStack removeAllObjects];

    [self setNeedsDisplay];
}

@end
