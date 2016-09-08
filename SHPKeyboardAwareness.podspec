Pod::Spec.new do |s|
  s.name             = "SHPKeyboardAwareness"
  s.version          = "2.4.0"
  s.summary          = "Handle and avoid the keyboard obstructing your views in a very easy and robust way."
  s.description      = "Get notified when you need to move your text-field / -view.
                        Does not require overriding anything. All you need to do is subscribe to a signal
                        and you get an offset with which you need to offset your view. Requires Reactive Cocoa."
  s.homepage         = "https://github.com/shapehq/SHPKeyboardAwareness"
  s.license          = 'MIT'
  s.author           = { "Philip Bruce" => "philip@shape.dk" }
  s.source           = { :git => "https://github.com/shapehq/SHPKeyboardAwareness.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Source/**/*.{h,m}'

  s.public_header_files = 'Source/SHPKeyboardAwareness.h', 'Source/NSObject+SHPKeyboardAwareness.h', 'Source/SHPKeyboardEvent.h', 'Source/SHPKeyboardAwarenessClient.h'
  s.frameworks = 'UIKit'
  s.dependency 'ReactiveCocoa', '~> 4.2.0'
end
