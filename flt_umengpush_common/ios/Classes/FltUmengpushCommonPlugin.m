#import "FltUmengpushCommonPlugin.h"
#import <UIKit/UIKit.h>
#import <UMCommon/UMCommon.h>
#import <UMCommon/MobClick.h>

@implementation FltUmengpushCommonPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugin.bughub.dev/flt_umengpush_common"
                                     binaryMessenger:[registrar messenger]];
    FltUmengpushCommonPlugin* instance = [[FltUmengpushCommonPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

+ (void)initWithAppKey:(NSString *)appKey channel:(NSString *)channel{
    if (appKey==nil||[appKey isEqual:[NSNull null]]||[appKey isEqualToString:@""]) {
        NSLog(@"FltUmengpushCommonPlugin:appKey is null");
        return;
    }
    
    if (channel==nil||[channel isEqual:[NSNull null]]||[channel isEqualToString:@""]) {
        NSLog(@"FltUmengpushCommonPlugin:channel is null");
        return;
    }
    
    [UMConfigure initWithAppkey:appKey channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"init" isEqualToString:call.method]) {
        
        NSString* appKey = call.arguments[@"appKey"];
        NSString* channel = call.arguments[@"channel"];
        
        if (appKey==nil||[appKey isEqual:[NSNull null]]||[appKey isEqualToString:@""]) {
            result([FlutterError errorWithCode:@"Error" message:@"appKey is null" details:nil]);
            return;
        }
        
        if (channel==nil||[channel isEqual:[NSNull null]]||[channel isEqualToString:@""]) {
            result([FlutterError errorWithCode:@"Error" message:@"channel is null" details:nil]);
            return;
        }
        
        [UMConfigure initWithAppkey:appKey channel:channel];
        
        result(nil);
    } else if ([@"setLogEnabled" isEqualToString:call.method]) {
        
        BOOL bFlag = [call.arguments[@"enabled"] boolValue];
        
        [UMConfigure setLogEnabled:bFlag];
        
        result(nil);
    }  else if ([@"pageStart" isEqualToString:call.method]) {
        [self pageStart:call result:result];
    } else if ([@"pageEnd" isEqualToString:call.method]) {
        [self pageEnd:call result:result];
    } else if ([@"event" isEqualToString:call.method]) {
        [self event:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)pageStart:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* viewName = call.arguments[@"viewName"];
    
    [MobClick beginLogPageView:viewName];
    
    result([NSNumber numberWithBool:YES]);
}

- (void)pageEnd:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* viewName = call.arguments[@"viewName"];
    
    [MobClick endLogPageView:viewName];
    
    result([NSNumber numberWithBool:YES]);
}

- (void)event:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* eventId = call.arguments[@"eventId"];
    NSString* label = call.arguments[@"label"];
    
    if (label == nil) {
        [MobClick event:eventId];
    } else {
        [MobClick event:eventId label:label];
    }
    
    result([NSNumber numberWithBool:YES]);
}

@end
