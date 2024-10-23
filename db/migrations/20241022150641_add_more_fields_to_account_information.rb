# frozen_string_literal: true

Sequel.migration do
  up do
    genders = %w[
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
    ]

    orientations = %w[
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
    ]

    languages = %w[abk aar afr aka sqi amh ara arg hye asm ava ave aym aze bam bak eus bel ben bis bos bre bul mya cat cha che nya zho chu chv cor cos cre hrv ces dan div nld dzo eng epo est ewe fao fij fin fra fry ful gla glg lug kat deu ell kal grn guj hat hau heb her hin hmo hun isl ido ibo ind ina ile iku ipk gle ita jpn jav kan kau kas kaz khm kik kin kir kom kon kor kua kur lao lat lav lim lin lit lub ltz mkd mlg msa mal mlt glv mri mar mah mon nau nav nde nbl ndo nep nor nob nno oci oji ori orm oss pli pus fas pol por pan que ron roh run rus sme smo sag san srd srp sna snd sin slk slv som sot spa sun swa ssw swe tgl tah tgk tam tat tel tha bod tir ton tso tsn tur tuk twi uig ukr urd uzb ven vie vol wln cym wol xho iii yid yor zha zul]
    relationship_type = %w[monogamous non_monogamous]
    relationship_status = %w[single partnered married]
    frequency = %w[never sometimes often]
    haves_or_have_nots = %w[have have_not]
    wants = %w[
      want_more
      do_not_want_more
      want_some
      do_not_want_any
      dont_know
      maybe
    ]
    religions = %w[
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
    ]
    importance = %w[
      important not_important do_not_care
    ]

    create_enum(:genders, genders)
    create_enum(:orientations, orientations)
    create_enum(:languages, languages)
    create_enum(:relationship_type, relationship_type)
    create_enum(:relationship_status, relationship_status)
    create_enum(:frequency, frequency)
    create_enum(:haves_or_have_nots, haves_or_have_nots)
    create_enum(:wants, wants)
    create_enum(:religions, religions)
    create_enum(:importance, importance)

    alter_table :account_informations do
      add_column :about_me, :text
      add_column :birth_date, :date
      add_column :genders, "genders[]"
      add_column :orientations, "orientations[]"
      add_column :languages, "languages[]"
      add_column :relationship_type, :relationship_type
      add_column :relationship_status, :relationship_status
      add_column :tobacco, :frequency
      add_column :marijuana, :frequency
      add_column :alcohol, :frequency
      add_column :other_recreational_drugs, :frequency
      add_column :pets, :haves_or_have_nots
      add_column :wants_pets, :wants
      add_column :kids, :haves_or_have_nots
      add_column :wants_kids, :wants
      add_column :religion, :religions
      add_column :religion_importance, :importance
    end
  end
  down do
    alter_table :account_informations do
      drop_column :about_me
      drop_column :birth_date
      drop_column :genders
      drop_column :orientations
      drop_column :languages
      drop_column :relationship_type
      drop_column :relationship_status
      drop_column :tobacco
      drop_column :marijuana
      drop_column :alcohol
      drop_column :other_recreational_drugs
      drop_column :pets
      drop_column :wants_pets
      drop_column :kids
      drop_column :wants_kids
      drop_column :religion
      drop_column :religion_importance
    end

    drop_enum(:genders)
    drop_enum(:orientations)
    drop_enum(:languages)
    drop_enum(:relationship_type)
    drop_enum(:relationship_status)
    drop_enum(:frequency)
    drop_enum(:haves_or_have_nots)
    drop_enum(:wants)
    drop_enum(:religions)
    drop_enum(:importance)
  end
end
