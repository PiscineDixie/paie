# coding: utf-8
# Classe representer un cheque
#
class Cheque
  
  # Ajouter un cheque pour la paie dans le doc
  def self.render(doc, paie)
    unless paie.total == 0
      doc.start_new_page
      doc.draw_text Date.today.to_s(:db), :at => [450, 700]
      doc.draw_text "***" + number_to_currency(paie.total), :at => [450, 650], :style => :bold
      doc.draw_text paie.montant_alphabetique, :at => [170, 650], :size => 14
      doc.bounding_box([35, 625], :width => 200) do
        doc.text paie.prenom_nom
        doc.text paie.employe.adresse1
        doc.text paie.employe.adresse2
        doc.text paie.employe.adresse3
      end
      
      doc.bounding_box([0, 470], :width => 500) do 
        stub(doc, paie)
      end
      
      doc.bounding_box([0, 220], :width => 500) do
        stub(doc, paie)
      end

    end
  end
  
  Widths = [120, 130, 60, 70, 70 ]
  Headers = [ "", "", "", "Période", "Annuel" ]
  
  def self.stub(doc, paie)
    
    doc.font_size(10)
    head = doc.make_table([Headers]) do | h |
      h.column_widths = Widths
      h.cells.style :borders => [:bottom]
      h.columns(3..4).align = :right
    end
    
    data = 
      [ 
        ["Nom:", paie.prenom_nom,  
        "Heures", number_with_precision(paie.heures, :precision => 2), number_with_precision(paie.employe.heures_annuel, :precision => 2)],
       ["Début de période:", paie.periode_debut,
        "Brut", number_with_precision(paie.brut, :precision => 2), number_with_precision(paie.employe.gains_brut_annuel, :precision => 2)],
       ["Fin de période:", paie.periode_fin,
        "Vacances", number_with_precision(paie.vacances, :precision => 2), number_with_precision(paie.employe.gains_vacances_annuel, :precision => 2)],
       ["Numéro de chèque:", paie.cheque_no,
        "R.R.Q", number_with_precision(paie.rrq, :precision => 2), number_with_precision(paie.employe.rrq_annuel, :precision => 2)],
       ["Salaire horaire:", number_with_precision(paie.employe.salaire_horaire, :precision => 2),
        "Ass. Emploi", number_with_precision(paie.ae, :precision => 2), number_with_precision(paie.employe.ae_annuel, :precision => 2)],
       ["Autre gain:", number_with_precision(paie.autre_gain_imposable, :precision => 2),
        "R.Q.A.P.", number_with_precision(paie.rqap, :precision => 2), number_with_precision(paie.employe.rqap_annuel, :precision => 2)],
       ["Ajust. Heures:", number_with_precision(paie.ajustement_heures, :precision => 2),
        "Imp. Féd.", number_with_precision(paie.impot_fed, :precision => 2), number_with_precision(paie.employe.impot_federal_annuel, :precision => 2)],
       ["Remb. Dépenses:", number_with_precision(paie.remb_depense, :precision => 2),
        "Imp. Prov.", number_with_precision(paie.impot_prov, :precision => 2), number_with_precision(paie.employe.impot_prov_annuel, :precision => 2)],
       ["Note:", paie.note,
        "Net", number_with_precision(paie.net, :precision => 2), number_with_precision(paie.employe.gains_net_annuel, :precision => 2)]
      ]
      
    rows = doc.make_table(data) do | t |
      t.column_widths = Widths
      t.cells.style :borders => [], :padding => 1
      t.columns(3..4).align = :right
    end
  
    doc.table([[head], [rows]]) do |t|
      t.cells.style :borders => []
    end
  end
  
  # Emulate those functions that are normally available in views
  def self.number_to_currency(n)
    number_with_precision(n, :precision => 2)
  end
  
  def self.number_with_precision(n, precision)
    sprintf('%1.2f', n)
  end
  
end

