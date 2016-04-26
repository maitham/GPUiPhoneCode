//
//  ViewController.swift
//  DetectHoughGPU
//
//  Created by Maitham Dib on 25/02/2016.
//  Copyright © 2016 HelloOpenCV. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UIViewController {
    
    var videoCamera:GPUImageVideoCamera?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Set Camera Settings
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .Back)
        videoCamera!.outputImageOrientation = .LandscapeLeft;
//        GPUVideoOutput.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        GPUVideoOutput.fillMode = kGPUImageFillModePreserveAspectRatio
        
        let start = NSDate(); // <<<<<<<<<< Start time
        // Initiaite Hough transform Filter and threshold
        let houghTransformFilter = GPUImageHoughTransformLineDetector()
        houghTransformFilter.lineDetectionThreshold = 0.25
        
        // Initiate Line Generator set size and line width and color
        let lineGenerator = GPUImageLineGenerator()
        
        //        var top_margin:CGFloat = 420;
        //        var bottom_margin:CGFloat = 600;
        //        var left_lane_left_margin:CGFloat = 0;
        //        var left_lane_right_margin:CGFloat = 525;
        //        var right_lane_left_margin:CGFloat = 525;
        //        var right_lane_right_margin:CGFloat = 1000;
        
//        lineGenerator.forceProcessingAtSize(CGSize(width:524.8,height:180))
        lineGenerator.forceProcessingAtSize(GPUVideoOutput.sizeInPixels)
        lineGenerator.lineWidth = 50
        lineGenerator.setLineColorRed(1.0, green:0.0, blue:0.0)
        
        // Find filter and store lines in lines Detected block to then add to the image
        houghTransformFilter.linesDetectedBlock =
            {(lineArray:UnsafeMutablePointer<GLfloat>, linesDetected:UInt, frameTime:CMTime) in
                lineGenerator.renderLinesFromArray(lineArray, count:linesDetected, frameTime:frameTime)
                
                var lowm = 0.9, highm = 1.3// This set is for portrait (road test) [0.5, 0.65] nice too
                var leftcount:Int = 0, leftm:GLfloat = 0, leftb:GLfloat = 0, rightcount:Int = 0, rightm:GLfloat = 0, rightb:GLfloat = 0;
                var hasLeft = false, hasRight = false;
                
                for var i:Int = 0; i<Int(linesDetected); i++
                {
                    var m = lineArray[2*i], b = lineArray[2*i+1];
//                    NSLog("m: %f, b: %f", m, b);
                    if (Double(m) > lowm && Double(m) < highm) { // Right side
                        rightcount++;
                        rightm += m;
                        rightb += b;
                        hasRight = true;
                        
                    } else if (Double(-m) > lowm && Double(-m) < highm) { // Left side
                        leftcount++;
                        leftm += m;
                        leftb += b;
                        hasLeft = true;
                    }

                }

                var nLines = 0;
                if (hasRight) {
                    lineArray[0] = rightm / GLfloat(rightcount);
                    lineArray[1] = rightb / GLfloat(rightcount);
//                    xInter += [self xInterceptAty:1 m:lineArray[0] b:lineArray[1]];
                    nLines++;
                    
                    if (hasLeft) {
                        lineArray[2] = leftm / GLfloat(leftcount);
                        lineArray[3] = leftb / GLfloat(leftcount);
//                        xInter += [self xInterceptAty:1 m:lineArray[2] b:lineArray[3]];
                        nLines++;
                    }
                } else if (hasLeft) {
                    lineArray[0] = leftm / GLfloat(leftcount);
                    lineArray[1] = leftb / GLfloat(leftcount);
//                    xInter += [self xInterceptAty:1 m:lineArray[2] b:lineArray[3]];
                    nLines++;
                }

                lineGenerator.renderLinesFromArray(lineArray, count:UInt(nLines), frameTime:frameTime)
                
            }
        let crosshairs = GPUImageCrosshairGenerator();
        crosshairs.crosshairWidth = 10;
        crosshairs.forceProcessingAtSize(GPUVideoOutput.sizeInPixels)
        
//        var top_margin:CGFloat = 420;
//        var bottom_margin:CGFloat = 600;
//        var left_lane_left_margin:CGFloat = 0;
//        var left_lane_right_margin:CGFloat = 525;
//        var right_lane_left_margin:CGFloat = 525;
//        var right_lane_right_margin:CGFloat = 1000;
//        
        //initiate Filters
        let cropFilter = GPUImageCropFilter()
        cropFilter.cropRegion = CGRectMake(0, 0.58,0.41, 0.25)

        let blendFilter = GPUImageAlphaBlendFilter()
        blendFilter.forceProcessingAtSize(GPUVideoOutput.sizeInPixels)

        let gammaFilter = GPUImageGammaFilter()

        videoCamera?.addTarget(houghTransformFilter);
        houghTransformFilter.addTarget(cropFilter);
        
        videoCamera?.addTarget(gammaFilter);
        gammaFilter.addTarget(blendFilter);
        
        lineGenerator.addTarget(blendFilter);
        blendFilter.addTarget(GPUVideoOutput);
        
//        cropFilter.addTarget(lineGenerator);
//        lineGenerator.addTarget(GPUVideoOutput)
//        cropFilter.addTarget(GPUVideoOutput);
        
//        // Daisy Chain Filters
//        videoCamera?.addTarget(filter)
//        videoCamera?.addTarget(gammaFilter)
//        
//        
//        gammaFilter.addTarget(blendFilter)
//        lineGenerator.addTarget(blendFilter)
//        blendFilter.addTarget(GPUVideoOutput)
//
        let end = NSDate();   // <<<<<<<<<<   end time
        let timeInterval: Double = end.timeIntervalSinceDate(start); // <<<<< Difference in seconds (double)
        print("Time to evaluate problem: \(timeInterval) seconds")

        videoCamera?.startCameraCapture()
    }
    @IBOutlet weak var GPUVideoOutput: GPUImageView!
}



//
//        [houghDetector setLinesDetectedBlock:^(GLfloat* lineArray, NSUInteger linesDetected, CMTime frameTime){
//            // Find lines within slope bound
//            float lowm = 0.4, highm = 0.8; // This set is for portrait (road test) [0.5, 0.65] nice too
//            //		float lowm = 2.15, highm = 2.6; // This set is for portrait left (video playing)
//            float leftcount = 0, leftm = 0, leftb = 0, rightcount = 0, rightm = 0, rightb = 0;
//            bool hasLeft = false, hasRight = false;
//            for (int i = 0; i < linesDetected; i++) {
//            float m = lineArray[2*i], b = lineArray[2*i+1];
//            //			NSLog(@"m: %f, b: %f", lineArray[2*i], lineArray[2*i+1]);
//
//            if (m > lowm && m < highm) { // Right side
//            rightcount++;
//            rightm += m;
//            rightb += b;
//            hasRight = true;
//
//            } else if (-m > lowm && -m < highm) { // Left side
//            leftcount++;
//            leftm += m;
//            leftb += b;
//            hasLeft = true;
//            }
//            }
//
//            // Compute average lines and store in old array
//            int nLines = 0;
//            float xInter = 0;
//            if (hasRight) {
//            lineArray[0] = rightm / rightcount;
//            lineArray[1] = rightb / rightcount;
//            xInter += [self xInterceptAty:1 m:lineArray[0] b:lineArray[1]];
//            nLines++;
//
//            if (hasLeft) {
//            lineArray[2] = leftm / leftcount;
//            lineArray[3] = leftb / leftcount;
//            xInter += [self xInterceptAty:1 m:lineArray[2] b:lineArray[3]];
//            nLines++;
//            }
//            } else if (hasLeft) {
//            lineArray[0] = leftm / leftcount;
//            lineArray[1] = leftb / leftcount;
//            xInter += [self xInterceptAty:1 m:lineArray[2] b:lineArray[3]];
//            nLines++;
//            }
//
//            // Debug prints
//            //		NSLog(@"Number of lines: %ld; Number of new lines: %d", (unsigned long) linesDetected, nLines);
//            //		if (nLines > 0) NSLog(@"%f %f %f %f", lineArray[0], lineArray[1], lineArray[2], lineArray[3]);
//
//            // Render lines
//            [lineGenerator renderLinesFromArray:lineArray count:nLines frameTime:frameTime];
//
//            // Generate crosses
//            if (nLines == 0) xInter = 0.5;
//            else xInter /= nLines;
//            int nPoints = 20;
//            GLfloat center[nPoints * 2];
//            for (int i = 0; i < nPoints; i++) {
//            center[2*i] = xInter;
//            center[2*i+1] = 1.0 - 0.4 / nPoints * i;
//            }
//
//            // Render crosses
//            [crosshairGenerator renderCrosshairsFromArray:center count:nPoints frameTime:frameTime];
//            }];
//
//
//
//


      