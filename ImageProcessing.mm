//
//  ImageProcessing.m
//  DetectHoughGPU
//
//  Created by Maitham Dib on 20/03/2016.
//  Copyright © 2016 HelloOpenCV. All rights reserved.
//

#import "DetectHoughGPU-Bridging-Header.h"

#import <Foundation/Foundation.h>
#include <opencv2/core/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc_c.h>
#import "opencv2/highgui.hpp"
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/objdetect.hpp>
#import <opencv2/imgcodecs/ios.h>
#include "KalmanFilterOneLane.hpp"
#include <iostream>

using namespace cv;

@interface ImageProcessing(){
}
@end

@implementation ImageProcessing : NSObject
- (id)init {
    self = [super init];
    
        return self;
}


vector<cv::Vec2f> kalmanPredict(vector<cv::Vec2f> lane){
        KalmanFilterOneLane KF(lane);
        vector<Vec2f> pp = KF.predictOneLane();
    return pp;
    }

- (vector<double>)getKalmanPrediction:(vector<double>) right{
    vector<Vec2f> rightLane;
    rightLane.push_back(Vec2f(right[0],right[1]));
    vector<Vec2f> pp = kalmanPredict(rightLane);
    vector<double> ppDouble;
    ppDouble.push_back(pp[0][0]);
    ppDouble.push_back(pp[0][1]);
    return ppDouble;
}
@end

