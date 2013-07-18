require 'rubygems'
gem 'highline', '>=1.6.2'
require 'highline/import'
require 'rexml/document'
require 'fileutils'

class Bundler

  attr_writer :password

  def initialize
    @artifacts = {}
  end

  def add_artifact(classifier, path)
    @artifacts[classifier] = path
  end

  def create(target_dir)
    check_artifact_exists(:pom)
    check_artifact_exists(:jar)
    check_artifact_exists(:sources)

    xml = File.read(@artifacts[:pom])
    doc = REXML::Document.new(xml)

    artifact_id = doc.elements['project/artifactId'].text
    version = doc.elements['project/version'].text
    packaging_element = doc.elements['project/packaging']
    packaging = packaging_element ? packaging_element.text : 'jar'
    packaging == 'jar' or raise "Unsupported packaging: #{packaging}"
    base_name = "#{artifact_id}-#{version}"

    Dir.mkdir target_dir

    @artifacts.each_pair { |classifier, path|
      # TODO: support for artifacts of non-jar type
      filename = "#{base_name}-#{classifier}.jar" # default
      filename = "#{base_name}.pom" if classifier == :pom
      filename = "#{base_name}.jar" if classifier == :jar
      result_path = "#{target_dir}/#{filename}"
      FileUtils.cp path, result_path
      sign result_path
    }

    unless @artifacts[:javadoc]
      generate_javadoc target_dir
      sign "#{target_dir}/#{base_name}-javadoc.jar"
    end

    Dir.chdir(target_dir) do
      exec('jar', 'cvf', "#{base_name}-bundle.jar", *Dir.glob("*"))
    end
  end

  def check_artifact_exists(classifier)
    raise "Missing required artifact '#{classifier}': #{@artifacts}" unless @artifacts[classifier]
  end

  def generate_javadoc(target_dir)
    temp = 'javadoc-temp'
    FileUtils.rm_rf temp
    FileUtils.mkdir_p "#{temp}/src/main/java"

    FileUtils.cp @artifacts[:pom], "#{temp}/pom.xml"
    exec('unzip', @artifacts[:sources], '-d', "#{temp}/src/main/java")

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
