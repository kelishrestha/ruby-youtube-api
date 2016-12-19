# frozen_string_literal: true
require 'rails_helper'

describe FindHeaderLinks do
  subject(:find_header_links) do
    described_class.new(request_params, request_env, current_page, last_page).call
  end

  let(:api_key) { FactoryGirl.create(:api_key) }
  let(:calendar) { FactoryGirl.create(:calendar) }
  let(:current_page) { 1 }
  let(:rack_request_params) do
    Rack::MockRequest.env_for("/api/v1/calendar/#{calendar.uid}/events",
                              'HTTP_X_API_TOKEN' => api_key.token,
                              'HTTP_HOST' => 'test_host',
                              'CONTENT_TYPE' => 'application/json',
                              'QUERY_STRING' => "page=#{current_page}&per_page=1")
  end
  let(:request) { ActionDispatch::TestRequest.new(rack_request_params) }
  let(:request_params) { request.query_parameters }
  let(:request_env) { request.env }
  let(:last_page) { 5 }

  shared_examples 'Render header links' do |page_details|
    let(:header_link) { '' }

    it "returns header links with #{page_details}" do
      expect(find_header_links).to eq(header_link)
    end
  end

  context 'when current page is' do
    let(:base_url) { "<http://test_host/api/v1/calendar/#{calendar.uid}/events?" }

    context 'first page' do
      include_examples 'Render header links', 'next page as 2 and last page as 5' do
        let(:header_link) do
          "#{base_url}page=2&per_page=1>; rel=\"next\", "\
          "#{base_url}page=5&per_page=1>; rel=\"last\""
        end
      end
    end

    context 'last page' do
      let(:current_page) { 5 }
      include_examples 'Render header links', 'first page as 1 and previous page as 4' do
        let(:header_link) do
          "#{base_url}page=1&per_page=1>; rel=\"first\", "\
          "#{base_url}page=4&per_page=1>; rel=\"prev\""
        end
      end
    end

    context 'second page' do
      let(:current_page) { 2 }
      include_examples 'Render header links', 'first, last, previous as 1 and next as 3' do
        let(:header_link) do
          "#{base_url}page=1&per_page=1>; rel=\"first\", "\
          "#{base_url}page=1&per_page=1>; rel=\"prev\", "\
          "#{base_url}page=3&per_page=1>; rel=\"next\", "\
          "#{base_url}page=5&per_page=1>; rel=\"last\""
        end
      end
    end

    context 'third page' do
      let(:current_page) { 3 }
      include_examples 'Render header links', 'first, previous ,next and last page links' do
        let(:header_link) do
          "#{base_url}page=1&per_page=1>; rel=\"first\", "\
          "#{base_url}page=2&per_page=1>; rel=\"prev\", "\
          "#{base_url}page=4&per_page=1>; rel=\"next\", "\
          "#{base_url}page=5&per_page=1>; rel=\"last\""
        end
      end
    end
  end
end
