# Q.V. the initial comment in spec/integration/files_spec.rb
#
# Missing features:
# * dependencies
# * before/after scripts

require 'fileutils'
require 'tmpdir'

describe 'FPM::Package::Test' do
  # This is to get access to the 'test' FPM type in the FPM executable.
  before(:all) {
    @dir = `pwd`.chomp
    @includedir = File.join(@dir,'spec/lib')
  }

  # Do all of our work within a temp directory
  let(:tempdir) { Dir.mktmpdir }
  before(:each) { Dir.chdir tempdir }
  after(:each) {
    Dir.chdir @dir
    FileUtils.remove_entry_secure tempdir
  }

  # FIXME: 2>/dev/null is to suppress a Gem::Specification complaint about JSON.
  # After 'bundle install', Ruby 2.2 has JSON 1.8.3 and 1.8.1 (default) installed
  # and something gets confused because both are sufficient for JSON >= 1.7.7
  # You can disable it by setting the envvar VERBOSE=1
  def execute(cmd)
    cmd.unshift "ruby -I#{@includedir} -rfpm/package/test `which fpm`"
    cmd.push '2>/dev/null' unless ENV['VERBOSE'] && ENV['VERBOSE'] != '0'
    return eval `#{cmd.join(' ')}`# 
  end

  def verify(name, metadata={}, contents={})
    expect(File).to exist(name)
    expect(File).to exist(File.join(name, 'META.json'))
    expect(JSON.parse(IO.read(File.join(name, 'META.json')))).to eq(metadata)
    if contents.empty?
      expect(Dir[File.join(name, 'contents/*')].empty?).to be(true)
    else
      expect(true).to be(false)
    end
  end

  it "creates an empty package" do
    execute([
      '--name foo',
      '--version 0.0.1',
      '-s empty',
      '-t test',
    ])

    verify('foo.test', {
      'name' => 'foo',
      'version' => '0.0.1',
      'requires' => [],
    })
  end

  it "creates an empty package with dependencies" do
    execute([
      '--name foo',
      '--version 0.0.2',
      '--depends baz',
      '--depends bar',
      '-s empty',
      '-t test',
    ])

    verify('foo.test', {
      'name' => 'foo',
      'version' => '0.0.2',
      'requires' => [ 'bar', 'baz' ],
    })
  end
end
