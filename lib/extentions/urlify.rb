class NilClass
  def looks_like_url?() false end

  def urlify!() self end

  def provider() self end

end

class String
  def looks_like_url?
    !!(self.match /(^https?\:\/\/|^www\.|^\/\/)[^\s<]+|[^\s<]+\.(com|net|org|us|me|co|info|ws|ca|biz|me|cc|tv|asia)[^\s<]*$/)
  end

  def urlify!
    if self.looks_like_url?                                                   # make sure string starts with "http://"
      self.insert(0, 'http:') if self.downcase.match /^\/\//                  # "//mysite.com" is ok
      self.insert(0, 'http://') unless self.downcase.match /^https?\:\/\//    # "HTTPS://mysite.com" is ok
      self.downcase!
    end
    self
  end

  def provider
    return nil unless self.looks_like_url?
    href = "" << self

    u = URI.parse(href.urlify!) rescue nil
    return nil if u.nil? or u.host.nil?

    tokens = u.host.split('.')
    return nil unless tokens.present?
    tokens.slice!(0) if 'www'.eql? tokens[0]
    provider = tokens[0].symbolize # e.g. :facebook or :twitter or :yelp or webpage domain or other
    provider = :website unless [:twitter, :facebook, :yelp, :flickr, :youtube, :instagram, :pinterest].include? provider
    provider
  end

end

