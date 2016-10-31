Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "MemoryTextField"
s.summary = "AOMemoryTextField provide autocomplete to a UITextField."
s.requires_arc = true

# 2
s.version = "0.1.1"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "AlvaroOlave" => "alvaro.olave.baneres@gmail.com" }

# 5 - Replace this URL with your own Github page's URL (from the address bar)
s.homepage = "https://github.com/AlvaroOlave/MemoryTextField"


# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/AlvaroOlave/MemoryTextField.git", :tag => "#{s.version}"}


# 7
s.framework = 'SystemConfiguration'


# 8
s.source_files = 'AOMemoryTextField/*.{h,m}'

end
