
Maven Central Bundler
=====================

Takes a POM, a binary JAR, a sources JAR, an optional javadoc JAR, and
generates from them a bundle which can be uploaded to Maven Central, as
instructed in here:

  https://docs.sonatype.org/display/Repository/Sonatype+OSS+Maven+Repository+Usage+Guide
  https://docs.sonatype.org/display/Repository/Uploading+3rd-party+Artifacts+to+The+Central+Repository

For usage instructions, run make_bundle.rb without parameters.

Requires the following command line applications: jar, unzip, gpg

To run the tests, it's helpful to store your GPG password in a file and
pipe it to the tests, to avoid having to retype it. Alternatively you may
use an environment variable. For example:

  echo secret > password.tmp
  cat password.tmp | rspec spec/

  GPG_PASSWORD=secret rspec spec/
