class Admin::OperatorsController < Admin::ApplicationController
  def show
    @operator = current_operator
  end
end
