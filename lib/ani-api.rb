# frozen_string_literal: true
require 'net/http'
require 'json'

class AniApi
  @@uri = URI("https://graphql.anilist.co/")

  MediaResult = Struct.new(:title, :type)

  def self.media(id)
    query = '''
      query ($id: Int) {
        Media (id: $id) {
          id
          type
          title {
            romaji
            english
            native
          }
        }
      }
    '''

    payload = {
      query: query,
      variables: { id: id }
    }

    http = Net::HTTP.new(@@uri.host, @@uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(@@uri.path, {'Content-Type' => 'application/json'})
    request.body = payload.to_json

    response = http.request(request).body
    data = JSON.parse(response)["data"]["Media"]

    # ==== Fetch Title ====
    en = data["title"]["english"]
    jp = data["title"]["english"]
    title = [en, jp]

    type = data["type"]

    MediaResult.new(title, type)
  end
end

puts AniApi.media(201514).title.en