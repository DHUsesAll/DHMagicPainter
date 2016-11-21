//
//  ViewController.m
//  MagicPainter
//
//  Created by Mac on 2016/11/21.
//  Copyright © 2016年 Mac. All rights reserved.
//

#import "ViewController.h"
#import "DHMagicPaintView.h"

@interface ViewController ()

@property (nonatomic, strong) DHMagicPaintView * paintView;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    DHMagicPaintView * view = [[DHMagicPaintView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    view.center = self.view.center;
    [self.view addSubview:view];
    
    self.paintView = view;
    
    UIBarButtonItem * undoItem = [[UIBarButtonItem alloc] initWithTitle:@"undo" style:UIBarButtonItemStylePlain target:self action:@selector(undo:)];
    UIBarButtonItem * redoItem = [[UIBarButtonItem alloc] initWithTitle:@"redo" style:UIBarButtonItemStylePlain target:self action:@selector(redo:)];
    
    self.navigationItem.rightBarButtonItems = @[redoItem, undoItem];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStylePlain target:self action:@selector(clear:)];
    
    self.stepper.value = view.numberOfParts;
}

- (IBAction)save:(id)sender {
    [self.paintView saveToAlbumWithCompletionBlock:nil];
}

- (IBAction)onStepper:(UIStepper *)sender {
    self.paintView.numberOfParts = [sender value];
}

- (void)undo:(UIBarButtonItem *)sender
{
    [self.paintView undo];
}

- (void)redo:(UIBarButtonItem *)sender
{
    [self.paintView redo];
}

- (void)clear:(UIBarButtonItem *)sender
{
    [self.paintView clear];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
