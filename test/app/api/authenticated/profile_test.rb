# frozen_string_literal: true

require_relative "../../../test_helper"

describe API::Authenticated::Profile do
  include SwaggerHelper::TestMethods
  before(:all) do
    @login = "foo@retromeet.social"
    @password = "bogus123"
    @account = create(:account, email: @login, password: @password, profile: { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) })
    set_oauth_grant_with_token(oauth_grant_with_token(@account))
    @account2 = create(:account)
    @account3 = create(:account)
    @conversation = create(:conversation, profile1: @account.profile, profile2: @account3.profile)
  end

  describe "get /profile/info" do
    before do
      @endpoint = "/api/profile/info"
    end

    it "has the information expected" do
      expected_response = { id: @account.profile.id, display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) }
      authorized_get @endpoint

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      assert_equal expected_response, last_response_json_body
    end
  end

  describe "get /profile/complete" do
    before do
      @endpoint = "/api/profile/complete"
    end

    it "gets the user information" do
      profile = @account.profile
      expected_response = {
        id: profile.id,
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
        location_display_name: profile.location.display_name.transform_keys(&:to_sym),
        age: AgeHelper.age_from_date(profile.birth_date),
        hide_age: profile.hide_age
      }
      authorized_get @endpoint

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      assert_equal expected_response, last_response_json_body
    end
  end

  describe "post /profile/location" do
    before do
      @endpoint = "/api/profile/location"
    end

    it "sends a non-sensical location and gets no results back" do
      body = {
        location: "askdjlasjdklasjdlasjdljasdlk",
        osm_id: 0
      }

      stub_request(:get, "https://photon.komoot.io/api?q=askdjlasjdklasjdlasjdljasdlk&layer=state&layer=county&layer=city&layer=district&limit=10&lang=en")
        .to_return(webfixture_json_file("photon.no_results"))

      authorized_post @endpoint, body.to_json

      assert_predicate last_response, :unprocessable?
      assert_schema_conform(422)
    end

    it "sends a location too generic and gets too many results back but it is correctly filtered by osm_id" do
      body = {
        location: "Méier",
        osm_id: 5_520_336
      }

      stub_request(:get, "https://photon.komoot.io/api?q=M%C3%A9ier&layer=state&layer=county&layer=city&layer=district&limit=10&lang=en")
        .to_return(webfixture_json_file("photon.meier"))

      assert_difference "Location.count", 1 do
        authorized_post @endpoint, body.to_json

        assert_schema_conform(200)
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
        authorized_post @endpoint, body.to_json

        assert_schema_conform(200)
      end

      assert_predicate last_response, :ok?
    end
  end

  describe "post /profile/complete" do
    before do
      @endpoint = "/api/profile/complete"
    end

    it "gets a bad request if there's no body" do
      authorized_post @endpoint, {}.to_json

      assert_predicate last_response, :bad_request?
      assert_schema_conform(400)
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
      authorized_post @endpoint, body.to_json

      expected_response = body

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      assert_equal expected_response, last_response_json_body
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
      authorized_post @endpoint, body.to_json

      expected_response = body

      assert_predicate last_response, :ok?
      # assert_response_schema_confirm(200) # (renatolond, 2024-11-26) since oapi2 has no nullable possibility, this cannot be checked. see if https://github.com/interagent/committee/pull/400 can make this work
      assert_equal expected_response, last_response_json_body
    end

    ###
    # This is a bit of meta programming to guarantee that the all the values the database supports are correctly declared in the endpoint documentation
    # We iterate through all the params that the endpoint supports and for each we get possible values in the database and update it
    post_endpoint = API::Authenticated::Profile.routes.find { |v| v.request_method == "POST" && v.path == "/api/profile/complete(.json)" }
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

          authorized_post @endpoint, body.to_json

          expected_response = body

          assert_predicate last_response, :ok?
          assert_schema_conform(200)
          assert_equal expected_response, last_response_json_body
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
    end

    it "gets the user information" do
      profile = @account.profile
      expected_response = {
        id: @account.profile.id,
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
        age: AgeHelper.age_from_date(profile.birth_date)
      }
      authorized_get format(@endpoint, id: @account.profile.id)

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      assert_equal expected_response, last_response_json_body
    end

    it "gets the user information without age if user requested it" do
      profile = create(:profile, hide_age: true)
      expected_response = {
        id: profile.id,
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
        location_display_name: profile.location.display_name.transform_keys(&:to_sym)
      }
      authorized_get format(@endpoint, id: profile.id)

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      assert_equal expected_response, last_response_json_body
    end

    it "gets the user information_with_picture" do
      profile = create(:profile_with_picture)
      expected_response = {
        id: profile.id,
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
        age: AgeHelper.age_from_date(profile.birth_date),
        picture: ImageUploader::Attacher.from_data(profile.picture.to_h).file.download_url

      }
      authorized_get format(@endpoint, id: profile.id)

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      assert_equal expected_response, last_response_json_body
    end
  end

  describe "post /api/profile/picture" do
    before do
      @endpoint = "/api/profile/picture"
    end

    it "posts a picture and the picture gets saved" do
      authorized_post @endpoint, profile_picture: Rack::Test::UploadedFile.new("test/files/retromeet_128.png")

      assert_predicate last_response, :no_content?
      @account.reload

      assert_predicate @account.profile.picture, :present?
      assert_equal "retromeet_128.png", @account.profile.picture.dig("metadata", "filename")
    end
  end

  describe "post /profile/:id/block" do
    before do
      @endpoint = "/api/profile/%<id>s/block"
    end

    it "blocks a profile" do
      profile = create(:profile)
      assert_difference "ProfileBlock.count", 1 do
        authorized_post format(@endpoint, id: profile.id)
      end

      assert_predicate last_response, :no_content?
    end

    it "gets a 404 for a non existing uuid" do
      authorized_post format(@endpoint, id: "11111111-1111-7111-b111-111111111111")

      assert_predicate last_response, :not_found?
      assert_schema_conform(404)
    end
  end

  describe "delete /profile/:id/block" do
    before do
      @endpoint = "/api/profile/%<id>s/block"
      @target_profile = create(:profile)
      create(:profile_block, profile: @account.profile, target_profile: @target_profile)
    end

    it "unblocks a profile" do
      assert_difference "ProfileBlock.count", -1 do
        authorized_delete format(@endpoint, id: @target_profile.id)
      end

      assert_predicate last_response, :no_content?
    end

    it "gets a 404 for a non existing uuid" do
      authorized_delete format(@endpoint, id: "11111111-1111-7111-b111-111111111111")

      assert_predicate last_response, :not_found?
      assert_schema_conform(404)
    end
  end

  describe "get /profile/:id/conversation" do
    before do
      @endpoint = "/api/profile/%<id>s/conversation"
    end

    it "gets a 404 if there's no conversation between the users" do
      expected_response = {
        error: "NOT_FOUND",
        details: [
          {
            fields: [],
            errors: ["conversation not found"]
          }
        ]
      }

      authorized_get format(@endpoint, id: @account2.profile.id)

      assert_predicate last_response, :not_found?
      assert_schema_conform(404)
      assert_equal expected_response, last_response_json_body
    end

    it "gets a 422 if the user passes its own id" do
      expected_response = {
        error: "PROFILE_IS_THE_SAME",
        details: [
          {
            fields: ["id"],
            errors: ["the requested profile is the user's"]
          }
        ]
      }

      authorized_get format(@endpoint, id: @account.profile.id)

      assert_predicate last_response, :unprocessable?
      assert_schema_conform(422)
      assert_equal expected_response, last_response_json_body
    end

    it "gets the conversation between the logged in user and the profile requested" do
      expected_response = {
        id: @conversation.id,
        created_at: @conversation.created_at.iso8601
      }

      authorized_get format(@endpoint, id: @account3.profile.id)

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      assert_equal expected_response, last_response_json_body
    end
  end
end
