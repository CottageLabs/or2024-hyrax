class Ability
  include Hydra::Ability
  
  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    return unless current_user.admin?

    can :manage, Role
    can :manage, ::User
    can :create, [::Dataset]
  end
end
