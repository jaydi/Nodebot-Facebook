class Ability
  include CanCan::Ability

  def initialize(user)
    can :create, Message
    can :read, Message

    if user
      can :manage, :all if user.has_role?(:admin)
      can :reply, Message, id: Message.with_role(:receiver, user).pluck(:id)
      can :destroy, Message, id: Message.with_role(:receiver, user).pluck(:id)
    end
  end
end