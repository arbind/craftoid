class NilClass
  def looks_like_url?() false end

  def urlify!() self end

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

end

