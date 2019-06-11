##!/bin/bash -ilex

# Get Input Params, like:
# sh ipa_resign.sh [udid] [ipa_input_path] [ipa_output_path] 
REGISTER_DEVICE_UDID=$1
IPA_INPUT_PATH=$2
IPA_OUTPUT_PATH=$3

# Set Environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Fastlane Session
export FASTLANE_SESSION=''
# Fastlane Specify Password 
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=''
# Skip Update Check
export FASTLANE_SKIP_UPDATE_CHECK=1
# Development Code Sign Identity
# 例如:iPhone Developer: XY (AB12345678)
CODESIGNING_IDENTITY=""

# Local User Password
#KEYCHAIN_PASSWORD=""

# Provision File Name
MOBILE_PROVISION_FILENAME="com.xuyanci.ipasupersignature-${REGISTER_DEVICE_UDID}.mobileprovision"


if [ -z "$REGISTER_DEVICE_UDID" ]; then 
    echo "Register Device UDID is Empty" 
    exit
    else 
    echo "Register Device UDID is ${REGISTER_DEVICE_UDID}"
fi

if [ -z "$IPA_INPUT_PATH" ]; then 
    echo "Ipa input path is Empty" 
    exit
    else 
    echo "Ipa input path is ${IPA_INPUT_PATH}"
fi

if [ -z "$IPA_OUTPUT_PATH" ]; then 
    echo "Ipa output path is Empty" 
    exit
    else 
    echo "Ipa output path is ${IPA_OUTPUT_PATH}"
fi


if [ ! -f "$IPA_OUTPUT_PATH" ];then

echo "iPA need to generate"

 ## unlock keychain
#security unlock-keychain -p KEYCHAIN_PASSWORD

# register devcie
fastlane run register_device name:"${REGISTER_DEVICE_UDID}" udid:"${REGISTER_DEVICE_UDID}"

# Wait for Auth
fastlane sigh --force --development --filename "${MOBILE_PROVISION_FILENAME}"  --skip_install true --skip_certificate_verification  true

# copy source file to desfile 
cp -f  "${IPA_INPUT_PATH}"  "${IPA_OUTPUT_PATH}" 

# Resign ipa
fastlane sigh resign "${IPA_OUTPUT_PATH}" --signing_identity "${CODESIGNING_IDENTITY}" -p "${MOBILE_PROVISION_FILENAME}"
fi

##################################### 上传到fir.im #####################################

# 需要到FIR查看
api_token=""
# 需要到FIR查看，应用信息
fir_app_id=""

response=$( curl -X "POST" "http://api.fir.im/apps" \
     -H "Content-Type: application/json" \
     -d "{\"type\":\"ios\", \"bundle_id\":\"com.beeto.ipasupersignature\", \"api_token\":\"${api_token}\"}")

cert=$(echo $response | jq .'cert')
icon=$(echo $cert | jq .'binary')
key=$(echo $icon | jq .'key' | sed 's/\"//g')  
token=$(echo $icon | jq .'token' | sed 's/\"//g')  

response=$(curl -F "key=${key}"  \
       -F "token=${token}"       \
       -F "file=@${IPA_OUTPUT_PATH}"   \
       -F "x:name=iPA_XY"        \
       -F "x:version=1.0.0"         \
       -F "x:build=1"               \
       -F "x:release_type=Inhouse"    \
       -F "x:changelog=first"      \
    	https://upload.qbox.me )

iscomplete=$(echo $response | jq .'iscomplete')

if [iscomplete]
	
then
	  echo "Upload Success" 
else
 	  echo "Upload Fail"  exit
fi   

# 获取Download Token
response=$( curl "http://api.fir.im/apps/${fir_app_id}/download_token?api_token=${api_token}")
token=$(echo $response | jq .'download_token' | sed 's/\"//g')  

# 获取url
response=$( curl -X "POST" "http://download.fir.im/apps/${fir_app_id}/install?download_token=${token}")
url=$(echo $response | jq .'url'  | sed 's/\"//g')

# 构建itms-services，通过Safari打开该链接安装即可
services="itms-services://?action=download-manifest&url=https://fir.im/plists/$url"

