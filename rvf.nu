def openNvim [ ] {
    if ($env.FZF_SELECT_COUNT == null or $env.FZF_SELECT_COUNT == 0) {
        'nvim {1} +{2}'
  } else {
        'nvim +cw -q {+f}'
  }
}


# ripgrep->fzf->vim [QUERY]
export def rfv [query] {
  let RELOAD = 'reload:rg --column --color=always --smart-case {q}'
  let becomeOrExecute =  if ($nu.os-info.name == 'windows') {
    'execute'
  } else {
    'become'
  }


  (fzf --disabled --ansi --multi
       --bind $"start:($RELOAD)" --bind $"change:($RELOAD)"
       --bind $"enter:($becomeOrExecute):(openNvim)"
       --bind $"ctrl-o:execute:(openNvim)"
       --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview'
       --delimiter :
       --preview 'bat --style=full --color=always --highlight-line {2} {1}'
       --preview-window '~4,+{2}+4/3,<80(up)'
       --query "load")
}