class PropileConfigsController < ApplicationController
  def index
    @propile_configs = PropileConfig.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @propile_configs }
    end
  end

  def show
    @propile_config = PropileConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @propile_config }
    end
  end

  def new
    @propile_config = PropileConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @propile_config }
    end
  end

  def edit
    @propile_config = PropileConfig.find(params[:id])
  end

  def create
    @propile_config = PropileConfig.new(params[:propile_config])

    respond_to do |format|
      if @propile_config.save
        format.html { redirect_to @propile_config, notice: 'Propile config was successfully created.' }
        format.json { render json: @propile_config, status: :created, location: @propile_config }
      else
        format.html { render action: "new" }
        format.json { render json: @propile_config.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @propile_config = PropileConfig.find(params[:id])

    respond_to do |format|
      if @propile_config.update_attributes(params[:propile_config])
        format.html { redirect_to @propile_config, notice: 'Propile config was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @propile_config.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @propile_config = PropileConfig.find(params[:id])
    @propile_config.destroy

    respond_to do |format|
      format.html { redirect_to propile_configs_url }
      format.json { head :no_content }
    end
  end
end
