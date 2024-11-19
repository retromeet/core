# frozen_string_literal: true

require_relative "../../../test_helper"

describe API::Authenticated::Profile do
  include RackHelper
  before(:all) do
    @login = "foo@retromeet.social"
    @password = "bogus123"
    @account = create(:account, email: @login, password: @password, profile: { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) })
  end

  describe "get /profile/info" do
    before do
      @auth = login(login: @login, password: @password)
    end

    it "has the information expected" do
      expected_response = { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) }
      authorized_get @auth, "/api/profile/info"

      assert_predicate last_response, :ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end

  describe "get /profile/complete" do
    before do
      @endpoint = "/api/profile/complete"
      @auth = login(login: @login, password: @password)
    end

    it "gets the user information" do
      profile = @account.profile
      expected_response = {
        about_me: profile.about_me,
        created_at: profile.created_at.iso8601,
        birth_date: profile.birth_date.to_s,
        genders: profile.genders,
        orientations: profile.orientations,
        languages: profile.languages,
        relationship_status: profile.relationship_status,
        relationship_type: profile.relationship_type,
        tobacco: profile.tobacco,
        marijuana: profile.marijuana,
        alcohol: profile.alcohol,
        other_recreational_drugs: profile.other_recreational_drugs,
        pets: profile.pets,
        wants_pets: profile.wants_pets,
        kids: profile.kids,
        wants_kids: profile.wants_kids,
        religion: profile.religion,
        religion_importance: profile.religion_importance,
        display_name: profile.display_name,
        location_display_name: profile.location.display_name.transform_keys(&:to_sym)
      }
      authorized_get @auth, @endpoint

      assert_predicate last_response, :ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end

  describe "post /profile/location" do
    before do
      @endpoint = "/api/profile/location"
      @auth = login(login: @login, password: @password)
    end

    it "sends a non-sensical location and gets no results back" do
      body = {
        location: "askdjlasjdklasjdlasjdljasdlk",
        osm_id: 0
      }

      stub_request(:get, "https://photon.komoot.io/api?q=askdjlasjdklasjdlasjdljasdlk&layer=state&layer=county&layer=city&layer=district&limit=10&lang=en")
        .to_return(webfixture_json_file("photon.no_results"))

      authorized_post @auth, @endpoint, body.to_json

      assert_predicate last_response, :unprocessable?
    end

    it "sends a location too generic and gets too many results back but it is correctly filtered by osm_id" do
      body = {
        location: "Méier",
        osm_id: 5_520_336
      }

      stub_request(:get, "https://photon.komoot.io/api?q=M%C3%A9ier&layer=state&layer=county&layer=city&layer=district&limit=10&lang=en")
        .to_return(webfixture_json_file("photon.meier"))

      assert_difference "Location.count", 1 do
        authorized_post @auth, @endpoint, body.to_json
      end

      assert_predicate last_response, :ok?
    end

    it "sends a location that has exactly one result and updates the location for the user" do
      body = {
        location: "Méier, Rio de Janeiro, Região Metropolitana do Rio de Janeiro, Brazil",
        osm_id: 5_520_336
      }

      stub_request(:get, "https://photon.komoot.io/api?q=M%C3%A9ier%2C+Rio+de+Janeiro%2C+Regi%C3%A3o+Metropolitana+do+Rio+de+Janeiro%2C+Brazil&layer=state&layer=county&layer=city&layer=district&limit=10&lang=en")
        .to_return(webfixture_json_file("photon.meier_single_result"))

      assert_difference "Location.count", 1 do
        authorized_post @auth, @endpoint, body.to_json
      end

      assert_predicate last_response, :ok?
    end
  end

  describe "post /profile/complete" do
    before do
      @endpoint = "/api/profile/complete"
      @auth = login(login: @login, password: @password)
    end

    it "gets a bad request if there's no body" do
      authorized_post @auth, @endpoint, {}.to_json

      assert_predicate last_response, :bad_request?
    end

    it "posts with the same information as the user account" do
      profile = @account.profile
      body = {
        about_me: profile.about_me,
        genders: profile.genders,
        orientations: profile.orientations,
        languages: profile.languages,
        relationship_status: profile.relationship_status,
        relationship_type: profile.relationship_type,
        tobacco: profile.tobacco,
        marijuana: profile.marijuana,
        alcohol: profile.alcohol,
        other_recreational_drugs: profile.other_recreational_drugs,
        pets: profile.pets,
        wants_pets: profile.wants_pets,
        kids: profile.kids,
        wants_kids: profile.wants_kids,
        religion: profile.religion,
        religion_importance: profile.religion_importance,
        display_name: profile.display_name
      }
      authorized_post @auth, @endpoint, body.to_json

      expected_response = body

      assert_predicate last_response, :ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
    it "sets all nullable fields to null" do
      body = {
        about_me: nil,
        genders: nil,
        orientations: nil,
        languages: nil,
        relationship_status: nil,
        relationship_type: nil,
        tobacco: nil,
        marijuana: nil,
        alcohol: nil,
        other_recreational_drugs: nil,
        pets: nil,
        wants_pets: nil,
        kids: nil,
        wants_kids: nil,
        religion: nil,
        religion_importance: nil
      }
      authorized_post @auth, @endpoint, body.to_json

      expected_response = body

      assert_predicate last_response, :ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end

    ###
    # This is a bit of meta programming to guarantee that the all the values the database supports are correctly declared in the endpoint documentation
    # We iterate through all the params that the endpoint supports and for each we get possible values in the database and update it
    post_endpoint = API::Authenticated::Profile.routes.find { |v| v.request_method == "POST" && v.path == "/profile/complete(.:format)" }
    post_endpoint.params.each_key do |param|
      next if %w[text date].include? Profile.db_schema[param.to_sym][:db_type]

      if Profile.db_schema[param.to_sym][:db_type].ends_with?("[]")
        enum_type = Database.connection[:pg_type].where(typname: "_#{Profile.db_schema[param.to_sym][:db_type][..-3]}").get(:typelem)
        enum_values = Database.connection.instance_variable_get(:@enum_labels)[enum_type].map { |v| [v] }
      else
        enum_values = Profile.db_schema[param.to_sym][:enum_values]
      end
      next unless enum_values

      sub_tests = enum_values.map do |value|
        %(it "test that the value #{value.is_a?(Array) ? value[0] : value} is accepted" do
          body = {
            #{param}: #{value.is_a?(Array) ? value : "\"#{value}\""}
          }

          authorized_post @auth, @endpoint, body.to_json

          expected_response = body

          assert_predicate last_response, :ok?
          assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
        end
        )
      end
      eval <<-RUBY, binding, __FILE__, __LINE__ + 1 # rubocop:disable Security/Eval
        describe "#{param} parameter" do # describe "bogus parameter"
          #{sub_tests.join("\n")} # it "test that the value bogus1 is accepted" do ...
        end
      RUBY
    end
  end

  describe "get /profile/:id/complete" do
    before do
      @endpoint = "/api/profile/%<id>s/complete"
      @auth = login(login: @login, password: @password)
    end

    make_my_diffs_pretty!
    it "gets the user information" do
      profile = @account.profile
      expected_response = {
        account_id: @account.id,
        about_me: profile.about_me,
        genders: profile.genders,
        orientations: profile.orientations,
        languages: profile.languages,
        relationship_status: profile.relationship_status,
        relationship_type: profile.relationship_type,
        tobacco: profile.tobacco,
        marijuana: profile.marijuana,
        alcohol: profile.alcohol,
        other_recreational_drugs: profile.other_recreational_drugs,
        pets: profile.pets,
        wants_pets: profile.wants_pets,
        kids: profile.kids,
        wants_kids: profile.wants_kids,
        religion: profile.religion,
        religion_importance: profile.religion_importance,
        display_name: profile.display_name,
        location_display_name: profile.location.display_name.transform_keys(&:to_sym),
        location_distance: nil, # TODO: I think this should display the distance to the logged in user
        age: 39 # TODO: calculate this so that this test don't breaks when the profile ages
      }
      authorized_get @auth, format(@endpoint, id: @account.id)

      assert_predicate last_response, :ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
end
