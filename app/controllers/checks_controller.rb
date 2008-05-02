class ChecksController < ApplicationController
  def index
    case params[:order]
    when /\bdate\b/
      @order = 'date DESC'
    else
      @order = 'no DESC'
    end

    @checks = Check.find(:all, :order => @order)
  end

  def edit
    @bank_accounts = Account.find(:all, :conditions => ['no BETWEEN 1001 AND 1049'], :order => 'no')
    @check = Check.find(params[:id]) rescue Check.new
    return unless request.post?

    Check.transaction do
      case
      when params[:destroy]
        @check.destroy
      else
        @check.update_attributes!(params[:check])
        (params[:distribution] || {}).each do |id, data|
          @distribution = @check.distributions.find_by_id(id) || @check.distributions.build
          @distribution.attributes = data
          @distribution.save!
        end
      end

      @check.transfer! if params[:transfer]
    end

    redirect_to(:action => :index)

    rescue UnbalancedCheckException
      flash_failure :now, "Ce chèque n'est pas balancé.  Il ne peut pas être transféré."

    rescue ActiveRecord::RecordInvalid
      # NOP - we let the view handle it
  end

  def add_line
    render(:nothing => true) if params[:nline][:no].blank?
    @distribution = CheckDistribution.new(params[:nline])
    @line_count = 1 + params[:line_count].to_i
    render :layout => false
  end

  def delete_line
    @check = Check.find(params[:check_id])
    @distribution = @check.distributions.find(params[:id])
    @distribution.destroy
    self.count_lines!
    @index = params[:index]
  end

  def count_lines!
    return @check.lines.count if @check.new_record?
    count = CheckDistribution.maximum(:id, :conditions => ['check_id = ?', @check.id])
    @line_count = count.to_i rescue 0
  end
end
