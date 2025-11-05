#set -g fish_greeting

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -gx COLORTERM truecolor
set -gx WINEPREFIX $HOME/.wine
#set -gx LS_COLORS "di=38;5;141:ex=38;5;129:ln=38;5;135:pi=38;5;177:so=38;5;177:bd=38;5;177:cd=38;5;177:or=38;5;196:mi=38;5;196:su=38;5;129:sg=38;5;129:tw=38;5;141:ow=38;5;141:st=38;5;141"
set LS_COLORS ""
#if ! pgrep -x wmaker >/dev/null 
bash $HOME/scripts/start-wayfire.sh
#end
export GTK_THEME=Adwaita:dark
export DOTNET_ROOT=$HOME/.dotnet/
export PATH="$DOTNET_ROOT:$PATH"
export DOTNET_PACKAGES=/opt/dotnet-nugets/
alias icat="kitten icat"
#alias pkgdev="GIT_TRACE=2 pkgdev"
alias xonotic="mangohud xonotic-sdl"
alias lsmobo="dmidecode -t 2"
alias lsmem="dmidecode --type 17"
alias lmms="pw-jack lmms"
alias milkytracker="pw-jack milkytracker"
alias reload="fish_greeting"
alias wgetpaste="wgetpaste -s 0x0 -N"
alias tarxz="tar -cJvf"
alias git-fetch="git fetch upstream && git rebase upstream/master"
alias git-reset="git reset --hard origin/master && git rebase upstream/master && git push -f"
alias randr-set="wlr-randr --output HDMI-A-1 --preferred --mode 1920x1080@74.986000Hz && exit"
alias novnc-ngrok="novnc &; ngrok tcp 6080"
alias sober="flatpak run org.vinegarhq.Sober"
alias screensaver-settings="GDK_BACKEND=x11 xscreensaver-settings"
alias ls="eza --icons=always"
alias clang="clang -std=c99"
#alias helium="helium --enable-features=VaapiVideoDecoder,VaapiVideoEncoder,UseOzonePlatform --ozone-platform=wayland --use-gl=angle --use-angle=vulkan --ignore-gpu-blocklist --force-refresh-rate=100"
#alias grep="grep -RniI --color=auto --exclude-dir=.git" # R = recursive
# n = show line numbers
# i = case-insensitive
# I = exclude binary files
#if pgrep -x "wayfire"
#    tmux > /dev/null
#end

export GPG_TTY=$(tty)

export BC_ENV_ARGS="-ql $HOME/.bc"

function catsay
    if ! test -e $(which cowsay)
        echo "cowsay is not installed."
    end
    set cmd $(which cat)
    $cmd $argv | cowsay
end

if status --is-login
    set term_type (tty)
    if string match -r '/dev/tty[0-9]+' $term_type >/dev/null
        #echo "Running in a TTY (1)"
        or string match -r /dev/console $term_type >/dev/null
        #echo "Running in a TTY (2)"
        or string match -r '/dev/vc/[0-9]+' $term_type >/dev/null
        #echo "Running in a TTY (3)"
    else
        #echo "Running in a terminal emulator"
        set -gx MICRO_TRUECOLOR 1
        starship init fish | source
    end
else
    #echo "Not a login shell"
    set -gx MICRO_TRUECOLOR 1
    starship init fish | source
end

#function wgetpaste
#command wgetpaste $argv | wl-copy
#end
function pastefile
    command curl -F "file=@$argv" https://file.io | grep -o '"link":"[^"]*' | sed 's/"link":"//'
end
# Trigger a bell when pressing backspace at the beginning of the line
function fish_mode_changed
    # If backspace is pressed at the beginning of the line, play the bell sound
    bind \b 'beginning-of-line; test -z (commandline); if test $? -eq 0; beep; end'
end

# pnpm
set -gx PNPM_HOME "/home/charlotte/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

function rcc
    set arg_count (count $argv)

    if test $arg_count -eq 0
        echo "Usage: rcc <url> [<url> ...] [destination]"
        return 1
    end

    if test $arg_count -eq 1
        # One URL, no destination — save to current dir
        rclone copyurl --progress --auto-filename $argv[1] .
    else
        # Check if last argument is a directory
        if test -d $argv[-1]
            set dest $argv[-1]
            set urls $argv[1..-2]
        else
            # No existing directory given — default to current dir
            set dest .
            set urls $argv
        end

        for url in $urls
            rclone copyurl --progress --auto-filename $url $dest
        end
    end
end

function print_memory_usage
    ps -eo cmd,rss --sort=-rss | head -n 21 | tail -n +2 | awk '{rss=$NF; $NF=""; printf "%s: %.2f MiB\n", $0, rss/1024; sum+=rss} END {printf "\nTotal: %.3f GiB\n", sum/1024/1024}'
end

function to_lower
    if ! type rename >/dev/null
        echo "`rename` must be installed to use this function!"
        exit 1
    end

    set location $argv[1]
    set _type ""

    if test "$argv[1]" = -d
        set location $argv[2]
        set _type d
    else if test "$argv[1]" = -f
        set location $argv[2]
        set _type f
    end

    if test -n "$_type"
        find "$location" -type $_type -exec rename y/A-Z/a-z/ {} +
    else
        find "$location" -exec rename y/A-Z/a-z/ {} +
    end
end

function to_upper
    if ! type rename >/dev/null
        echo "`rename` must be installed to use this function!"
        exit 1
    end

    set location $argv[1]
    set _type ""

    if test "$argv[1]" = -d
        set location $argv[2]
        set _type d
    else if test "$argv[1]" = -f
        set location $argv[2]
        set _type f
    end

    if test -n "$_type"
        find "$location" -type $_type -exec rename y/a-z/A-Z/ {} +
    else
        find "$location" -exec rename y/a-z/A-Z/ {} +
    end
end

function luks-mount
    if not test $argv
        echo "please give /dev mountpoint"
    end
    if not test -e /dev/mapper/gpg
        sudo cryptsetup open "/dev/$argv" gpg
    end
    sudo mkdir -p /mnt/gpg
    sudo mount /dev/mapper/gpg /mnt/gpg
end

function luks-unmount
    set current_dir (realpath (pwd))
    set mount_dir (realpath /mnt/gpg)

    if test "$current_dir" = "$mount_dir"
        printf "%s %s %s\n" "ERROR: "(status current-function)": Cannot unmount. Make sure you're not in /mnt/gpg!"
        return 1
    end

    sudo umount /mnt/gpg

    if test -e /dev/mapper/gpg
        sudo cryptsetup close gpg
    else
        printf "%s %s %s\n" "ERROR: "(status current-function)": /dev/mapper/gpg still exists. Cannot continue."
    end
end

function protontricks
    flatpak run com.github.Matoking.protontricks $argv
end
