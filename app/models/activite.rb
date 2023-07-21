# coding: utf-8
# Classe pour les codes d'activites
#
class Activite
  # La liste des activites et leur code. Pour les heures travaillees.
  CodeActivites = { 
    'S' => 'Sauveteur', 'LN' => 'Lessons de natation', 'E' => 'Entretien',
    'P' => 'Plongeon', 'PC' => 'Plongeon - Compétition',
    'AF' => 'Aquaforme', 'MN' => 'Maîtres-nageurs',
    'W' => 'Water-polo', 'WC' => 'Water-polo - Compétition',
    'N' => 'Equipe natation', 'NC' => 'Equipe natation - Compétition',
    'F' => 'Formation', 'AD' => 'Admin',
    'Y' => 'Synchro', 'YC' => 'Synchro - Compétition',
    'AC' => 'Accueil',
    'LD' => 'Leaders',
    'YO' => 'Yoga',
    'ZU' => 'Zumba'
   }
   
   # Retourne le nom de l'activite etant donne le code
   def self.nom(code)
     return CodeActivites[code]
   end
end