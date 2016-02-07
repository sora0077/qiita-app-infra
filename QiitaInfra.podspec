#
#  Be sure to run `pod spec lint iTunesMusicKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the sp
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specific
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPod
#

Pod::Spec.new do |s|

  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.name         = "QiitaInfra"
  s.version      = "1.0.0"
  s.summary      = "QiitaInfra."

  s.description  = <<-DESC
                   QiitaInfra Kit
                   DESC

  s.homepage     = "https://github.com/sora0077/QiitaKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "" => "" }
  s.source       = { :git => "https://github.com/sora0077/QiitaKit.git", :tag => ""}


  s.source_files  = "QiitaInfra/**/*.{swift}"
  s.exclude_files = "Classes/Exclude"

  s.dependency "QiitaKit"
  s.dependency "RealmSwift"
  s.dependency "QueryKit"
  s.dependency "QiitaDomainInterface"

end
