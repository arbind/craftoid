class WebsiteCraft < WebCraft
  field :host
  field :keywords

  embedded_in :craft

  alias_method :url,     :web_craft_id   # the website's url is used as its :web_craft_id
  alias_method :website, :web_craft_id   # 

end
