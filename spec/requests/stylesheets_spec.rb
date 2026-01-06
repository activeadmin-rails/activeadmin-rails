require 'rails_helper'

RSpec.describe "Stylesheets", type: :request do

  begin
    require "sprockets"
    sprockets_available = true
  rescue LoadError
    sprockets_available = false
  end

  let(:css) do
    assets = Rails.application.assets
    assets.find_asset("active_admin.css")
  end
  
  it "should successfully render the scss stylesheets using sprockets", skip: !sprockets_available do
    expect(css).to_not eq nil
  end
  
  it "should not have any syntax errors", skip: !sprockets_available do
    expect(css.to_s).to_not include("Syntax error:")
  end

end
