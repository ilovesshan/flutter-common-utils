###  flutter-common-utils

#### 1、简介

flutter-common-utils：基于flutter框架封装的一个通用工具包，里面包含了日常开发中的常用工具类以及通用界面，里面主要集成了较为流行的三方插件，例如：`provider` 、`get`、`dio`、`flutter_easyloading`、`flutter_screenutil`、`flutter_easyrefresh` 等等很多，具体可以查看 `pubspec.yaml` 文件



#### 2、导入

可以将项目克隆到本地进行引入，也可以在 `yml`文件中通过 git方式引入。

```yaml
dependencies:
	flutter:
		sdk: flutter
	# 本地引入 common_utils
	common_utils:
		path: ./common_utils


	# git方式引入 common_utils
	common_utils:
		git:
			url: git://github.com/ilovesshan/flutter-common-utils.git
			ref: master
```



#### 3、使用

在项目主文件中进行配置

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



#### 4、最后

本项目工具库会长期更新维护下去...
