# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2017_06_29_004532) do

  create_table "constante_paies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "deductionBaseFed"
    t.integer "impFedI1", default: 0
    t.integer "impFedI2", default: 0
    t.integer "impFedI3", default: 0
    t.decimal "impFedR1", precision: 8, scale: 6, default: "0.0"
    t.decimal "impFedR2", precision: 8, scale: 6, default: "0.0"
    t.decimal "impFedR3", precision: 8, scale: 6, default: "0.0"
    t.decimal "impFedR4", precision: 8, scale: 6, default: "0.0"
    t.integer "impFedK1", default: 0
    t.integer "impFedK2", default: 0
    t.integer "impFedK3", default: 0
    t.integer "impFedK4", default: 0
    t.integer "deductionBaseProv"
    t.integer "impProvI1", default: 0
    t.integer "impProvI2", default: 0
    t.decimal "impProvT1", precision: 8, scale: 2, default: "0.0"
    t.decimal "impProvT2", precision: 8, scale: 2, default: "0.0"
    t.decimal "impProvT3", precision: 8, scale: 2, default: "0.0"
    t.integer "impProvK1", default: 0
    t.integer "impProvK2", default: 0
    t.integer "impProvK3", default: 0
    t.decimal "aeTauxEmployeur", precision: 8, scale: 6, default: "0.0"
    t.decimal "aeTauxEmploye", precision: 8, scale: 6, default: "0.0"
    t.decimal "rrqTauxEmployeur", precision: 8, scale: 6, default: "0.0"
    t.decimal "rrqTauxEmploye", precision: 8, scale: 6, default: "0.0"
    t.decimal "rqapTauxEmployeur", precision: 8, scale: 6, default: "0.0"
    t.decimal "rqapTauxEmploye", precision: 8, scale: 6, default: "0.0"
    t.decimal "fssTauxEmployeur", precision: 8, scale: 6, default: "0.0"
    t.decimal "aeMaximumEmploye", precision: 8, scale: 2, default: "0.0"
    t.decimal "rrqMaximumEmploye", precision: 8, scale: 2, default: "0.0"
    t.decimal "rqapMaximumEmploye", precision: 8, scale: 2, default: "0.0"
    t.integer "aeMaximumGainAssurable", default: 0
    t.decimal "rrqExemptionEmploye", precision: 8, scale: 2, default: "0.0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "csstTauxEmployeur", precision: 8, scale: 6, default: "0.0"
  end

  create_table "employes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "nom", default: "", null: false
    t.string "prenom", default: "", null: false
    t.string "adresse1"
    t.string "adresse2"
    t.string "adresse3"
    t.string "nas"
    t.string "courriel"
    t.boolean "courriel_sommaire", default: false
    t.date "naissance", null: false
    t.string "etat", default: "", null: false
    t.decimal "salaire_horaire", precision: 8, scale: 2, null: false
    t.boolean "exempte_impot", default: false
    t.decimal "exemption_fed", precision: 8, scale: 2, default: "9600.0", null: false
    t.decimal "exemption_prov", precision: 8, scale: 2, default: "9600.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["courriel"], name: "employes_unique_courriel", unique: true
  end

  create_table "employeurs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "nom"
    t.string "adresse1"
    t.string "adresse2"
    t.string "adresse3"
    t.string "numero_entreprise"
    t.date "debut_paie"
    t.date "fin_paie"
    t.integer "semaines_par_paie"
    t.integer "prochain_no_cheque"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feuilles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "employe_id"
    t.date "periode"
    t.boolean "locked", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "empl_locked", default: false
    t.index ["employe_id", "periode"], name: "par_employe_periode", unique: true
  end

  create_table "heures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "feuille_id", null: false
    t.string "activite", default: "", null: false
    t.datetime "debut", null: false
    t.integer "duree", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["debut"], name: "par_debut"
    t.index ["feuille_id", "debut"], name: "par_feuille_debut", unique: true
  end

  create_table "paies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "employe_id"
    t.integer "periode_id"
    t.integer "feuille_id"
    t.integer "cheque_no"
    t.decimal "remb_depense", precision: 8, scale: 2, default: "0.0"
    t.decimal "ajustement_heures", precision: 8, scale: 2, default: "0.0"
    t.decimal "autre_gain_imposable", precision: 8, scale: 2, default: "0.0"
    t.decimal "brut", precision: 8, scale: 2, default: "0.0"
    t.decimal "net", precision: 8, scale: 2, default: "0.0"
    t.decimal "vacances", precision: 8, scale: 2, default: "0.0"
    t.decimal "ae", precision: 8, scale: 2, default: "0.0"
    t.decimal "rrq", precision: 8, scale: 2, default: "0.0"
    t.decimal "rqap", precision: 8, scale: 2, default: "0.0"
    t.decimal "impot_fed", precision: 8, scale: 2, default: "0.0"
    t.decimal "impot_prov", precision: 8, scale: 2, default: "0.0"
    t.string "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["employe_id", "periode_id"], name: "par_employe_periode", unique: true
    t.index ["periode_id"], name: "par_periode"
  end

  create_table "periodes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "debut"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "ae_employeur", precision: 8, scale: 2, default: "0.0"
    t.decimal "rrq_employeur", precision: 8, scale: 2, default: "0.0"
    t.decimal "rqap_employeur", precision: 8, scale: 2, default: "0.0"
    t.decimal "fss_employeur", precision: 8, scale: 2, default: "0.0"
    t.decimal "csst_employeur", precision: 8, scale: 2, default: "0.0"
    t.boolean "locked", default: false
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "courriel"
    t.string "nom"
    t.string "roles"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["courriel"], name: "index_users_on_courriel"
    t.index ["courriel"], name: "users_unique_courriel", unique: true
  end

end
