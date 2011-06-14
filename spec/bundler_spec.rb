require 'bundler'
require 'fileutils'

describe Bundler, "given no javadocs," do

  before(:all) do
    @testdata = 'test-data'
    @sandbox = 'test-sandbox'
    FileUtils.rm_rf @sandbox

    bundler = Bundler.new
    bundler.set_options :pom => @testdata+'/annotations-pom.xml',
                        :jar => @testdata+'/annotations.jar',
                        :sources => @testdata+'/src_annotations.zip',
                        :javadoc => false
    bundler.create(@sandbox)
  end

  it "renames POM" do
    File.file?(@sandbox+"/pom.xml").should == true
  end

  it "renames JAR" do
    File.file?(@sandbox+"/annotations-9.0.4.jar").should == true
  end

  it "renames sources JAR" do
    File.file?(@sandbox+"/annotations-9.0.4-sources.jar").should == true
  end

  it "creates javadoc JAR" do
    File.file?(@sandbox+"/annotations-9.0.4-javadoc.jar").should == true
  end

  it "signs all artifacts" do
    File.file?(@sandbox+"/annotations-9.0.4.pom.asc").should == true
    File.file?(@sandbox+"/annotations-9.0.4.jar.asc").should == true
    File.file?(@sandbox+"/annotations-9.0.4-sources.jar.asc").should == true
    File.file?(@sandbox+"/annotations-9.0.4-javadoc.jar.asc").should == true
  end

  it "bundles the generated artifacts together" do
    File.file?(@sandbox+"/annotations-9.0.4-bundle.jar").should == true
  end
end
