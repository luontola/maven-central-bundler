require 'rubygems'
gem 'highline', '>=1.6.2'
require 'highline/import'
require 'rexml/document'
require 'fileutils'

class Bundler

  def set_options(options)
    @pom_file = options[:pom]
    @jar_file = options[:jar]
    @sources_file = options[:sources]
    @javadoc_file = options[:javadoc]

    xml = File.read(options[:pom])
    doc = REXML::Document.new(xml)

    @artifact_id = doc.elements['project/artifactId'].text
    @version = doc.elements['project/version'].text
    @packaging = doc.elements['project/packaging'].text
    @packaging == 'jar' or raise "Unsupported packaging: #{@packaging}"
    @final_name = "#{@artifact_id}-#{@version}"
  end

  def create(target_dir)
    Dir.mkdir target_dir
    result_pom = target_dir+"/pom.xml"
    result_jar = target_dir+"/#{@final_name}.jar"
    result_sources = target_dir+"/#{@final_name}-sources.jar"
    result_javadoc = target_dir+"/#{@final_name}-javadoc.jar"

    FileUtils.cp @pom_file, result_pom
    FileUtils.cp @jar_file, result_jar
    FileUtils.cp @sources_file, result_sources
    if @javadoc_file
      FileUtils.cp @javadoc_file, result_javadoc
    else
      generate_javadoc target_dir
    end

    sign result_pom, target_dir+"/#{@final_name}.pom.asc"
    sign result_jar
    sign result_sources
    sign result_javadoc

    Dir.chdir(target_dir) do
      system('jar', 'cvf', "#{@final_name}-bundle.jar", *Dir.glob("*"))
    end
  end

  def generate_javadoc(target_dir)
    temp = 'javadoc-temp'
    FileUtils.rm_rf temp
    FileUtils.mkdir_p "#{temp}/src/main/java"

    FileUtils.cp @pom_file, "#{temp}/pom.xml"
    system('unzip', @sources_file, '-d', "#{temp}/src/main/java")

    Dir.chdir(temp) do
      system("mvn", "javadoc:jar")
    end
    FileUtils.cp Dir.glob("#{temp}/target/*-javadoc.jar"), target_dir

    FileUtils.rm_rf temp
  end

  def sign(file, output_file=false)
    @password = get_password("\nEnter GPG password:") unless @password
    command = ['gpg', '--passphrase', @password, '--armor', '--detach-sign']
    command.push '--output', output_file if output_file
    command.push file
    system(*command)
  end

  def get_password(prompt="Enter Password")
    ask(prompt) { |q| q.echo = false }
  end
end
