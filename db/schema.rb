# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170629004532) do

  create_table "constante_paies", force: :cascade do |t|
    t.integer  "deductionBaseFed",       limit: 4
    t.integer  "impFedI1",               limit: 4,                         default: 0
    t.integer  "impFedI2",               limit: 4,                         default: 0
    t.integer  "impFedI3",               limit: 4,                         default: 0
    t.decimal  "impFedR1",                         precision: 8, scale: 6, default: 0.0
    t.decimal  "impFedR2",                         precision: 8, scale: 6, default: 0.0
    t.decimal  "impFedR3",                         precision: 8, scale: 6, default: 0.0
    t.decimal  "impFedR4",                         precision: 8, scale: 6, default: 0.0
    t.integer  "impFedK1",               limit: 4,                         default: 0
    t.integer  "impFedK2",               limit: 4,                         default: 0
    t.integer  "impFedK3",               limit: 4,                         default: 0
    t.integer  "impFedK4",               limit: 4,                         default: 0
    t.integer  "deductionBaseProv",      limit: 4
    t.integer  "impProvI1",              limit: 4,                         default: 0
    t.integer  "impProvI2",              limit: 4,                         default: 0
    t.decimal  "impProvT1",                        precision: 8, scale: 2, default: 0.0
    t.decimal  "impProvT2",                        precision: 8, scale: 2, default: 0.0
    t.decimal  "impProvT3",                        precision: 8, scale: 2, default: 0.0
    t.integer  "impProvK1",              limit: 4,                         default: 0
    t.integer  "impProvK2",              limit: 4,                         default: 0
    t.integer  "impProvK3",              limit: 4,                         default: 0
    t.decimal  "aeTauxEmployeur",                  precision: 8, scale: 6, default: 0.0
    t.decimal  "aeTauxEmploye",                    precision: 8, scale: 6, default: 0.0
    t.decimal  "rrqTauxEmployeur",                 precision: 8, scale: 6, default: 0.0
    t.decimal  "rrqTauxEmploye",                   precision: 8, scale: 6, default: 0.0
    t.decimal  "rqapTauxEmployeur",                precision: 8, scale: 6, default: 0.0
    t.decimal  "rqapTauxEmploye",                  precision: 8, scale: 6, default: 0.0
    t.decimal  "fssTauxEmployeur",                 precision: 8, scale: 6, default: 0.0
    t.decimal  "aeMaximumEmploye",                 precision: 8, scale: 2, default: 0.0
    t.decimal  "rrqMaximumEmploye",                precision: 8, scale: 2, default: 0.0
    t.decimal  "rqapMaximumEmploye",               precision: 8, scale: 2, default: 0.0
    t.integer  "aeMaximumGainAssurable", limit: 4,                         default: 0
    t.decimal  "rrqExemptionEmploye",              precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "csstTauxEmployeur",                precision: 8, scale: 6, default: 0.0
  end

  create_table "employes", force: :cascade do |t|
    t.string   "nom",               limit: 255,                         default: "",     null: false
    t.string   "prenom",            limit: 255,                         default: "",     null: false
    t.string   "adresse1",          limit: 255
    t.string   "adresse2",          limit: 255
    t.string   "adresse3",          limit: 255
    t.string   "nas",               limit: 255
    t.string   "courriel",          limit: 255
    t.boolean  "courriel_sommaire",                                     default: false
    t.date     "naissance",                                                              null: false
    t.string   "etat",              limit: 255,                         default: "",     null: false
    t.decimal  "salaire_horaire",               precision: 8, scale: 2,                  null: false
    t.boolean  "exempte_impot",                                         default: false
    t.decimal  "exemption_fed",                 precision: 8, scale: 2, default: 9600.0, null: false
    t.decimal  "exemption_prov",                precision: 8, scale: 2, default: 9600.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "employes", ["courriel"], name: "employes_unique_courriel", unique: true, using: :btree

  create_table "employeurs", force: :cascade do |t|
    t.string   "nom",                limit: 255
    t.string   "adresse1",           limit: 255
    t.string   "adresse2",           limit: 255
    t.string   "adresse3",           limit: 255
    t.string   "numero_entreprise",  limit: 255
    t.date     "debut_paie"
    t.date     "fin_paie"
    t.integer  "semaines_par_paie",  limit: 4
    t.integer  "prochain_no_cheque", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feuilles", force: :cascade do |t|
    t.integer  "employe_id",  limit: 4
    t.date     "periode"
    t.boolean  "locked",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "empl_locked",           default: false
  end

  add_index "feuilles", ["employe_id", "periode"], name: "par_employe_periode", unique: true, using: :btree

  create_table "heures", force: :cascade do |t|
    t.integer  "feuille_id", limit: 4,                null: false
    t.string   "activite",   limit: 255, default: "", null: false
    t.datetime "debut",                               null: false
    t.integer  "duree",      limit: 4,                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "heures", ["debut"], name: "par_debut", using: :btree
  add_index "heures", ["feuille_id", "debut"], name: "par_feuille_debut", unique: true, using: :btree

  create_table "paies", force: :cascade do |t|
    t.integer  "employe_id",           limit: 4
    t.integer  "periode_id",           limit: 4
    t.integer  "feuille_id",           limit: 4
    t.integer  "cheque_no",            limit: 4
    t.decimal  "remb_depense",                     precision: 8, scale: 2, default: 0.0
    t.decimal  "ajustement_heures",                precision: 8, scale: 2, default: 0.0
    t.decimal  "autre_gain_imposable",             precision: 8, scale: 2, default: 0.0
    t.decimal  "brut",                             precision: 8, scale: 2, default: 0.0
    t.decimal  "net",                              precision: 8, scale: 2, default: 0.0
    t.decimal  "vacances",                         precision: 8, scale: 2, default: 0.0
    t.decimal  "ae",                               precision: 8, scale: 2, default: 0.0
    t.decimal  "rrq",                              precision: 8, scale: 2, default: 0.0
    t.decimal  "rqap",                             precision: 8, scale: 2, default: 0.0
    t.decimal  "impot_fed",                        precision: 8, scale: 2, default: 0.0
    t.decimal  "impot_prov",                       precision: 8, scale: 2, default: 0.0
    t.string   "note",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paies", ["employe_id", "periode_id"], name: "par_employe_periode", unique: true, using: :btree
  add_index "paies", ["periode_id"], name: "par_periode", using: :btree

  create_table "periodes", force: :cascade do |t|
    t.date     "debut"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "ae_employeur",   precision: 8, scale: 2, default: 0.0
    t.decimal  "rrq_employeur",  precision: 8, scale: 2, default: 0.0
    t.decimal  "rqap_employeur", precision: 8, scale: 2, default: 0.0
    t.decimal  "fss_employeur",  precision: 8, scale: 2, default: 0.0
    t.decimal  "csst_employeur", precision: 8, scale: 2, default: 0.0
    t.boolean  "locked",                                 default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "courriel",   limit: 255
    t.string   "nom",        limit: 255
    t.string   "roles",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["courriel"], name: "index_users_on_courriel", using: :btree
  add_index "users", ["courriel"], name: "users_unique_courriel", unique: true, using: :btree

end
