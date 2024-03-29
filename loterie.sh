#!/bin/bash

# Loterie Asseth - septembre 2017
# filtertron - jzu@free.fr
# Compare en valeur absolue le delta entre le hash d'un bloc decide a l'avance
# et ceux des adresses email (ou les identifiants) des candidats
# Le plus petit delta apparait en premier et gagne le lot
# DEBUG=1 permet d'envoyer les hashs sur stderr pour verification
# Teste sur une machine ou tourne Parity 1.6.3, changer GETHEXEC au besoin
# On peut aussi acceder a un noeud Avalanche en specifiant l'URL (port 9650)
# Exemple :
# $ ./loterie.sh 4243679 foo@example.com bar@example.com baz@example.com


LANG=C
LC_ALL=C

export BC_LINE_LENGTH=0

#export DEBUG=1

#export GETHEXEC="geth attach $HOME/.local/share/io.parity.ethereum/jsonrpc.ipc --exec"
export GETHEXEC="geth attach --exec"
#export GETHEXEC="geth attach http://localhost:9650/ext/bc/C/rpc --exec"

# Affiche les hashes et les deltas

debug () {

  if [ "$DEBUG" = 1 ]
  then 
    echo $* 1>&2
  fi
}

if [ "$DEBUG" = 1 ]
then
  FMT=cat
else
  FMT='sed -e s/.*\ //g'
fi

# Gestion des erreurs

if [ $# -lt 3 ]
then
  echo "Usage: $0 block# email1 email2 [emails...]"
  exit 1
fi

echo | $GETHEXEC "" &> /dev/null
if [ $? -ne 0 ]
then
  echo Node Ethereum inaccessible
  exit 2
fi

export BLKNBR=$1
shift

$GETHEXEC "eth.getBlock($BLKNBR)" 2> /dev/null \
| grep -q "^null$"
if [ $? -eq 0 ]
then
  echo Bloc $BLKNBR inexistant
  exit 3
fi

# Hash du bloc choisi

BLOCKH=`$GETHEXEC 'eth.getBlock('$BLKNBR').hash' \
        | sed 's/^"0x\(.*\)"/\1/' \
        | tr a-f A-F`
debug $BLOCKH 'eth.getBlock('$BLKNBR').hash'

# Hash des emails et calcul des deltas

for m in $*
do
  MAILH=`$GETHEXEC 'web3.sha3("'$m'")' \
         | sed 's/^"0x\(.*\)"/\1/' \
         | tr a-f A-F`
  debug $MAILH $m
  echo ibase=16\; $MAILH-$BLOCKH \
  | bc \
  | sed -e "s/-//" \
        -e "s/$/ $m/"
done \
| sort -n \
| eval "$FMT"


