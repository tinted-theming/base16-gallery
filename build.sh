#!/usr/bin/env bash

set -eu pipefail

main() {
  setup

  generate_themes "base16"
  generate_themes "base24"

  erb template.erb > out/index.html
}

setup() {
  if [ -z "$(command -v 'vim')" ]; then
    echo "Error: vim is required for build."
    exit 1
  fi

  rm -rf out
  mkdir out

  rm -rf tinted-vim
  git clone --depth=1 https://github.com/tinted-theming/tinted-vim

  rm -rf schemes
  git clone --depth=1 https://github.com/tinted-theming/schemes
}

generate_themes() {
  local system=${1:-"base16"}

  colorschemes=($(ls "schemes/$system/" | grep yaml | sed 's/\..*$//'))
  tmpfile="$0.html"

  vim -es -u NORC -N \
    -c 'silent! set termguicolors' \
    -c 'silent! set runtimepath+=tinted-vim' \
    -c 'silent! syntax on' \
    -c "silent! colorscheme $system-${colorschemes[0]}" \
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
      -c "colorscheme $system-$colorscheme" \
      -c 'TOhtml' \
      -c 'wqall' \
      $0 > /dev/null 2>&1

    grep -Pzo '(?s)<style>.*</style>' $tmpfile \
      | sed "3,14!d;s/body/pre/;s/^/#$system-$colorscheme /" \
      > "out/$system-$colorscheme.css"

    rm -f $tmpfile
  done
}

main
