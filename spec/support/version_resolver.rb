class VersionResolver
  class Empty
    def fit?(other)
      false
    end
  end

  class Version < Struct.new(:version, :op)
    def fit?(other)
      other.send(op || '==', version)
    end
  end

  class Range < Struct.new(:version1, :version2)
    def fit?(other)
      other > version1 && other < version2
    end
  end

  REGEXP = /([><=]{0,2})(\d+\.\d+\.\d+)/

  attr_reader :server_version

  def initialize(version = nil)
    @server_version = build_version(version || get_server_version)
  end

  def fit?(tag)
    tag = parse_tag(tag)
    tag.fit?(server_version)
  end

  private

  def build_version(v)
    ::Gem::Version.new(v)
  end

  def get_server_version
    Influxdb::Api.client.version.to_s(:mini)
  end

  def parse_tag(tag)
    tags = tag.split(?-)

    if tags.size > 1
      Range.new(build_version(tags[0]), build_version(tags[1]))
    else
      if m = REGEXP.match(tags[0])
        Version.new(build_version(m[2]), m[1].empty? ? nil : m[1])
      else
        Empty.new
      end
    end
  end
end
