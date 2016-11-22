//
//  DHPaintView.h
//  MagicPainter
//
//  Created by Mac on 2016/11/21.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHPaintView : UIView

@property (nonatomic, strong) NSMutableArray <NSMutableArray <NSValue *> *>* lineArray;

- (void)clear;
- (void)undo;
- (void)redo;

@end
