# Non-login interactive shells don't read .profile on their own
if [ -f ~/.bash_profile ]; then
  . ~/.bash_profile
elif [ -f ~/.profile ]; then
  . ~/.profile
fi
