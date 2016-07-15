module ActionsHelper
  def find_or_create_action(content)
    a = Action.find_by_content(content.downcase)
    unless a
      params[:action] = {content: content.downcase}
      a = Action.new(action_params)
    end

    if a.save
      return a
    else
        a.errors.full_messages.each do |message|
        flash[:danger] = message;
      end
      return nil
    end
  end  

  private

    def action_params
      params.require(:action).permit(:content)
    end
end