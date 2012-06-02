class Admin::StatisticsController < Admin::BaseController
  before_filter :check_engineer_rights
  
  def index
    redirect_to :action => 'customers_statistics'
  end

  def customers_statistics
    get_statistics_for 'customers'
  end

  def engineers_statistics
    @engineers = Engineer.find(:all)
  end

  def users_statistics
    # get_statistics_for 'users'
    @companies = Company.find(:all)
    if params[:company_id]
      @company = Company.find(params[:company_id])
      @users = @company.employee_stats
    else
      @company = Company.find(:first)
      @users = @company.employee_stats
    end
  end

  protected
  def get_statistics_for(people)
#    unless params[:page].nil?
#      eval "@#{people} = #{Inflector.classify(people)}.statistics((params[:page].to_i-1)*params[:limit].to_i, params[:limit].to_i)"
#    else
      eval "@#{people} = #{Inflector.classify(people)}.statistics"
#    end
#    eval "@#{people}_count = #{Inflector.classify(people)}.count"
#    @page = params[:page].to_i || 1
  end
end
