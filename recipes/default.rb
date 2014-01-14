#
# Author:: Didier Bathily (<bathily@njin.fr>)
# Cookbook Name:: play2
# Recipe:: default
#
# Copyright 2013, njin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

chef_gem "rubyzip" do
end
require 'zip'

play2Home 		= node.play2.home
destinationName = "play-#{node.play2.version}"
zipName 		= destinationName+".zip"
destinationPath = play2Home+"/"+destinationName 
archiveFile		= play2Home+"/"+zipName

unless File.directory? destinationPath
  directory play2Home do
    action :create
  end

  #Download
  remote_file "#{archiveFile}" do
    source node.play2.url+node.play2.version+"/#{zipName}"
    checksum node.play2.checksum
  end

  ruby_block "install" do
    block do
      #Unzip
      Zip::File.open(archiveFile) { |zip_file|
        zip_file.each { |f|
          unless f.directory?
            f_path=::File.join(play2Home, f.name)
            FileUtils.mkdir_p(::File.dirname(f_path))
            zip_file.extract(f, f_path) {true}
          end
        }
      }

      FileUtils.chmod "+x", "#{destinationPath}/play"
      FileUtils.chmod "+x", "#{destinationPath}/framework/build"
      FileUtils.chmod "+x", "#{destinationPath}/framework/build.bat"
      FileUtils.chmod "+x", "#{destinationPath}/framework/clean"
      FileUtils.chmod "+x", "#{destinationPath}/framework/cleanEverything"
      FileUtils.chmod "+x", "#{destinationPath}/framework/package"
      FileUtils.chmod "+x", "#{destinationPath}/framework/runtests"
      
      #Link
      FileUtils.ln_sf "#{destinationPath}/play", "/usr/bin/play"

      #Clean
      FileUtils.rm archiveFile
    end
  end
end
