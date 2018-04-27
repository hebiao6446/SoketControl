//
//  ViewController.m
//  SoketControl
//
//  Created by apple on 2018/4/26.
//  Copyright © 2018年 hebiao. All rights reserved.
//

#import "ViewController.h"

#import "GCDAsyncUdpSocket.h"


//https://www.jianshu.com/p/949b8b1075d8   图像格式转换  可参考


@interface ViewController ()<GCDAsyncUdpSocketDelegate>{
    
    GCDAsyncUdpSocket *udpSocket;
    
    
    NSMutableData *mutableData;
    
    
    
    UIImageView *imageView;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//     uint16_t maxReceivSize = 60000;
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [udpSocket setMaxReceiveIPv4BufferSize:maxReceivSize];
    
    mutableData = [[NSMutableData alloc] init];
    
   
    uint16_t port = 9999;
    NSError *error;
     NSData *ip = [@"10.1.8.121" dataUsingEncoding:NSUTF8StringEncoding];
//    [udpSocket bindToAddress:ip error:&error];
//    if (error) {//监听错误打印错误信息
//        NSLog(@"error:%@",error);
//    }
    [udpSocket enableBroadcast:YES error:&error];
    if (error) {//监听错误打印错误信息
        NSLog(@"error:%@",error);
    }
    [udpSocket bindToPort: port error:&error];
    
    
    if (error) {//监听错误打印错误信息
        NSLog(@"error:%@",error);
    }else {//监听成功则开始接收信息
        [udpSocket beginReceiving:&error];
    }
    
    
    
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(50, 50, 20, 20);
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    
    
    
    
    imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(10, 100, 300, 200);
    imageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:imageView];
    
    
    
    
    
    unsigned long max_length = 5;
    
    char * pYuvBuf = "1qazxsw23edcvfr45tgbnhy67ujmki89o0plm";
    
    unsigned long arr_size ;
    
    char **cl = split_char(pYuvBuf, max_length,&arr_size);
    
    
    int i;
    for(i = 0; i < arr_size; i++)
    {
        printf("%s\n", cl[i]);
        free(cl[i]);
    }
    
    
    
    
    /*
    
    unsigned long total =  strlen(pYuvBuf);
    
    unsigned long count = total/max_length +(total%max_length==0?0:1);
    
    char *s_header = (char *)malloc(max_length);
    unsigned long tail_length = total - (count-1)*max_length;
    char *s_tail = (char *)malloc(tail_length);
    
    
    for (int i=0; i<count; i++) {
        
        if (i == count -1) {
            memcpy(s_tail,pYuvBuf +i*max_length, tail_length);
            
            NSLog(@"==========   %s",s_tail);
        }else{
            memcpy(s_header,pYuvBuf +i*max_length, max_length);
            NSLog(@"==========   %s",s_header);
        }
        
    }
    */
    
   
    
}

char ** split_char(char *pYuvBuf,unsigned long max_length,unsigned long * arr_size){
    
    
    unsigned long total =  strlen(pYuvBuf);
    
    unsigned long count = total/max_length +(total%max_length==0?0:1);
    
    *arr_size = count;
    
    unsigned long tail_length = total - (count-1)*max_length;
 
     char **c_list = calloc(count, sizeof(char *));
    
    for (int kk = 0; kk<count; kk++) {
        if (kk == count-1) {
             c_list[kk] =  calloc(tail_length,sizeof(char));
        }else{
             c_list[kk] = calloc(max_length,sizeof(char));
        }
       
    }
    
    for (int i=0; i<count; i++) {
        if (i == count -1) {
            memcpy(c_list[i],pYuvBuf +i*max_length, tail_length);
        }else{
            memcpy(c_list[i],pYuvBuf +i*max_length, max_length);
        }
    }
 
    return c_list;
}



-(void)buttonAction{
    NSData *data = [@"hello" dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *ip = [@"10.1.8.121" dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:@"10.1.8.121" port:9999 withTimeout:1 tag:999];
    
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"didConnectToAddress");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error{
     NSLog(@"didNotConnect");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
     NSLog(@"didSendDataWithTag");
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error{
     NSLog(@"didNotSendDataWithTag");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext{
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([string isEqualToString:@"start"]) {
        [mutableData resetBytesInRange:NSMakeRange(0, [mutableData length])];
        [mutableData setLength:0];
        
        
    }else if ([string isEqualToString:@"end"]){
        
        
//        unsigned char *buffer = (unsigned char *)[mutableData bytes];
        
        imageView.image = [self dataY2UIImage:[mutableData bytes] width:1280 height:720];
        
        
        
    }else{
        [mutableData appendData:data];
    }

    
}


-(UIImage *)dataY2UIImage:(void *)data width:(int)width height:(int)height{
    
    CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width, rgbSpace, kCGBitmapByteOrderDefault );
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
    
 
}

-(UIImage *)YUVtoUIImage:(int)w h:(int)h buffer:(unsigned char *)buffer{
    //YUV(NV12)-->CIImage--->UIImage Conversion
    NSDictionary *pixelAttributes = @{(NSString*)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    
    
    CVPixelBufferRef pixelBuffer = NULL;
    
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                          w,
                                          h,
                                          kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                                          (__bridge CFDictionaryRef)(pixelAttributes),
                                          &pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer,0);
    unsigned char *yDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    // Here y_ch0 is Y-Plane of YUV(NV12) data.
    unsigned char *y_ch0 = buffer;
    unsigned char *y_ch1 = buffer + w * h;
    memcpy(yDestPlane, y_ch0, w * h);
    unsigned char *uvDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    
    // Here y_ch1 is UV-Plane of YUV(NV12) data.
    memcpy(uvDestPlane, y_ch1, w * h/2);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    if (result != kCVReturnSuccess) {
        NSLog(@"Unable to create cvpixelbuffer %d", result);
    }
    
    // CIImage Conversion
    CIImage *coreImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *MytemporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef MyvideoImage = [MytemporaryContext createCGImage:coreImage
                                                       fromRect:CGRectMake(0, 0, w, h)];
    
    // UIImage Conversion
    UIImage *Mynnnimage = [[UIImage alloc] initWithCGImage:MyvideoImage
                                                     scale:1.0
                                               orientation:UIImageOrientationRight];
    
    CVPixelBufferRelease(pixelBuffer);
    CGImageRelease(MyvideoImage);
    
    return Mynnnimage;
    
}



- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error{
     NSLog(@"withError %@",error.description);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
