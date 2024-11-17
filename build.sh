#!/bin/bash

set -eu pipefail

rm -rf out
mkdir out

rm -rf base16-vim
git clone --depth=1 https://github.com/tinted-theming/base16-vim

rm -rf schemes
git clone --depth=1 https://github.com/tinted-theming/schemes

export COLORSCHEMES=($(ls schemes/base16/ | grep yaml | sed 's/\..*$//'))

for COLORSCHEME in ${COLORSCHEMES[@]}; do
  echo $COLORSCHEME

  vim -es -u NORC -N \
    -c 'silent! set termguicolors' \
    -c 'silent! set runtimepath+=base16-vim' \
    -c 'silent! syntax on' \
    -c "silent! colorscheme base16-$COLORSCHEME" \
    -c 'silent! TOhtml' \
    -c 'silent! wqa!' \
    $0 > /dev/null 2>&1

  grep -Pzo '(?s)<style>.*</style>' $0.html \
    | sed "3,14!d;s/body/pre/;s/^/#base16-$COLORSCHEME /" \
    > out/$COLORSCHEME.css

  awk "/<pre id='vimCodeElement'>/,/<\/pre>/" $0.html \
    > out/$COLORSCHEME.html

  rm -f $0.html
done

erb template.erb > out/index.html
