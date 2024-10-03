#!/bin/bash

#  Dev Set Up
apt-get update -y
apt-get install -y tmux vim quota

cat <<EOF > /home/ubuntu/.tmux.conf
set-option -g history-limit 25000
set-option -g prefix C-x
set-option -g default-command "bash -l"
set -g mouse on
set -s escape-time 0

# ui
set -g status-right "#S"
set -g status-right-style "fg=#ff5555"
set -g status-style "fg=#aa91e3,bold"
set -g status-left-style "fg=#928374"
set -g status-bg default
set -g status-position bottom
set -g status-interval 1
set -g status-left ""
set-option -g default-terminal "screen-256color"

# bind keys
bind-key -r r source-file ~/.tmux.conf
bind-key -r k run-shell "pkill -f tmux"
EOF

cat <<EOF > /home/ubuntu/.vimrc
syntax on
colo elflord

set number relativenumber
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set cursorline

set smartindent

set undofile

set hlsearch
set incsearch

set scrolloff=8

set updatetime=50

set colorcolumn=80

let mapleader = " "

nnoremap <leader>pv :Ex<CR>

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv

nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>
EOF

chown ubuntu:ubuntu /home/ubuntu/.tmux.conf
chown ubuntu:ubuntu /home/ubuntu/.vimrc

# Docker
curl -fsSl https://get.docker.com | sh
sudo groupadd docker
sudo usermod -aG docker $USER