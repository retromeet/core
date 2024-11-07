# frozen_string_literal: true

Sequel.migration do
  up do
    countries_iso_3166_1_alpha2 = %w[ad ae af ag ai al am ao aq ar as at au aw ax az ba bb bd be bf bg bh bi bj bl bm bn bo bq br bs bt bv bw by bz ca cc cd cf cg ch ci ck cl cm cn co cr cu cv cw cx cy cz de dj dk dm do dz ec ee eg eh er es et fi fj fk fm fo fr ga gb gd ge gf gg gh gi gl gm gn gp gq gr gs gt gu gw gy hk hm hn hr ht hu id ie il im in io iq ir is it je jm jo jp ke kg kh ki km kn kp kr kw ky kz la lb lc li lk lr ls lt lu lv ly ma mc md me mf mg mh mk ml mm mn mo mp mq mr ms mt mu mv mw mx my mz na nc ne nf ng ni nl no np nr nu nz om pa pe pf pg ph pk pl pm pn pr ps pt pw py qa re ro rs ru rw sa sb sc sd se sg sh si sj sk sl sm sn so sr ss st sv sx sy sz tc td tf tg th tj tk tl tm tn to tr tt tv tw tz ua ug um us uy uz va vc ve vg vi vn vu wf ws ye yt za zm zw] # list exported from the web, should match https://www.iso.org/obp/ui/#search/code/

    create_enum(:countries_iso_3166_1_alpha2, countries_iso_3166_1_alpha2)
    create_table(:locations) do
      primary_key :id, type: :Bignum
      column :geom, "geometry(POINT, 4326)", null: false # 4326 is the chosen spatial reference, WGS84 geodetic, seems to be the more common one: https://spatialreference.org/ref/epsg/4326/
      column :display_name, :jsonb, null: false
      column :osm_id, Integer, null: false, unique: true
      column :country_code, :countries_iso_3166_1_alpha2, null: false # regardless of provider, the country data will come from open street maps and that is what they use https://wiki.openstreetmap.org/wiki/Country_code
    end

    alter_table(:account_informations) do
      add_foreign_key :location_id, :locations, type: :Bignum
    end
  end
  down do
    alter_table(:account_informations) do
      drop_column(:location_id)
    end
    drop_table(:locations)
    drop_enum(:countries_iso_3166_1_alpha2)
  end
end
