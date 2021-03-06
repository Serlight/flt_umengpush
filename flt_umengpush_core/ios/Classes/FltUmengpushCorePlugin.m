#import "FltUmengpushCorePlugin.h"
#import <UMPush/UMessage.h>

@interface FltUmengpushCorePlugin () <UNUserNotificationCenterDelegate>
@property(readonly,nonatomic) NSObject<FlutterPluginRegistrar>* registrar;
@end

@implementation FltUmengpushCorePlugin {
    FlutterEventSink eventSink;
    NSDictionary* lastUserInfo;//最后一次推送内容
}

-(instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*) registrar{
    self = [super init];
    
    _registrar = registrar;
    
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugin.bughub.dev/flt_umengpush_core"
            binaryMessenger:[registrar messenger]];
  FltUmengpushCorePlugin* instance = [[FltUmengpushCorePlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"plugin.bughub.dev/flt_umengpush_core/event" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
    
    [registrar addApplicationDelegate:instance];
    
}



- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"configure" isEqualToString:call.method]) {
      
      [[UIApplication sharedApplication] registerForRemoteNotifications];
      
    result(nil);
  }else if ([@"addTags" isEqualToString:call.method]) {//添加标签 示例：将“标签1”、“标签2”绑定至该设备
      
      NSDictionary *argsDict = call.arguments;
      
      NSArray *tags = argsDict[@"tags"];
      
      [UMessage addTags:tags response:^(id  _Nullable responseObject, NSInteger remain, NSError * _Nullable error) {
          
      }];
      
      result(nil);
  }else if ([@"deleteTags" isEqualToString:call.method]) {//删除标签,将之前添加的标签中的一个或多个删除
      
      NSDictionary *argsDict = call.arguments;
      
      NSArray *tags = argsDict[@"tags"];
      
      [UMessage deleteTags:tags response:^(id  _Nullable responseObject, NSInteger remain, NSError * _Nullable error) {
          
      }];
      
      result(nil);
  }else if ([@"addAlias" isEqualToString:call.method]) {//别名增加，将某一类型的别名ID绑定至某设备，老的绑定设备信息还在，别名ID和device_token是一对多的映射关系
      
      NSDictionary *argsDict = call.arguments;
      
      NSString *alias = argsDict[@"alias"];
      
      NSString *type = argsDict[@"type"];
      
      [UMessage addAlias:alias type:type response:^(id  _Nullable responseObject, NSError * _Nullable error) {
          FlutterMethodChannel* channel = [FlutterMethodChannel
          methodChannelWithName:@"plugin.bughub.dev/flt_umengpush_core/UTrack.ICallBack_addAlias"
                binaryMessenger:[self.registrar messenger]];
          BOOL isSuccess = NO;
          NSString *message = @"";
          
          if (error==nil) {
              isSuccess = YES;
              message = responseObject;
          } else {
              isSuccess = NO;
              message = error.localizedDescription;
          }
          
          NSDictionary *resultDict = @{@"isSuccess": @(isSuccess),@"message":message};
          [channel invokeMethod:@"callback" arguments: resultDict];
      }];
      
      result(nil);
  }else if ([@"setAlias" isEqualToString:call.method]) {//别名绑定，将某一类型的别名ID绑定至某设备，老的绑定设备信息被覆盖，别名ID和deviceToken是一对一的映射关系
      
      NSDictionary *argsDict = call.arguments;
      
      NSString *alias = argsDict[@"alias"];
      
      NSString *type = argsDict[@"type"];
      
      [UMessage setAlias:alias type:type response:^(id  _Nullable responseObject, NSError * _Nullable error) {
          FlutterMethodChannel* channel = [FlutterMethodChannel
          methodChannelWithName:@"plugin.bughub.dev/flt_umengpush_core/UTrack.ICallBack_setAlias"
                binaryMessenger:[self.registrar messenger]];
          BOOL isSuccess = NO;
          NSString *message = @"";
          
          if (error==nil) {
              isSuccess = YES;
              message = responseObject;
          } else {
              isSuccess = NO;
              message = error.localizedDescription;
          }
          
          NSDictionary *resultDict = @{@"isSuccess": @(isSuccess),@"message":message};
          [channel invokeMethod:@"callback" arguments: resultDict];
      }];
      
      result(nil);
  }else if ([@"deleteAlias" isEqualToString:call.method]) {//移除别名ID
      
      NSDictionary *argsDict = call.arguments;
      
      NSString *alias = argsDict[@"alias"];
      
      NSString *type = argsDict[@"type"];
      
      [UMessage removeAlias:alias type:type response:^(id  _Nullable responseObject, NSError * _Nullable error) {
          
          FlutterMethodChannel* channel = [FlutterMethodChannel
          methodChannelWithName:@"plugin.bughub.dev/flt_umengpush_core/UTrack.ICallBack_deleteAlias"
                binaryMessenger:[self.registrar messenger]];
          BOOL isSuccess = NO;
          NSString *message = @"";

          if (error==nil) {
              isSuccess = YES;
              message = responseObject;
          } else {
              isSuccess = NO;
              message = error.localizedDescription;
          }

          NSDictionary *resultDict = @{@"isSuccess": @(isSuccess),@"message":message};
          [channel invokeMethod:@"callback" arguments: resultDict];
      }];
      
      result(nil);
  } else {
      result(FlutterMethodNotImplemented);
  }
}

- (NSString *)stringDevicetoken:(NSData *)deviceToken {
    
    if (@available(iOS 13.0, *)) {
        if (![deviceToken isKindOfClass:[NSData class]]) return @"";
        const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
        NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                              ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                              ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                              ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
        return hexToken;
    }
    
    NSString *token = [deviceToken description];
    NSString *pushToken = [[[token stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"umeng_push_plugin token: %@", pushToken);
    return pushToken;
}

-(void)sendMessage:(NSDictionary*)userInfo{
    eventSink(@{
        @"event":@"notificationHandler",
        @"data":userInfo
    });
    lastUserInfo = nil;
}

#pragma ApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
        UMessageRegisterEntity *entity = [[UMessageRegisterEntity alloc]init];
        if (@available(iOS 10.0, *)) {
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        } else {
            // Fallback on earlier versions
        }
        [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
//            NSLog(@"didReceiveRemoteNotification:%d %@",granted,error);
        }];
    
    return YES;
}

#pragma UNUserNotificationCenterDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    [self stringDevicetoken:deviceToken];
    if (eventSink!=nil) {
        eventSink(@{
            @"event":@"configure",
            @"deviceToken":[self stringDevicetoken:deviceToken]
        });
    }
}

//iOS10以下使用这两个方法接收通知
- (BOOL)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
//    NSLog(@"didReceiveRemoteNotification:%@",userInfo);
    
    if (eventSink!=nil) {
        [self sendMessage:userInfo];
    }
    
    [UMessage setAutoAlert:NO];
    if ([[[UIDevice currentDevice] systemVersion]intValue] < 10) {
        [UMessage didReceiveRemoteNotification:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
    return YES;
}

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//iOS10新增：处理前台收到通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)){
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    
//    NSLog(@"willPresentNotification:%@",userInfo);
    
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [UMessage setAutoAlert:NO];
        //应用处于前台时的远程推送接受
        [UMessage didReceiveRemoteNotification:userInfo];
    }
    
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
    
}

//iOS10新增：处理后台点击通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
//    NSLog(@"didReceiveNotificationResponse:%@",userInfo);
    
    if (eventSink!=nil) {
        [self sendMessage:userInfo];
    } else { //当应用被杀掉，点击通知从后台启动时，此时eventSink未初始化完成为nil,先把通知信息保存下来
        lastUserInfo = userInfo;
    }
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
    }else{
        //应用处于后台时的本地推送接受
    }
}

#endif

#pragma FltterStreamHandler
-(FlutterError *)onCancelWithArguments:(id)arguments{
    eventSink = nil;
    return nil;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events{
    eventSink = events;
    //如果应用被杀掉收到推送，点击通知从后台启动时，此时eventSink初始化完成,把保存下来的通知信息通知Flutter
    if (lastUserInfo!=nil) {
        [self sendMessage:lastUserInfo];
    }
    return nil;
}

@end
