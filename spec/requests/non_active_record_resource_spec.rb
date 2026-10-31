require 'rails_helper'

class NonArJob
  include ActiveModel::Model
  attr_accessor :id, :job_class

  def self.all
    [
      new(id: '0b8f6c1e-2c8e-4f5e-9d3a-6f1c2a7b9e01', job_class: 'MailerJob'),
      new(id: '7d2e4a90-1b3c-4d5e-8f6a-0c1d2e3f4a5b', job_class: 'ReportJob')
    ]
  end

  def self.find_by(conditions)
    all.detect { |job| job.id == conditions[:id] }
  end

  def persisted?
    true
  end
end

RSpec.describe 'non-ActiveRecord resource', type: :request do
  include Rails.application.routes.url_helpers

  let(:application) { ActiveAdmin::Application.new }
  let(:namespace) { application.namespace(:root) { |n| n.site_title = nil } }
  let(:page) { Capybara.string(response.body) }

  let(:resource) do
    namespace.register NonArJob do
      actions :index, :show
      config.batch_actions = false

      controller do
        protected

        def scoped_collection
          Kaminari.paginate_array(NonArJob.all)
        end

        def find_resource
          NonArJob.find_by(id: params[:id])
        end
      end
    end
  end

  around do |example|
    with_temp_application(application) do
      load_resources { resource }
      example.call
    end
    namespace.unload!
  end

  it "renders the default index" do
    get resource.route_collection_path
    expect(response).to have_http_status(:ok)
    expect(page).to have_css "a[href='/non_ar_jobs/0b8f6c1e-2c8e-4f5e-9d3a-6f1c2a7b9e01']"
    expect(page).to have_css "a[href='/non_ar_jobs/7d2e4a90-1b3c-4d5e-8f6a-0c1d2e3f4a5b']"
  end

  context "with a custom index" do
    let(:resource) do
      namespace.register NonArJob do
        actions :index
        config.batch_actions = false

        index do
          column :job_class
        end

        controller do
          protected

          def scoped_collection
            Kaminari.paginate_array(NonArJob.all)
          end
        end
      end
    end

    it "renders unsortable columns" do
      get resource.route_collection_path(nil, order: 'job_class_asc', q: { job_class_eq: 'x' })
      expect(response).to have_http_status(:ok)
      expect(page).to have_css 'td.col-job_class', text: 'MailerJob'
      expect(page).not_to have_css 'th.sortable'
    end
  end

  it "renders the default show page" do
    get "/non_ar_jobs/7d2e4a90-1b3c-4d5e-8f6a-0c1d2e3f4a5b"
    expect(response).to have_http_status(:ok)
  end
end
