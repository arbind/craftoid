class MaterializeUtil

  def self.obj_hash(clazz, atts_hash)
    obj_hash = {} # the final set of attributes is stored in here
    atts = clazz.fields.keys.reject{|k| k[0].eql? '_'}  # Get mongoid fields for the clazz, but skip _id and _type and _private fields
    atts.reject!{ |k| (atts_hash.has_key?(k) || atts_hash.has_key?(:"#{k}")) ? false : true } # keep only fields that are present in atts_hash
    atts.map{|k| obj_hash[k] = atts_hash[k] || atts_hash[:"#{k}"] } # finally set the field in obj_hash from the value in atts_hash
    obj_hash
  end

end