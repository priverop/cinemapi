# frozen_string_literal: true

class ScrapeRunsController < DashboardController
  def index
    if params[:date].present?
      @selected_date = Date.parse(params[:date])
      @scrape_runs = ScrapeRun.includes(:theater).on_date(@selected_date).recent
    else
      @days = ScrapeRun.daily_summaries
    end
  end

  def show
    @scrape_run = ScrapeRun.includes(:theater, :scrape_failures).find(params[:id])
  end

  def export_failures_by_date
    date = Date.parse(params[:date])
    send_data JSON.pretty_generate(ScrapeRun.failures_on(date)),
              filename: "failures_#{date.strftime("%Y-%m-%d")}.json",
              type: "application/json",
              disposition: "attachment"
  end
end
