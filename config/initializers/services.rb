require "gds_api/publishing_api_v2"

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find("publishing-api"),
      disable_cache: true,
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
      timeout: 30,
    )
  end
end
