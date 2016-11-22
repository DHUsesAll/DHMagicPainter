//
//  DHMagicPaintView.m
//  MagicPainter
//
//  Created by Mac on 2016/11/21.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "DHMagicPaintView.h"
#import "DHVector2D.h"

@interface DHMagicPaintView ()

@property (nonatomic, strong) NSMutableArray * vectors;
@property (nonatomic, strong) CAShapeLayer * guidesLayer;

@property (nonatomic, copy) void (^completionBlock)(BOOL success);

@end

@implementation DHMagicPaintView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.numberOfParts = 8;
        self.layer.borderColor = self.guidesLayer.strokeColor;
        self.layer.borderWidth = 1;
        [self.layer addSublayer:self.guidesLayer];
        self.clipsToBounds = YES;
        
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:1].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    
    CGRect frame = self.frame;
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    
    CGPoint center = CGPointMake(width/2, height/2);
    
    [self.lineArray enumerateObjectsUsingBlock:^(NSArray<NSValue *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __block NSInteger baseVectorIdx = NSNotFound;
        __block DHVector2D * baseVector = nil;
        
        for (int i = 0; i < self.vectors.count; ++i) {
            
            for (int idx = 0; idx < obj.count; ++idx) {
                NSValue * pointValue = obj[idx];
                CGPoint point = [pointValue CGPointValue];
                
                if (idx == 0) {
                    baseVectorIdx = [self relatedVectorIndexWithPoint:point];
                    baseVector = self.vectors[baseVectorIdx];
                }
                NSInteger vectorIdx = baseVectorIdx + i;
                if (vectorIdx >= self.vectors.count) {
                    vectorIdx -= self.vectors.count;
                }
                
                CGFloat radian = [baseVector clockwiseAngleToVector:self.vectors[vectorIdx]];
                
                DHVector2D * pointVector = [[DHVector2D alloc] initWithStartPoint:center endPoint:point];
                [pointVector rotateClockwiselyWithRadian:radian];
                
                CGPoint endPoint = pointVector.endPoint;
                
                if (idx == 0) {
                    CGContextMoveToPoint(ctx, endPoint.x, endPoint.y);
                } else {
                    CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y);
                }

            }
            
            
            
        }
        
        CGContextStrokePath(ctx);
    }];
    
}

// 判断一个点处于哪一个向量的顺时针方向
- (NSInteger)relatedVectorIndexWithPoint:(CGPoint)point
{
    CGRect frame = self.frame;
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    
    CGPoint center = CGPointMake(width/2, height/2);
    
    DHVector2D * vector = [[DHVector2D alloc] initWithStartPoint:center endPoint:point];
    __block NSInteger relatedVectorIndex = NSNotFound;
    
    do {
        
        [vector rotateAntiClockwiselyWithRadian:M_PI/180];
        [self.vectors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([vector angleOfOtherVector:obj] <= M_PI/180 ) {
                relatedVectorIndex = idx;
                *stop = YES;
            }
            
        }];
        
    } while (relatedVectorIndex == NSNotFound);
    
    return relatedVectorIndex;
}

- (void)saveToAlbumWithCompletionBlock:(void (^)(BOOL))completion
{
    if (self.lineArray.count == 0) {
        return;
    }
    self.completionBlock = completion;
    self.layer.borderWidth = 0;
    [self.guidesLayer removeFromSuperlayer];
    
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer drawInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    UIGraphicsEndImageContext();
    self.layer.borderWidth = 1;
    [self.layer addSublayer:self.guidesLayer];
}



- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (self.completionBlock) {
        self.completionBlock(error != nil);
    }
}

- (void)setNumberOfParts:(NSInteger)numberOfParts
{
    _numberOfParts = numberOfParts;
    self.vectors = nil;
    [self.guidesLayer removeFromSuperlayer];
    self.guidesLayer = nil;
    [self.layer addSublayer:self.guidesLayer];
    [self setNeedsDisplay];
}

- (CAShapeLayer *)guidesLayer
{
    if (!_guidesLayer) {
       
        _guidesLayer = [CAShapeLayer layer];
        _guidesLayer.strokeColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
        _guidesLayer.fillColor = [UIColor clearColor].CGColor;
        
        UIBezierPath * bezierPath = [UIBezierPath bezierPath];
        
        [self.vectors enumerateObjectsUsingBlock:^(DHVector2D *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [bezierPath moveToPoint:obj.startPoint];
            [bezierPath addLineToPoint:obj.endPoint];
            
        }];
        
        _guidesLayer.path = bezierPath.CGPath;
        
    }
    return _guidesLayer;
}

- (NSMutableArray *)vectors
{
    if (!_vectors) {
        
        CGRect frame = self.frame;
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        
        CGPoint center = CGPointMake(width/2, height/2);
        
        
        _vectors = [NSMutableArray arrayWithCapacity:0];
        
        DHVector2D * baseVector = [[DHVector2D alloc] initWithStartPoint:center endPoint:CGPointMake(width/2, - (sqrt(2) - 1) * width/2)];
        
        for (int i = 0; i < self.numberOfParts; ++i) {
            
            DHVector2D * vector = [DHVector2D vectorWithVector:baseVector];
            CGFloat radian = 2 * M_PI / self.numberOfParts * i;
            [vector rotateClockwiselyWithRadian:radian];
            [_vectors addObject:vector];
            
        }
    }
    return _vectors;
}



@end
