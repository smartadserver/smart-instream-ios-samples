Pod::Spec.new do |s|
  s.name                = "${COMMERCIAL_NAME}"
  s.version             = "${VERSION}"
  s.summary             = "Smart AdServer — Core SDK"
  s.homepage            = "http://www.smartadserver.com/"
  s.documentation_url   = "https://documentation.smartadserver.com/"
  s.license             = { :type => "COMMERCIAL", :text => "" }
  s.author              = "Smart AdServer"
  s.platforms           = { :ios => '12.0', :tvos => '12.0' }

  s.source              = { :git => "git@gitlab.com:smartadserver/iOSKit-Releases.git" }
  s.vendored_framework  = "SCSCoreKit/#{s.version}/SCSCoreKit.xcframework"
end
