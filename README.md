前言:
    该Shell主要实现自动注册设备、自动拉取配置证书、代码签名、发布到Fir等功能。

操作说明:
sh ipa_resign.sh [udid] [ipa_input_path] [ipa_output_path] 

例子:
sh ipa_resign.sh UUID ./iPA_Source.ipa  ./iPA_Out.ipa

文件目录:
- ipa_resign.sh 执行脚本文件

- iPA_Source.ipa  待签名的ipa包

- *.mobileprovision 配置证书

- fastlane/Appfile    fastlane APP配置文件 (存放bundleid,账号等)

- fastlane/Fastfile   fastlane 自定义配置文件

- Gemfile   环境依赖文件


安装说明:
1. bundle install  (安装fastlane)
2. brew install jq (shell解析json)
3. 登录AppleId管理站生成APP专用密码，配置到FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD，建议放到~/.bash_profile
4. fastlane spaceauth -u APPID 
输入账号密码，此步骤需要两步验证，获取到FASTLANE_SESSION字符串，修改ipa_resign.sh文件里面的FASTLANE_SESSION为该字符串，后续在SESSION有效期的情况下就不需要两部验证以及账号密码了，建议FASTLANE_SESSION放到~/.bash_profile里面。
5. 查看自己KeyChain的CodeSignIdentity,修改ipa_resign.sh文件里面的CODESIGNING_IDENTITY为该字符串

运行环境:
1. p12文件 (找开发人员提供并安装到KeyChain,代码签名需要)
2. MacOSX系统环境
3. 账号密码 (找开发人员提供)


参考资料:

通过Safari浏览器获取iOS设备UDID(设备唯一标识符)
http://www.skyfox.org/safari-ios-device-udid.html

iOS各种证书之间详解关于Certificate、Provisioning Profile、App ID的介绍及其之间的关系http://www.zhongruitech.com/645998114.html

代码签名探析
https://objccn.io/issue-17-2/

iOS逆向必备绝技之ipa重签名
https://www.yangshebing.com/2018/01/06/iOS%E9%80%86%E5%90%91%E5%BF%85%E5%A4%87%E7%BB%9D%E6%8A%80%E4%B9%8Bipa%E9%87%8D%E7%AD%BE%E5%90%8D/

Jenkins + fastlane iOS 双重认证 自动更新配置文件配置Appfile使用sigh最后
https://cloud.tencent.com/developer/article/1353444

FIR发布应用
https://fir.im/docs/publish
