Pod::Spec.new do |s|
  s.name         = "HttpClient"
  s.version      = "0.1"
  s.summary      = "This is an example of a cross-platform Swift framework!"
  s.description  = <<-DESC
    Your description here.
  DESC
  s.source       = { :git => "https://github.com/Nang01T2/HttpClient.git", :tag => s.version }
  s.homepage     = "https://github.com/Nang01T2/HttpClient"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = "Nang Nguyen"

  s.swift_version = '5.0'

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "10.0"

  s.source_files  = "Sources/**/*"

  s.dependency 'Moya'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
end
