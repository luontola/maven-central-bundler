require 'rubygems'
gem 'highline', '>=1.6.2'
require 'highline/import'
require 'rexml/document'
require 'fileutils'

class Bundler

  attr_writer :password

  def set_options(options)
    @pom_file = options[:pom]
    @jar_file = options[:jar]
    @sources_file = options[:sources]
    @javadoc_file = options[:javadoc]

    xml = File.read(options[:pom])
    doc = REXML::Document.new(xml)

    @artifact_id = doc.elements['project/artifactId'].text
    @version = doc.elements['project/version'].text
    packaging_element = doc.elements['project/packaging']
    @packaging = packaging_element ? packaging_element.text : 'jar'
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
      exec('jar', 'cvf', "#{@final_name}-bundle.jar", *Dir.glob("*"))
    end
  end

  def generate_javadoc(target_dir)
    temp = 'javadoc-temp'
    FileUtils.rm_rf temp
    FileUtils.mkdir_p "#{temp}/src/main/java"

    FileUtils.cp @pom_file, "#{temp}/pom.xml"
    exec('unzip', @sources_file, '-d', "#{temp}/src/main/java")

    Dir.chdir(temp) do
      exec("mvn", "javadoc:jar")
    end
    FileUtils.cp Dir.glob("#{temp}/target/*-javadoc.jar"), target_dir

    FileUtils.rm_rf temp
  end

  def sign(file, output_file=false)
    @password = get_password("\nEnter GPG password:") unless @password
    command = ['gpg', '--passphrase', @password, '--armor', '--detach-sign']
    command.push '--output', output_file if output_file
    command.push file
    exec(*command)
  end

  def get_password(prompt="Enter Password")
    ask(prompt) { |q| q.echo = false }
  end

  def exec(*command)
    system(*command) or raise "Command failed: #{command}"
  end
end
