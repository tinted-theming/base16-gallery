#!/bin/bash

set -eu pipefail

setup() {
  rm -rf out
  mkdir out

  rm -rf tinted-vim
  git clone --depth=1 https://github.com/tinted-theming/tinted-vim

  rm -rf schemes
  git clone --depth=1 https://github.com/tinted-theming/schemes
}

main() {
  setup

  colorschemes=($(ls schemes/base16/ | grep yaml | sed 's/\..*$//'))
  tmpfile="$0.html"

  vim -es -u NORC -N \
    -c 'silent! set termguicolors' \
    -c 'silent! set runtimepath+=base16-vim' \
    -c 'silent! syntax on' \
    -c "silent! colorscheme base16-${colorschemes[0]}" \
    -c 'silent! TOhtml' \
    -c 'silent! wqa!' \
    $0 > /dev/null 2>&1
  awk "/<pre id='vimCodeElement'>/{flag=1; next} /<\/pre>/{flag=0} flag" $tmpfile > out/shell.html

  for colorscheme in ${colorschemes[@]}; do
    echo $colorscheme

    vim -es -u NORC -N \
      -c 'set termguicolors' \
      -c 'set runtimepath+=tinted-vim' \
      -c 'syntax on' \
      -c "colorscheme base16-$colorscheme" \
      -c 'TOhtml' \
      -c 'wqall' \
      $0 > /dev/null 2>&1

    grep -Pzo '(?s)<style>.*</style>' $tmpfile \
      | sed "3,14!d;s/body/pre/;s/^/#base16-$colorscheme /" \
      > out/$colorscheme.css

    rm -f $tmpfile
  done

  erb template.erb > out/index.html
}

main
