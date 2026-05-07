module SystemHelpers
  def ensure_js_is_ready
    expect(page).to have_css('[data-js-loaded-value="true"]')
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
end
