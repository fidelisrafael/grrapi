class Origin < ActiveRecord::Base
  belongs_to :originable, polymorphic: true

  validates :originable_id, presence: true
  validates :originable_type, presence: true

  validates_presence_of :ip, :provider

  validates :provider, presence: true, inclusion: Application::Config.authentication_providers
end
