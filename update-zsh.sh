#!/usr/bin/env zsh
echo $ZSH
cd ~/.oh-my-zsh
git status
git stash
$ZSH/tools/upgrade.sh

#upgrade_oh_my_zsh
git stash pop
