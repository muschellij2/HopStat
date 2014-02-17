
So I was looking around how to change [Terminal tab names](http://reviews.cnet.com/8301-13727_7-57475154-263/how-to-use-ssh-host-names-for-tabs-in-the-os-x-terminal/).  I want the tab name to change to the current working directory if I'm on my local system and to "Enigma" if I'm on our cluster host computer and "Node" if I'm on a cluster node.  

After some tweaking, I found a solution that I like.  

In my `~/.bashrc` file, I have:


```bash
function tabname {
  x="$1"
  export PROMPT_COMMAND='echo -ne "\033]0;${x}\007"'
  # printf "\e]1;$1\a"
}
### changing tab names
tname=`hostname | awk '/enigma/ { print "Enigma"; next; } { print "Node" }'`
tabname "$tname"

```

which essentially just does a regular expression for the word `enigma` using the `hostname` command.  It then assigns this to a bash variable `tname` and then `tabname` assigns that tab name.

In my personal `~/.bashrc`, I added:


```bash
function tabname {
  x="$1"
  export PROMPT_COMMAND='echo -ne "\033]0;${x}\007"'
  # printf "\e]1;$1\a"
}
### changing tab names
tname=`hostname | awk -v PWD=$PWD '/macbook/ { print PWD; next; }'`
tabname "$tname"

```


so that when I'm on my `macbook` (change this as needed for your machine), it will have the working directory as the tab name.  Now, yes, I know that Terminal usually puts the working directory in the window name, but I find that I tend to not look at that and only tab names.

Now, you can combine these to have:

```bash
tname=`hostname | awk -v PWD=$PWD '/enigma/ { print "Enigma: " PWD; next; } { print "Node: " PWD }'`
```

if you want to describe where you are on the cluster.

Here's the result:

![Tabs](https://dl.dropboxusercontent.com/u/600586/WordPress_Hopstat/Changing_Tab_Names/tab_names.png)


This worked great on our cluster, but remained when I exited an ssh session, so I'm still tweaking.  Any comments would be appreciated.
