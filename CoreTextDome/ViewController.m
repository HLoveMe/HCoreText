//
//  ViewController.m
//  CoreTextDome
//
//  Created by 朱子豪 on 16/4/22.
//  Copyright © 2016年 朱子豪. All rights reserved.
//

#import "ViewController.h"
#import "tempViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    tempViewController *temp =[[tempViewController alloc]init];
    [self.navigationController pushViewController:temp animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

