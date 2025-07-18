# 1、设置一行多少个图标

defaults write com.apple.dock springboard-columns -int 10
# 2、设置多少行显示图标数量

defaults write com.apple.dock springboard-rows -int 8
# 3、重置Launchpad

defaults write com.apple.dock ResetLaunchPad -bool TRUE
# 4、重启Docker

killall Dock
