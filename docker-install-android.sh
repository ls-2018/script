docker run -itd --rm --privileged --pull always -v ~/data/:/data -p 5555:5555 registry.cn-hangzhou.aliyuncs.com/acejilam/redroid:12.0.0-latest
sleep 5s
brew install android-platform-tools
adb connect localhost:5555
