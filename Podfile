source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/OnePiece19/HXSpecs.git'

# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

# ignore all warnings from all pods
inhibit_all_warnings!


#target 'HXProject' do
#  # Comment the next line if you don't want to use dynamic frameworks
#  use_frameworks!
#
#  # Pods for HXProject
#
#end

#☆☆☆☆☆ 生产阶段远程库 ☆☆☆☆☆
def pro_project_pods
#  pod 'HXLeetCode', '0.1.0'
end

#☆☆☆☆☆ 开发阶段本地库 ☆☆☆☆☆
def dev_local_pods
   pod 'HXLeetCode', :path => 'Lib/HXLeetCode'
end

#☆☆☆☆☆ 测试阶段远程 ☆☆☆☆☆
def dev_remote_pods
# pod 'HXLeetCode', :git => 'git@github.com:OnePiece19/HXLeetCode.git', :branch => 'master'
end

#☆☆☆☆☆ 三方库 ☆☆☆☆☆
def vendors_pods
  
  pod 'YYCategories'
  pod 'SCLAlertView-Objective-C'
  
  pod 'ReactiveCocoa', '2.1.8'
  pod 'UMCCommon'
  pod 'UMCPush'
  pod 'UXCModule-iOS', '0.1.7.6'
  pod 'MJRefresh'
  pod 'TTTAttributedLabel', '2.0.0'
  pod 'YYModel', '~> 1.0.4'
  pod 'Bugly', '2.5.2'
  pod 'ZYBLottieiOS','2.5.5'
  pod 'AFNetworking','4.0.1'
  pod 'FBAllocationTracker', :git => 'https://gitee.com/mirrors_facebookarchive/FBAllocationTracker.git', :tag => '0.1.5'
end

#☆☆☆☆☆ 调试工具 ☆☆☆☆☆
def debugger_pods
end


abstract_target :App do
  
  pro_project_pods  # 生产阶段远程库
  dev_local_pods    # 开发阶段本地库
  dev_remote_pods   # 开发阶段远程分支库

  vendors_pods      # 三方库
  debugger_pods     # 调试库
  
  target :HXProject do
    project 'HXProject.xcodeproj'
  end
  
end



