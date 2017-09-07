#!/bin/bash

# Loterie Asseth - septembre 2017
# filtertron - jzu@free.fr
# Compare en valeur absolue le delta entre le hash d'un bloc decide a l'avance
# et ceux des adresses email des candidats
# Le plus petit delta apparait en premier et gagne le lot
# DEBUG=1 permet d'envoyer les hashs sur stderr pour verification
# Teste sur une machine ou tourne Parity 1.6.3, changer GETHEXEC au besoin
# Exemple :
# $ ./loterie.sh 4243679 foo@example.com bar@example.com baz@example.com


LANG=C
LC_ALL=C
BC_LINE_LENGTH=0

#export DEBUG=1

export GETHEXEC="geth attach $HOME/.local/share/io.parity.ethereum/jsonrpc.ipc --exec"


debug () {

  if [ "$DEBUG" = 1 ]
  then 
    echo $* 1>&2
  fi
}


if [ $# -lt 3 ]
then
  echo "Usage: $0 block# email1 email2 [emails...]"
  exit 1
fi


export BLKNBR=$1
shift

BLOCKH=`$GETHEXEC 'eth.getBlock('$BLKNBR').hash' \
        | sed 's/^"0x\(.*\)"/\1/' \
        | tr a-f A-F`
debug $BLOCKH 'eth.getBlock('$BLKNBR').hash'

i=0
for m in $*
do
  MAILH[$i]=`$GETHEXEC 'web3.sha3("Print('$m')")' \
             | sed 's/^"0x\(.*\)"/\1/' \
             | tr a-f A-F`
  debug ${MAILH[$i]} $m
  echo ibase=16\; ${MAILH[$i]}-$BLOCKH \
  | bc \
  | sed -e "s/-//" \
        -e "s/$/ $m/"
  i=$[$i+1]
done \
| sort -n

