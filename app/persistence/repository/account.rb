# frozen_string_literal: true

module Persistence
  module Repository
    # Contains database logic around accounts
    module Account
      extend Datasets

      GENDER_VALUES = %w[
        man
        woman
        non_binary
        genderqueer
        genderfluid
        gender_non_conforming
        transgender
        trans_man
        transmasculine
        trans_woman
        transfeminine
        transsexual
        agender
        bigender
        pangender
        two_spirit
        intersex
        androgynous
        questioning
        unsure
      ].freeze

      ORIENTATION_VALUES = %w[
        straight
        bisexual
        heteroflexible
        homoflexible
        gay
        lesbian
        queer
        pansexual
        omnisexual
        abrosexual
        demisexual
        asexual
        greysexual
        reciprosexual
        demiromantic
        aromantic
        greyromantic
        fluid
        fluctuating
        unsure
        questioning
      ].freeze

      LANGUAGE_VALUES = %w[abk aar afr aka sqi amh ara arg hye asm ava ave aym aze bam bak eus bel ben bis bos bre bul mya cat cha che nya zho chu chv cor cos cre hrv ces dan div nld dzo eng epo est ewe fao fij fin fra fry ful gla glg lug kat deu ell kal grn guj hat hau heb her hin hmo hun isl ido ibo ind ina ile iku ipk gle ita jpn jav kan kau kas kaz khm kik kin kir kom kon kor kua kur lao lat lav lim lin lit lub ltz mkd mlg msa mal mlt glv mri mar mah mon nau nav nde nbl ndo nep nor nob nno oci oji ori orm oss pli pus fas pol por pan que ron roh run rus sme smo sag san srd srp sna snd sin slk slv som sot spa sun swa ssw swe tgl tah tgk tam tat tel tha bod tir ton tso tsn tur tuk twi uig ukr urd uzb ven vie vol wln cym wol xho iii yid yor zha zul].freeze

      RELATIONSHIP_TYPE_VALUES = %w[monogamous non_monogamous].freeze

      RELATIONSHIP_STATUS_VALUES = %w[single partnered married].freeze

      FREQUENCY_VALUES = %w[never sometimes often].freeze

      HAVES_OR_HAVE_NOTS_VALUES = %w[have have_not].freeze

      WANTS_VALUES = %w[
        want_more
        do_not_want_more
        want_some
        do_not_want_any
        dont_know
        maybe
      ].freeze

      RELIGION_VALUES = %w[
        agnosticism
        atheism
        buddhism
        candomble
        catholicism
        christianity
        hinduism
        islam
        judaism
        rastafari
        sikh
        spiritism
        umbanda
        other
      ].freeze

      IMPORTANCE_VALUES = %w[
        important not_important do_not_care
      ].freeze

      class << self
        # @param account_id [Integer] An id for an account
        def profile_id_from_account_id(account_id:)
          profiles.where(account_id:).get(:id)
        end

        # Returns profile information for a given account
        #
        # @param id [Integer] An id for a profile, it should be an UUID
        # @return [Hash{Symbol => Object}] A record containing all information about a profile
        def profile_info(id:)
          profiles.left_join(:locations, id: :location_id)
                  .where(Sequel[:profiles][:id] => id)
                  .select_all(:profiles)
                  # TODO: (renatolond, 2024-11-14) Filter the location display name for only the users' language and the fallback one
                  .select_append(Sequel[:locations][:display_name].as(:location_display_name))
                  .first
        end

        # Returns basic profile information for a given account
        #
        # @param id (see .profile_info)
        # @return [Hash{Symbol => Object}] A record containing +profile_id+, +created_at+ and +display_name+
        def basic_profile_info(id:)
          profiles.where(id:)
                  .select(:created_at, :display_name, :id)
                  .first
        end

        # Updates the profile information for a given account
        # Does not validate argument names passed to +args+, so if not validated before-hand can raise an exception
        # @param account_id (see .profile_id_from_account_id)
        # @param args [Hash{Symbol => Object}] A hash containing the fields to be updated. Will not be verified for validity.
        # @return [void]
        def update_profile_info(account_id:, **args)
          args["languages"] = Sequel.pg_array(args["languages"], :languages) if args.key?("languages") && args["languages"]
          args["genders"] = Sequel.pg_array(args["genders"], :genders) if args.key?("genders") && args["genders"]
          args["orientations"] = Sequel.pg_array(args["orientations"], :orientations) if args.key?("orientations") && args["orientations"]
          profiles.where(account_id:).update(args)
        end

        # Updates the profile location for a given account
        # @param account_id (see .profile_id_from_account_id)
        # @param location_result (see Persistence::Repository::Location.upsert_location)
        # @return [void]
        def update_profile_location(account_id:, location_result:)
          location_id = Persistence::Repository::Location.upsert_location(location_result:)
          profiles.where(account_id:).update(location_id:)
        end

        # @param id (see .profile_info)
        # @return [String]
        def profile_location(id:)
          profiles.inner_join(:locations, id: :location_id)
                  .where(Sequel[:profiles][:id] => id)
                  .get(Sequel[:locations][:geom])
        end

        # @param account_id (see .profile_id_from_account_id)
        # @param display_name [String] the display name for the profile
        # @param birth_date [String,Date] the birth date for the profile
        # @return [void]
        def create_profile(account_id:, display_name:, birth_date:)
          profiles.insert(account_id:, display_name:, birth_date:)
        end

        # @param account_id (see .profile_id_from_account_id)
        # @return [Hash]
        def profile_picture(account_id:)
          profiles.where(account_id:)
                  .get(:picture)
                  &.to_hash
        end

        # @param account_id (see .profile_id_from_account_id)
        # @param picture [Hash] picture data coming from Shrine
        # @return [void]
        def update_profile_picture(account_id:, picture:)
          profiles.where(account_id:)
                  .update(picture: Sequel.pg_jsonb_wrap(picture))
        end

        # @param id (see .profile_info)
        # @return [String] The email for the profile
        def find_email_for(id:)
          profiles.where(Sequel[:profiles][:id] => id)
                  .inner_join(:accounts, id: :account_id)
                  .get(Sequel[:accounts][:email])
        end

        # @return [Array<String>]
        def admin_account_emails
          accounts.where(type: "admin")
                  .map(:email)
        end

        # @param email [String]
        # @return [void]
        def make_admin(email:)
          raise "Account with email=#{email} not found" unless accounts.where(email:).get(:id)

          accounts.where(email:)
                  .update(type: "admin")
        end
      end
    end
  end
end
