Pod::Spec.new do |s|
  s.name             = 'Task'
  s.version          = '0.3.2'
  s.summary          = 'A task encapsulates async code in a pure way.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Tasks are similar to promises, but they have to be executed explicitly. This fact makes them pure, and allows to delay execution until needed.
                       DESC

  s.homepage         = 'https://github.com/buscarini/task'

  s.license = "MIT"
  
  s.author           = { 'José Manuel Sánchez' => 'buscarini@gmail.com' }
  s.source           = { :git => 'git@github.com:buscarini/task.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = "10.9"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.source_files  = "Sources", "Sources/**/*.swift"
  
  s.swift_version = '5.3'

  s.dependency 'NonEmpty', '~> 0.3.1'

end
