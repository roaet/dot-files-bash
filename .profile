# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Check to see if SSH Agent is already running
agent_pid="$(ps -ef | grep "ssh-agent" | grep -v "grep" | awk '{print($2)}')"
 
# If the agent is not running (pid is zero length string)
if [[ -z "$agent_pid" ]]; then
    # Start up SSH Agent
 
    # this seems to be the proper method as opposed to `exec ssh-agent bash`
    eval "$(ssh-agent)"
 
    # if you have a passphrase on your key file you may or may
    # not want to add it when logging in, so comment this out
    # if asking for the passphrase annoys you
    ssh-add
 
# If the agent is running (pid is non zero)
else
    # Connect to the currently running ssh-agent
 
    # this doesn't work because for some reason the ppid is 1 both when
    # starting from ~/.profile and when executing as `ssh-agent bash`
    #agent_ppid="$(ps -ef | grep "ssh-agent" | grep -v "grep" | awk '{print($3)}')"
    agent_ppid="$(($agent_pid - 1))"
 
    # and the actual auth socket file name is simply numerically one less than
    # the actual process id, regardless of what `ps -ef` reports as the ppid
    agent_sock="$(find /tmp -path "*ssh*" -type s -iname "agent.$agent_ppid")"
 
    echo "Agent pid $agent_pid"
    export SSH_AGENT_PID="$agent_pid"
 
    echo "Agent sock $agent_sock"
    export SSH_AUTH_SOCK="$agent_sock"
fi
