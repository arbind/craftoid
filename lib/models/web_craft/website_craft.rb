class WebsiteCraft < WebCraft
  field :host
  field :keywords

  embedded_in :craft, inverse_of: :website

  alias_attribute :url,     :web_craft_id   # the website's url is used as its :web_craft_id
  alias_attribute :website, :web_craft_id   #

end
