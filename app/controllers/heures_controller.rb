# coding: utf-8
#
# Controlleur pour les heures
#
class HeuresController < ApplicationController
  
  # Methode ajax pour retourner un HTML avec ceux qui travaillaient a une heure specifique.
  def autravail
    # Input looks like: Mon Jul 04 2016 08:00:00 GMT-0400 (EDT)
    dt = Time.zone.parse(params[:debut])
    fin = dt + 3600
    @heures = Heure.auTravail(dt, fin)
    @title = 'Heures pour cette cellule'
    render(layout: 'popover')
  end
end