class UsersController < Devise::RegistrationsController
  skip_before_action :authenticate_user!, only: [:show_by_name]

  def show_by_name
    begin
      @user = User.where(is_partner: true, name: params[:name]).first
      raise ActiveRecord::RecordNotFound unless @user
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path
    end
  end

  def new
    super
  end

  def create
    @user = User.new(create_params)

    unless User.where(email: @user.email).count == 0
      redirect_to new_user_registration_path, flash: {error: "중복된 이메일입니다."}
      return
    end

    unless @user.password.length > 5
      redirect_to new_user_registration_path, flash: {error: "비밀번호는 6자 이상이어야 합니다."}
      return
    end

    unless @user.password == create_params[:password_confirmation]
      redirect_to new_user_registration_path, flash: {error: "비밀번호가 일치하지 않습니다."}
      return
    end

    super
  end

  def edit
  end

  def update
    attrs_to_update = {}

    if @user.profile_pic.blank? and update_params[:profile].blank?
      redirect_to edit_user_registration_path, flash: {error: "프로필 이미지를 입력해주세요."}
      return
    end

    if update_params[:profile].present?
      attrs_to_update[:profile_pic] = upload_profile(update_params[:profile])
    end

    if @user.name.blank? and update_params[:name].blank?
      redirect_to edit_user_registration_path, flash: {error: "닉네임을 입력해주세요."}
      return
    end

    new_name = update_params[:name].gsub(" ", "")

    if new_name.present? and @user.name != new_name
      if User.find_by_name(new_name).present?
        redirect_to edit_user_registration_path, flash: {error: "이미 존재하는 닉네임입니다."}
        return
      else
        attrs_to_update[:name] = new_name
      end
    end

    if @user.update_attributes(attrs_to_update)
      if @user.messenger_paired?
        redirect_to messages_path
      else
        redirect_to users_pair_path
      end
    else
      redirect_to edit_user_registration_path, flash: {error: "계정 업데이트에 실패했습니다: " + @user.errors.messages.to_s}
    end
  end

  def pair
    @user = current_user
  end

  def show_agreements
    @user = User.find(params[:id])
    if @user.agreements_accepted?
      redirect_to payment_path(id: params[:pending_payment_id], vendor: params[:vendor])
      return
    end

    @pending_payment_id = params[:pending_payment_id]
    @vendor = params[:vendor]
  end

  def accept_agreements
    @user = User.find(params[:id])
    if params[:terms_accepted] and params[:privacy_accepted]
      @user.update_attributes({agreements_accepted: true})
      redirect_to payment_path(id: params[:pending_payment_id])
    else
      redirect_to users_agreements_path, flash: {error: "모든 항목에 동의해주셔야 합니다."}
    end
  end

  private

  def create_params
    @create_params ||= params.require(:user).permit([:email, :password, :password_confirmation]).merge({partner_agreements_accepted: true})
  end

  def update_params
    @update_params ||= params.require(:user).permit([:profile, :name])
  end

  def upload_profile(profile_dispatch)
    return profile_dispatch if Rails.env.test?
    res = Cloudinary::Uploader.upload(profile_dispatch.tempfile.path, crop: :fill, width: 256, height: 256)
    res["secure_url"]
  end

end