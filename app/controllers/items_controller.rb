class ItemsController < ApplicationController
  def index
    @items = Item.paginate(:all, :order => 'no', :page => params[:page])
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new
    update_and_redirect('new')
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    update_and_redirect('edit')
  end

  protected
  def update_and_redirect(form)
    if @item.update_attributes(params[:item]) then
      if params[:commit] =~ /nouveau/i then
        redirect_to :action => :new
      else
        redirect_to :action => :index
      end
    else
      render :action => form
    end
  end
end
