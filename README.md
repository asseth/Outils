# Outils Asseth
Outils et scripts divers

`loterie.sh` - Compare en valeur absolue le delta entre le hash d'un bloc décidé à l'avance et les hashs des adresses email des candidats. L'email dont le delta est le plus petit apparaît en premier et gagne le lot. Si on préfixe la commande par `DEBUG=1`, les hashes et les deltas apparaissent.

`$ ./loterie.sh 4243679 foo@example.com bar@example.com baz@example.com`

`$ DEBUG=1 ./loterie.sh 4243679 foo@example.com bar@example.com baz@example.com`
