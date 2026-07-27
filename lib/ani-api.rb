require 'net/http'
require 'json'

class AniApi
  API_URI = URI("https://graphql.anilist.co/").freeze
  @rate_limit = 90

  attr_reader :rate_limit
  def self.media(id)
    query = <<~GRAPHQL
      query ($id: Int) {
        Media (id: $id) {
          id
          type
          format
          episodes
          duration
          chapters
          volumes
          genres
          averageScore
          title {
            romaji
            english
            native
          }
          description
          seasonYear
          startDate {
            day, month, year
          }
          endDate {
            day, month, year
          }
          coverImage {
            large, medium          
          }         
        }
      }
    GRAPHQL

    response = make_request(query, { id: id })
    @rate_limit = response['X-RateLimit-Remaining'].to_i

    JSON.parse(response.body)["data"]["Media"].compact
  end

  def self.search(title)
    query = <<~GRAPHQL
      query ($search: String) {
        Page (perPage: 5) {
          media (search: $search) {
            id
            type
          }
        }
      }
    GRAPHQL

    response = make_request(query, { search: title })
    data = JSON.parse(response.body)["data"]["Page"]["media"]
    @rate_limit = response['X-RateLimit-Remaining'].to_i

    data.map { |entry| entry }
  end

  private

  def self.make_request(query, vars)
    payload = {
      query: query,
      variables: vars
    }

    http = Net::HTTP.new(API_URI.host, API_URI.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(API_URI.path, {'Content-Type' => 'application/json'})
    request.body = payload.to_json

    http.request(request)
  end

  def self.rate_limit_remaining
    @rate_limit
  end
end