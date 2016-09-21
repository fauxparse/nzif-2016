class Admin::ReportsController < ApplicationController
  def accounts
    @report = AccountingReport.new(festival)

    respond_to do |format|
      format.csv do
        send_data @report.to_csv, filename: @report.filename
      end
    end
  end
end
