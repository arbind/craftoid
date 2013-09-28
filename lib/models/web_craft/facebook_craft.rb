class FacebookCraft < WebCraft
  field :likes
  field :talking_about_count

  field :first_name
  field :last_name
  field :gender
  field :locale
  field :is_published
  field :website
  field :about
  field :parking
  field :public_transit
  field :payment_options
  field :culinary_team
  field :general_manager
  field :restaurant_services
  field :restaurant_specialties
  field :category
  field :cover

  embedded_in :craft, inverse_of: :facebook

  alias_attribute :facebook_id, :web_craft_id
  alias_attribute :about, :description
  alias_attribute :link, :href  # facebook specifies it href as link=

  def self.provider_key
    'fb'
  end

end
