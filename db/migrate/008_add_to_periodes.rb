class AddToPeriodes < ActiveRecord::Migration
  def self.up
    add_column :periodes, :ae_employeur, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :periodes, :rrq_employeur, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :periodes, :rqap_employeur, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :periodes, :fss_employeur, :decimal, :precision => 8, :scale => 2, :default => 0
        
    ps = Periode.find(:all)
    ps.each do |p|
      p.ae_employeur = (p.ae_employe_total * ConstantePaie.instance.aeTauxEmployeur * 100).round / 100.0
      p.rrq_employeur = (p.rrq_employe_total * ConstantePaie.instance.rrqTauxEmployeur * 100).round / 100.0
      p.rqap_employeur = (p.rqap_employe_total * ConstantePaie.instance.rqapTauxEmployeur * 100).round / 100.0
      p.fss_employeur = (p.brut_total * ConstantePaie.instance.fssTauxEmployeur * 100).round / 100.0
      p.save!
    end
    
  end

  def self.down
    remove_column :periodes, :ae_employeur, :rrq_employeur, :rqap_employeur, :fss_employeur
  end
end
