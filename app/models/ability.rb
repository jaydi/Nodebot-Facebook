class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    can :manage, :all if user.has_role?(:admin)
    can :manage, Message, id: Message.with_role(:sender, user).pluck(:id)
    can :read, Message, id: Message.with_role(:receiver, user).pluck(:id)
    can :reply, Message, id: Message.with_role(:receiver, user).pluck(:id)
  end
end