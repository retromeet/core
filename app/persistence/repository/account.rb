# frozen_string_literal: true

module Persistence
  module Repository
    # Contains database logic around accounts
    module Account
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
        # Returns profile information for a given account
        #
        # @param account_id [Integer] An id for an account
        # @return [Hash{Symbol => Object}] A record containing +account_id+, +created_at+ and +display_name+
        def profile_info(account_id:)
          account_informations.where(account_id:).first
        end

        # Returns basic profile information for a given account
        #
        # @param account_id [Integer] An id for an account
        # @return [Hash{Symbol => Object}] A record containing +account_id+, +created_at+ and +display_name+
        def basic_profile_info(account_id:)
          account_informations.where(account_id:).select(:created_at, :display_name, :account_id).first
        end

        # Updates the profile information for a given account
        # Does not validate argument names passed to +args+, so if not validated before-hand can raise an exception
        # @param account_id (see #profile_info)
        # @param args [Hash{Symbol => Object}] A hash containing the fields to be updated. Will not be verified for validity.
        # @return [void]
        def update_profile_info(account_id:, **args)
          args["languages"] = Sequel.pg_array(args["languages"], :languages) if args.key?("languages")
          args["genders"] = Sequel.pg_array(args["genders"], :genders) if args.key?("genders")
          args["orientations"] = Sequel.pg_array(args["orientations"], :orientations) if args.key?("orientations")
          account_informations.where(account_id:).update(args)
        end

        private

          # @return [Sequel::Postgres::Dataset]
          def account_informations
            Database.connection[:account_informations]
          end
      end
    end
  end
end
