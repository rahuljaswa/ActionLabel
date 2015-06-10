#
# Be sure to run `pod lib lint ActionLabel.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ActionLabel"
  s.version          = "1.0.0"
  s.summary          = "A label that allows blocks to be registered over character ranges."
  s.homepage         = "http://rahuljaswa.com"
  s.license          = 'COMMERCIAL'
  s.author           = { "Rahul Jaswa" => "rahul.jaswa@gmail.com" }
  s.source           = { :git => "https://github.com/rahuljaswa/ActionLabel.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'ActionLabel' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
