require 'digest/sha1'

module Debitech
  class Mac
    def self.build(data)
      Digest::SHA1.hexdigest(data.map { |s| s.to_s + "&" }.join).upcase
    end
  end
end
