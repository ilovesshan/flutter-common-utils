###  flutter-common-utils

### 1、简介

flutter-common-utils：基于flutter框架封装的一个通用工具包，里面包含了日常开发中的常用工具类以及通用界面，里面主要集成了较为流行的三方插件，例如：`provider` 、`get`、`dio`、`flutter_easyloading`、`flutter_screenutil`、`flutter_easyrefresh` 等等很多，具体可以查看 `pubspec.yaml` 文件



### 2、导入

可以将项目克隆到本地进行引入，也可以在 `yml`文件中通过 git方式引入。

```text
dependencies:
  flutter:
    sdk: flutter
  # 本地引入 common_utils
  common_utils:
    path: ./common_utils

  # git方式引入 common_utils
  common_utils:
    git:
      url: https://github.com/ilovesshan/flutter-common-utils.git
      ref: master
```



### 3、配置

#### 3.1、关于key.jks文件配置

+ 生成kjs文件

  ```
  keytool -genkey -v -keystore /D:/keys/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
  ```

  

+ 查看SHA值

  ```
  keytool -v -list -keystore /D:/keys/key.jks
  ```

  

+ 在项目根目录下新建key.properties文件

  ```properties
  storePassword=123456
  keyPassword=123456
  keyAlias=key
  storeFile=D:/keys/key.jks
  ```

  

#### 3.2、build.grade（模块级别）

```
// 读取 key.properties
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

android {
    compileSdkVersion 31
    defaultConfig {
        minSdkVersion 19
        multiDexEnabled true
        ndk {
        	abiFilters 'x86', 'x86_64', 'armeabi', 'armeabi-v7a', 'mips', 'mips64', 'arm64-v8a'
        }
        manifestPlaceholders = [
        	// 配置高德地图信息(需要使用定位/地图功能就配置)
        	// 这个KEY需要自己去高德地图官网申请
        	AMAP_KEY: "xxxx"
        ]
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
        debug {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // 关闭混淆, 否则在运行release包后可能出现运行崩溃
            minifyEnabled false //删除无用代码
            shrinkResources false //删除无用资源
        }

        debug {
            signingConfig signingConfigs.debug
        }
    }
    
    dependencies {
    	implementation 'com.android.support:multidex:1.0.3'
    	
    	// 高德地图依赖配置(需要使用定位/地图功能就配置)
        implementation fileTree(dir: 'libs', include: ['*.jar'])
        implementation('com.amap.api:location:5.2.0')
        implementation 'com.amap.api:search:5.0.0'
        implementation('com.amap.api:3dmap:8.1.0')
    }
}
```



#### 3.2、build.grade（工程级别）

```

```



#### 3.3、AndroidManifest.xml 

```xml
<!--允许访问网络，必选权限-->
<uses-permission android:name="android.permission.INTERNET" />

<!--允许获取精确位置，精准定位必选-->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

<!--允许获取粗略位置，粗略定位必选-->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!--允许获取设备和运营商信息，用于问题排查和网络定位（无gps情况下的定位），若需网络定位功能则必选-->
<uses-permission android:name="android.permission.READ_PHONE_STATE" />

<!--允许获取网络状态，用于网络定位（无gps情况下的定位），若需网络定位功能则必选-->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!--允许获取wifi网络信息，用于网络定位（无gps情况下的定位），若需网络定位功能则必选-->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

<!--允许获取wifi状态改变，用于网络定位（无gps情况下的定位），若需网络定位功能则必选-->
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />

<!--后台获取位置信息，若需后台定位则必选-->
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!--用于申请调用A-GPS模块,卫星定位加速-->
<uses-permission android:name="android.permission.ACCESS_LOCATION_EXTRA_COMMANDS" />

<!--允许写设备缓存，用于问题排查-->
<uses-permission android:name="android.permission.WRITE_SETTINGS" />

<!--允许写入扩展存储，用于写入缓存定位数据-->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!--允许读设备等信息，用于问题排查-->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />


<application
             android:label="common_util_test02"
             android:icon="@mipmap/ic_launcher">

    <!-- 配置定位Service（不用地图功能就不配） -->
    <service android:name="com.amap.api.location.APSService" />
</application>

```



### 4、使用

在项目入口文件main.dart进行配置

```dart
import 'package:app/router/router.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';

void main() {
    runApp(const Application());
}

class Application extends StatefulWidget {
    const Application({Key? key}) : super(key: key);

    @override
    State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
    @override
    Widget build(BuildContext context) {
        // 使用 GetMaterialApp
        return GetMaterialApp(
            // APP主题配色方案
            theme: AppInitialize.appTheme(),
            // 路由解决方案(也可自行配置)
            initialRoute: YFRouter.splash,
            getPages: YFRouter.routes(),
            builder: (_, c) {
                // android状态栏为透明沉浸式
                AppInitialize.setSystemUiOverlayStyle();
                // 屏幕适配
                AppInitialize.initScreenUtil(_);
                return FlutterEasyLoading(
                    child: GestureDetector(
                        child: c!,
                        // 处理键盘
                        onTap: ()=> AppInitialize.closeKeyBord(context)
                    ),
                );
            },
        );
    }
}

```

```dart
// 路由文件信息(仅供参考)

class YFRouter {
    static const String splash = "/splash";
    static const String menuContainer = "/menuContainer";
    static const String login = "/login";

    static List<GetPage> routes() {
        return [
            GetPage(name: splash, page: () => const SplashPage()),
            GetPage(name: login, page: () => const LoginPage()),
            GetPage(name: menuContainer, page: () => const MenuContainer()),
        ];
    }

    static onUnknownRoute() {}
}
```



### 5、最后

本项目工具库会长期更新维护下去...
