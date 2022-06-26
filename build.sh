#!/bin/bash

set -eu pipefail

rm -rf out
mkdir out

rm -rf base16-vim
git clone --depth=1 https://github.com/base16-project/base16-vim

export COLORSCHEMES=($(ls base16-vim/colors | sed 's/\..*$//'))

for COLORSCHEME in ${COLORSCHEMES[@]}; do
  echo $COLORSCHEME
  vim -es -u NORC -N \
    -c 'set termguicolors' \
    -c 'set runtimepath+=base16-vim' \
    -c 'syntax on' \
    -c "colorscheme $COLORSCHEME" \
    -c 'TOhtml' \
    -c 'wqall' \
    $0 > /dev/null 2>&1

  grep -Pzo '(?s)<style>.*</style>' $0.html \
    | sed "3,14!d;s/body/pre/;s/^/#$COLORSCHEME /" \
    > out/$COLORSCHEME.css

  grep -Pzo "(?s)<pre id='vimCodeElement'>.*</pre>" $0.html \
    > out/$COLORSCHEME.html

  rm -f $0.html
done

erb template.erb > out/index.html
