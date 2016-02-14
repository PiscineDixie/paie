class PaieMailer < ApplicationMailer
  def releve(paie)
    @paie = paie
    mail(to: @paie.employe.courriel, subject: "Relevé de paie pour la période débutant le #{paie.periode_debut}")
  end
end
