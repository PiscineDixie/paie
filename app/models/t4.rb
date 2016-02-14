# coding: utf-8
# Classe representer un T4
#

require "prawn/measurement_extensions"

class T4
  
  # doc: PDF document opened to which we add
  # employes: Les employes pour lequels on veut ecrire un T4
  # employeur:
  # annee:
  # copies: Nombre de copies consécutives pour chaque T4
  def self.renderMultiple(doc, employes, employeur, annee, copies)
    t4Compteur = 0
    employes.each do | empl |
      unless empl.gains_brut_annuel(annee) == 0
        1.upto(copies) do
       
          if t4Compteur.modulo(2) == 0
          then
            doc.start_new_page
   
            doc.bounding_box([0,277.mm], :width => 22.cm, :height => 140.mm) do
              renderOne(doc, empl, employeur, annee)
            end
          else
            doc.bounding_box([0,141.mm], :width => 22.cm, :height => 140.mm) do
              renderOne(doc, empl, employeur, annee)
            end
          end
          t4Compteur = t4Compteur + 1
        end
      end
    end
  end
  
  # Ajouter un t4 pour l'employé dans le doc
  def self.renderOne(doc, employe, employeur, annee)
    # Ecrire les coordonnees de l'employeur
    doc.bounding_box([15.mm,135.mm], :width => 75.mm, :height => 25.mm) do
      doc.draw_text employeur.nom, :at => [5.mm, 12.mm]
    end
  
    # Ecrire les coordonnees de l'employe
    doc.draw_text employe.NOM_prenom, :at => [25.mm, 67.mm]
    doc.bounding_box([25.mm,60.mm], :width => 200, :height => 3.cm) do
      doc.text employe.adresse1
      doc.text employe.adresse2
      doc.text employe.adresse3
    end
  
    doc.draw_text annee.to_s, :at => [110.mm, 125.mm]
    doc.draw_text  employeur.numero_entreprise, :at => [25.mm, 101.mm]
    doc.draw_text "QC", :at => [103.mm, 98.mm]
    doc.draw_text employe.nas, :at => [25.mm, 88.mm]
    if employe.exempte_rrq_t4(annee)
    then
      doc.draw_text "X", :at => [75.mm, 89.mm]
    end
  
    doc.font "Courier" do
      doc.draw_text sprintf("%10.2f", employe.gains_brut_annuel(annee)), :at => [129.mm, 111.mm]
      doc.draw_text sprintf("%10.2f", employe.impot_federal_annuel(annee)), :at => [177.mm, 111.mm]
      doc.draw_text sprintf("%10.2f", employe.rrq_annuel(annee)), :at => [129.mm, 86.mm]
      doc.draw_text sprintf("%10.2f", employe.ae_annuel(annee)), :at => [129.mm, 73.mm]
      doc.draw_text sprintf("%10.2f", employe.rqap_annuel(annee)), :at => [129.mm, 34.mm]
    end
  end
  
end