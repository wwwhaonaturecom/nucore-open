class JxmlHolidaysController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  layout "two_column"
  before_action { @active_tab = "global_settings" }

  def index
    @jxml_holidays = JxmlHoliday.current_and_upcoming.order(:date)
  end

  def new
  end

  def create
    @jxml_holiday.date = parse_usa_date(jxml_holiday_params[:date])

    if @jxml_holiday.save
      redirect_to jxml_holidays_path, notice: t("jxml_holidays.create.success")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @jxml_holiday.update(date: parse_usa_date(jxml_holiday_params[:date]))
      redirect_to jxml_holidays_path, notice: t("jxml_holidays.update.success")
    else
      render :edit
    end
  end

  def destroy
    @jxml_holiday.destroy
    redirect_to jxml_holidays_path, notice: t("jxml_holidays.destroy.success")
  end

  private

  def jxml_holiday_params
    params.require(:jxml_holiday).permit(:date)
  end

end
