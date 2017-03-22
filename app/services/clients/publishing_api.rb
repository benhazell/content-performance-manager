require 'gds_api/publishing_api_v2'

module Clients
  class PublishingAPI
    attr_accessor :publishing_api, :per_page

    def initialize
      @publishing_api = GdsApi::PublishingApiV2.new(
        Plek.new.find('publishing-api'),
        disable_cache: true,
        bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
      )
      @per_page = 100
    end

    def find_each(fields, options = {})
      current_page = 1
      query = build_base_query(fields, options)

      loop do
        query = build_current_page_query(query, current_page)
        response = publishing_api.get_content_items(query)
        response["results"].each do |result|
          if options[:expand_links]
            result[:expanded_links] = expand_links(result["content_id"])
          end
          yield result.symbolize_keys
        end

        break if last_page?(response)
        current_page = response["current_page"] + 1
      end
    end

    def expand_links(content_id, include_drafts: false)
      response = publishing_api.get_expanded_links(content_id, with_drafts: include_drafts)
      response["expanded_links"].deep_symbolize_keys
    end

  private

    def build_base_query(fields, options)
      {
        document_type: options[:document_type],
        order: options[:order] || '-public_updated_at',
        q: options[:q] || '',
        states: ['published'],
        per_page: per_page,
        fields: fields || []
      }
    end

    def build_current_page_query(query, page)
      query[:page] = page
      query
    end

    def last_page?(response)
      response["results"].empty? || response["pages"] == response["current_page"]
    end
  end
end
