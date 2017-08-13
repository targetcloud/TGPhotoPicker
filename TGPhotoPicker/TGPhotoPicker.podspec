Pod::Spec.new do |s|
s.name         = "TGPhotoPicker"
s.version      = "0.0.5"
s.summary      = "the best photo picker plugin in swift"
s.homepage     = "https://github.com/targetcloud/TGPhotoPicker"
s.license      = "MIT"
s.author       = { "targetcloud" => "targetcloud@163.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/targetcloud/TGPhotoPicker.git", :tag => s.version }
s.source_files  = "TGPhotoPicker/TGPhotoPicker/TGPhotoPicker/**/*.{swift,h,m}"
s.resources     = "TGPhotoPicker/TGPhotoPicker/TGPhotoPicker/TGPhotoPicker.bundle"
s.requires_arc = true
end
