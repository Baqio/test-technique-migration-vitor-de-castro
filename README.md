# Test technique — Développeur·se Intégrations & Migration de données

Merci de l'intérêt que vous portez au poste.

Ce test reproduit le quotidien du poste : un nouveau client arrive chez nous et
souhaite retrouver dans Baqio les données de son ancien logiciel. Nous
fournissons ce que nous recevons réellement dans ces situations, et le travail
consiste à les faire entrer proprement en base.

Un collègue a commencé la reprise avant de passer à autre chose.
**Le code existant fonctionne sur un extrait simplifié des fichiers, mais pas
sur les fichiers réels du client.** Il est incomplet et il contient des
erreurs. L'objectif est donc autant de le corriger et de le compléter que
d'écrire du nouveau code.

---

## Temps et rendu

- Une semaine pour nous rendre le sujet, à faire quand cela vous arrange.
- Rendu avec un historique de commits lisible.
- Nous enchaînons sur un entretien d'environ une heure pendant lequel nous
  parcourons votre code ensemble. Le débrief compte autant que le code.

---

## Ce que nous évaluons

La justesse des données en base, ce que vous faites des données douteuses, la
traçabilité et la lisibilité.

Le point le plus important : **une erreur silencieuse est pire qu'un rejet
explicite**. Un client qui découvre trois mois plus tard que 40 de ses tarifs
sont faux, c'est un incident. Un rapport qui dit « 12 lignes non importées,
voici lesquelles et pourquoi », c'est un échange de cinq minutes.

---

## Les fichiers du client

Le client quitte **CaveGest 4.2**, un logiciel installé en local qu'il utilise
depuis 2011. Son prestataire lui a sorti deux exports, dans `data/` : ses
clients, et son catalogue avec ses grilles tarifaires.

---

## Le travail attendu

Les données des deux exports doivent se retrouver en base, justes, et la
reprise doit pouvoir être relancée sans dégât.

Deux importeurs existent et sont faux : `Customer::Import::Cavegest` et
`ProductPrice::Import::Cavegest`. `Importer::Audit` est vide : il doit porter
les contrôles qui permettent d'affirmer au client que sa reprise est juste,
et nous les attendons calculés depuis la base.

`lib/migration_report.rb` collecte ce qui s'est passé pendant l'import. À la
fin d'une reprise, nous devons pouvoir dire combien d'enregistrements ont été
créés, ce qui a été rejeté et pourquoi, et ce qui est passé mais mérite une
vérification humaine. La forme est libre ; la personne qui lit ce rapport n'est
pas développeuse.

---

## Notes de reprise

Ajoutez une courte section « Notes de reprise » à la fin de votre README, ou
dans un fichier poussé sur le repo. Nous y cherchons ce qu'un collègue
écrirait avant de partir en week-end :

- ce que vous avez décidé sur les cas où les fichiers ne tranchaient pas ;
- ce que vous feriez confirmer par le client avant de lancer la reprise en
  réel.

Quelques phrases suffisent. Nous ne cherchons pas un rapport, mais à comprendre
vos arbitrages sans avoir à les deviner dans le code.

---

## Précisions

Le schéma, les modèles et l'architecture sont modifiables, y compris en
repartant de zéro si vous jugez le code existant irrécupérable. Dites-nous
simplement pourquoi.

Les gems aussi : `roo` est une suggestion, pas une contrainte.

Bon courage.


## Notes de reprise

Code famille client
Le code R (REVENDEUR) a été mappé vers customer. Les codes inconnus sont rejetés avec un message d'erreur.

Feuille Excel
Seule la feuille "Feuil1" a été utilisée. La feuille "clients" est marquée "NE PAS UTILISER".

Lignes ignorées
Les lignes vides et la ligne "TOTAL" sont ignorées.

Code pays
Les valeurs "FRANCE", "France", "fr" sont normalisées en "FR".

Code postal
Les codes postaux sont stockés sous forme d'entier dans Excel (ex: 1000 au lieu de 01000). Ils sont complétés à 5 chiffres avec des zéros à gauche.

Colonnes dupliquées
Le fichier Excel contient 27 colonnes, dont des doublons (Nom, Prénom, Adresse, etc.) pour l'adresse de facturation et l'adresse de livraison. La méthode parse(headers: true) de Roo écrase silencieusement les colonnes dupliquées. Les lignes sont lues par index pour éviter ce problème.

Adresse de livraison
Quand les colonnes d'adresse de livraison (index 11-18) sont vides, use_billing_address est mis à true. Quand une adresse de livraison existe, use_billing_address est mis à false et les champs de livraison sont renseignés.

Lignes SOUS-TOTAL
Les lignes dont la référence commence par "SOUS-TOTAL" sont des sous-totaux par catégorie, pas des produits réels. Elles sont ignorées.

Virgule décimale
Les prix dans le fichier CSV utilisent la virgule comme séparateur décimal (format français). Ils sont convertis en point avant parsing.

Idempotence
L'import peut être relancé sans dégât. Les produits et tarifs existants sont mis à jour plutôt que recrées.

Grille SALON
Certains produits n'ont pas de tarif SALON (valeur vide). Un tarif à 0.00 est créé dans ce cas.

Encodage
Le fichier CSV est encodé en ISO-8859-1 (ancien logiciel français). Converti en UTF-8 à la lecture.

Clients sans nom
T00078, T01803 et T04000 n'ont ni raison sociale, ni nom, ni prénom. Ils sont rejetés avec un message d'erreur explicite.

Rapport d'import
Le rapport liste les compteurs, les erreurs et les avertissements. Il est lisible par un non-développeur.
