#
# Be sure to run `pod lib lint Task.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Task'
  s.version          = '0.1.0'
  s.summary          = 'A task encapsulates async code in a pure way.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Tasks are similar to promises, but they have to be executed explicitly. This fact makes them pure, and allows to delay execution until needed.
                       DESC

  s.homepage         = 'http://gitlab.treenovum-servic.es/iOS/Task'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JM. Sánchez' => 'josema@treenovum.es' }
  s.source           = { :git => 'git@gitlab.treenovum-servic.es:iOS/Task.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Task/Classes/**/*'

end
