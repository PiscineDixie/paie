# coding: utf-8
# Classe representer un RL1
#
# Notes on prawn layout:
#  - the bottom left corner of a page or bounding box is (x,y) = 0, 0
#  - bounding boxes are specified using the top left corner
#

require "prawn/measurement_extensions"

class RL1
  
  # doc: PDF document opened to which we add
  # employes: Les employes pour lequels on veut ecrire un RL1
  # employeur:
  # annee:
  def self.renderMultiple(doc, employes, employeur, annee)
    employes.each do | empl |
      unless empl.gains_brut_annuel(annee) == 0
       
        doc.start_new_page
   
        doc.bounding_box([10.mm,265.mm], :width => 210.mm, :height => 140.mm) do
          rl1s_employe(doc, empl, employeur, annee)
        end
   
        doc.bounding_box([0,140.mm], :width => 210.mm, :height => 140.mm) do
          rl1s_gouv(doc, empl, employeur, annee)
        end
      end
    end
  end
  
  def self.rl1s_employe(doc, employe, employeur, annee)
    doc.font "Courier" do
      # Premiere ligne
      doc.bounding_box([0, 137.mm], :width => 210.mm, :height => 16.mm) do
        doc.draw_text sprintf("%10.2f", employe.gains_brut_annuel(annee)), :at => [6.mm, 9.mm]
        doc.draw_text sprintf("%10.2f", employe.rrq_annuel(annee)), :at => [38.mm, 9.mm]
        doc.draw_text sprintf("%10.2f", employe.ae_annuel(annee)), :at => [72.mm, 9.mm]
        doc.draw_text sprintf("%10.2f", employe.impot_prov_annuel(annee)), :at => [138.mm, 9.mm]
        # Deuxieme ligne
        doc.draw_text sprintf("%10.2f", employe.rrq_salaire_annuel(annee)), :at => [6.mm, 1.mm]
        doc.draw_text sprintf("%10.2f", employe.rqap_annuel(annee)), :at => [38.mm, 1.mm]
      end
    end
  
    doc.bounding_box([15.mm, 55.mm], :width => 200, :height => 70.mm) do
      doc.text employe.NOM_prenom
      doc.text employe.adresse1
      doc.text employe.adresse2
      doc.text employe.adresse3
    end
    
    doc.draw_text sprintf("%s    %s    %s", employe.nas[0,3], employe.nas[3,3], employe.nas[6,3]), :at => [120.mm, 75.mm]
  
    doc.bounding_box([120.mm, 60.mm], :width => 70.mm) do
      doc.text employeur.nom
      doc.text employeur.adresse1
      doc.text employeur.adresse2 + " " + employeur.adresse3
    end
  end
  
  
  # Imprimer le stub du gouvernement
  def self.rl1s_gouv(doc, employe, employeur, annee)
    doc.bounding_box([0, 122.mm], :width => 210.mm, :height => 16.mm) do
      doc.font "Courier" do
        # Premiere ligne
        doc.draw_text sprintf("%10.2f", employe.gains_brut_annuel(annee)), :at => [14.mm, 9.mm]
        doc.draw_text sprintf("%10.2f", employe.rrq_annuel(annee)), :at => [48.mm, 9.mm]
        doc.draw_text sprintf("%10.2f", employe.ae_annuel(annee)), :at => [81.mm, 9.mm]
        doc.draw_text sprintf("%10.2f", employe.impot_prov_annuel(annee)), :at => [147.mm, 9.mm]
        # Deuxieme ligne
        doc.draw_text sprintf("%10.2f", employe.rrq_salaire_annuel(annee)), :at => [14.mm, 1.mm]
        doc.draw_text sprintf("%10.2f", employe.rqap_annuel(annee)), :at => [48.mm, 1.mm]
      end
    end
  
    # Coordonnees de l'employe
    doc.bounding_box([11.mm, 80.mm], :width => 100.mm, :height => 70.mm) do
      doc.draw_text employe.nom, :at => [0, 56.mm]
      doc.draw_text employe.prenom, :at => [0, 47.mm]
      doc.draw_text employe.adresse1, :at => [0, 30.mm]
      doc.draw_text employe.adresse2, :at => [0, 22.mm]
      doc.draw_text "QC", :at => [0.mm, 13.mm]
      doc.draw_text employe.adresse3, :at => [20.mm, 13.mm]
    end
    
    doc.draw_text sprintf("%s    %s    %s", employe.nas[0,3], employe.nas[3,3], employe.nas[6,3]), :at => [118.mm, 65.mm]
    
    # Coordonees de l'employeur
    doc.bounding_box([116.mm, 82.mm], :width => 300, :height => 72.mm) do
      doc.draw_text employeur.nom, :at => [0, 45.mm]
      doc.draw_text employeur.adresse1, :at => [0, 21.mm]
      doc.draw_text employeur.adresse2, :at => [0, 13.mm]
      doc.draw_text "QC", :at => [0, 4.mm]
      doc.draw_text employeur.adresse3, :at => [18.mm, 4.mm]
    end
  end
  
end