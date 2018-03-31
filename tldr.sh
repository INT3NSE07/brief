#!/usr/bin/env bash
set +vx -o pipefail
[[ $- = *i* ]] && echo "Don't source this script!" && return 1
: "${TLDR_TITLE_STYLE:= Newline Space Bold Yellow }"
: "${TLDR_DESCRIPTION_STYLE:= Space Yellow }"
: "${TLDR_EXAMPLE_STYLE:= Newline Space Bold Green }"
: "${TLDR_CODE_STYLE:= Space Bold Blue }"
: "${TLDR_VALUE_ISTYLE:= Space Bold Cyan }"
# The Value style (above) is an Inline style: doesn't take Newline or Space
# Inline styles for help text: default, URL, option, platform, command, header
: "${TLDR_DEFAULT_ISTYLE:= White }"
: "${TLDR_URL_ISTYLE:= Yellow }"
: "${TLDR_HEADER_ISTYLE:= Bold }"
: "${TLDR_OPTION_ISTYLE:= Bold Yellow }"
: "${TLDR_PLATFORM_ISTYLE:= Bold Blue }"
: "${TLDR_COMMAND_ISTYLE:= Bold Cyan }"
: "${TLDR_FILE_ISTYLE:= Bold Magenta }"
# Color/BG (Newline and Space also allowed) for error and info messages
: "${TLDR_ERROR_COLOR:= Newline Space Red }"
: "${TLDR_INFO_COLOR:= Newline Space Green }"

# Alternative location of pages cache
: "${TLDR_CACHE:= .}"

# Usage of 'less' or 'cat' for output (set to '0' for cat)
: "${TLDR_LESS:= }"

# $1: [optional] exit code; Uses: version cachedir
Usage(){
	Out "$(cat <<-EOF

		 ${HDE}USAGE: $HHE$(basename "$0")$XHHE [${HOP}option$XHOP] [${HPL}platform$XHPL/]${HCO}command$XHCO

		 $HDE[${HPL}platform$XHPL/]${HCO}command$XHCO:          Show page for ${HCO}command$XHCO (from ${HPL}platform$XHPL)

		 ${HDE}Element styling:$XHDE ${T}Title$XT ${D}Description$XD ${E}Example$XE ${C}Code$XC ${V}Value$XV

		 ${HOP}option$XHOP is optionally one of:
		  $HOP-s$XHOP, $HOP--search$XHOP ${HFI}regex$XHFI:         Search for ${HFI}regex$XHFI in all tldr pages
		  $HOP-l$XHOP, $HOP--list$XHOP [${HPL}platform$XHPL]:      List all pages (from ${HPL}platform$XHPL)
		  $HOP-a$XHOP, $HOP--list-all$XHOP:             List all pages from current platform + common
		  $HDE[$HOP-h$XHOP, $HOP-?$XHOP, $HOP--help$XHOP]:           This help overview

		EOF
	)"
	exit "${1:-0}"
}

# $1: keep output; Uses/Sets: stdout
Out(){ stdout+=$1$N;}

# $1: keep error messages
Err(){ Out "$ERRNL$ERRSP$ERR$B$1$XB$XERR";}

# $1: keep info messages
Inf(){ Out "$INFNL$INFSP$INF$B$1$XB$XINF";}

# $1: Style specification; Uses: color xcolor bg xbg mode xmode
Style(){
	local -l style
	STYLES='' XSTYLES='' COLOR='' XCOLOR='' NL='' SP=''
	for style in $1
	do
		[[ $style = newline ]] && NL=$N
		[[ $style = space ]] && SP=' '
		COLOR+=${color[$style]:-}${bg[$style]:-}
		XCOLOR=${xbg[$style]:-}${xcolor[$style]:-}$XCOLOR
		STYLES+=${color[$style]:-}${bg[$style]:-}${mode[$style]:-}
		XSTYLES=${xmode[$style]:-}${xbg[$style]:-}${xcolor[$style]:-}$XSTYLES
	done
}	

# Sets: color xcolor bg xbg mode xmode
Init_term(){
	[[ -t 2 ]] && {  # only if interactive session (stderr open)
			B=$'\e[1m' # $(tput bold || tput md)  # Start bold
			XB=$'\e[0m'  # End bold (no tput code...)
			U=$'\e[4m' # $(tput smul || tput us)  # Start underline
			XU=$'\e[24m' # $(tput rmul || tput ue)  # End underline
			I=$'\e[3m' # $(tput sitm || tput ZH)  # Start italic
			XI=$'\e[23m' # $(tput ritm || tput ZR)  # End italic
			R=$'\e[7m' # $(tput smso || tput so)  # Start reverse
			XR=$'\e[27m' # $(tput rmso || tput se)  # End reverse
			#X=$'\e[0m' # $(tput sgr0 || tput me)  # End all

		[[ $TERM != *-m ]] && {
				BLA=$'\e[30m' # $(tput setaf 0 || tput AF 0)
				RED=$'\e[31m' # $(tput setaf 1 || tput AF 1)
				GRE=$'\e[32m' # $(tput setaf 2 || tput AF 2)
				YEL=$'\e[33m' # $(tput setaf 3 || tput AF 3)
				BLU=$'\e[34m' # $(tput setaf 4 || tput AF 4)
				MAG=$'\e[35m' # $(tput setaf 5 || tput AF 5)
				CYA=$'\e[36m' # $(tput setaf 6 || tput AF 6)
				WHI=$'\e[37m' # $(tput setaf 7 || tput AF 7)
				DEF=$'\e[39m' # $(tput op)
				BLAB=$'\e[40m' # $(tput setab 0 || tput AB 0)
				REDB=$'\e[41m' # $(tput setab 1 || tput AB 1)
				GREB=$'\e[42m' # $(tput setab 2 || tput AB 2)
				YELB=$'\e[43m' # $(tput setab 3 || tput AB 3)
				BLUB=$'\e[44m' # $(tput setab 4 || tput AB 4)
				MAGB=$'\e[45m' # $(tput setab 5 || tput AB 5)
				CYAB=$'\e[46m' # $(tput setab 6 || tput AB 6)
				WHIB=$'\e[47m' # $(tput setab 7 || tput AB 7)
				DEFB=$'\e[49m' # $(tput op)
		}
	}

	declare -A color=(['black']=$BLA ['red']=$RED ['green']=$GRE ['yellow']=$YEL \
			['blue']=$BLU ['magenta']=$MAG ['cyan']=$CYA ['white']=$WHI)
	declare -A xcolor=(['black']=$DEF ['red']=$DEF ['green']=$DEF ['yellow']=$DEF \
			['blue']=$DEF ['magenta']=$DEF ['cyan']=$DEF ['white']=$DEF)
	declare -A bg=(['blackbg']=$BLAB ['redbg']=$REDB ['greenbg']=$GREB ['yellowbg']=$YELB \
			['bluebg']=$BLUB ['magentabg']=$MAGB ['cyanbg']=$CYAB ['whitebg']=$WHIB)
	declare -A xbg=(['blackbg']=$DEFB ['redbg']=$DEFB ['greenbg']=$DEFB ['yellowbg']=$DEFB \
			['bluebg']=$DEFB ['magentabg']=$DEFB ['cyanbg']=$DEFB ['whitebg']=$DEFB)
	declare -A mode=(['bold']=$B ['underline']=$U ['italic']=$I ['inverse']=$R)
	declare -A xmode=(['bold']=$XB ['underline']=$XU ['italic']=$XI ['inverse']=$XR)

	# the 5 main tldr page styles and error message colors
	Style "$TLDR_TITLE_STYLE"
	T=$STYLES XT=$XSTYLES TNL=$NL TSP=$SP
	Style "$TLDR_DESCRIPTION_STYLE"
	D=$STYLES XD=$XSTYLES DNL=$NL DSP=$SP
	Style "$TLDR_EXAMPLE_STYLE"
	E=$STYLES XE=$XSTYLES ENL=$NL ESP=$SP
	Style "$TLDR_CODE_STYLE"
	C=$STYLES XC=$XSTYLES CNL=$NL CSP=$SP
	Style "$TLDR_VALUE_ISTYLE"
	V=$STYLES XV=$XSTYLES
	Style "$TLDR_DEFAULT_ISTYLE"
	HDE=$STYLES XHDE=$XSTYLES
	Style "$TLDR_URL_ISTYLE"
	URL=$STYLES XURL=$XSTYLES
	HUR=$XHDE$STYLES XHUR=$XSTYLES$HDE
	Style "$TLDR_OPTION_ISTYLE"
	HOP=$XHDE$STYLES XHOP=$XSTYLES$HDE
	Style "$TLDR_PLATFORM_ISTYLE"
	HPL=$XHDE$STYLES XHPL=$XSTYLES$HDE
	Style "$TLDR_COMMAND_ISTYLE"
	HCO=$XHDE$STYLES XHCO=$XSTYLES$HDE
	Style "$TLDR_FILE_ISTYLE"
	HFI=$XHDE$STYLES XHFI=$XSTYLES$HDE
	Style "$TLDR_HEADER_ISTYLE"
	HHE=$XHDE$STYLES XHHE=$XSTYLES$HDE
	Style "$TLDR_ERROR_COLOR"
	ERR=$COLOR XERR=$XCOLOR ERRNL=$NL ERRSP=$SP
	Style "$TLDR_INFO_COLOR"
	INF=$COLOR XINF=$XCOLOR INFNL=$NL INFSP=$SP
}

Config(){
	type -p less >/dev/null || TLDR_LESS=0

	os=common stdout='' Q='"' N=$'\n'
    os='linux'
	Init_term
	[[ $TLDR_LESS = 0 ]] && 
		trap 'cat <<<"$stdout"' EXIT ||
		trap 'less -~RXQFP"Browse up/down, press Q to exit " <<<"$stdout"' EXIT

	cachedir=$(echo $TLDR_CACHE)
	[[ -d "$cachedir" ]] || mkdir -p "$cachedir" || {
		Err "Can't create the pages cache location $cachedir"
		exit 4
	}

	index=$cachedir/index.json
}

# $1: page; Uses: index cachedir pages_url platform os dl cached md
# Sets: cached md
Get_tldr(){
	local desc err=0 notfound
	# convert the local platform name to tldr's version
	# extract the platform key from index.json, return preferred subpath to page
	desc=$(tr '{' '\n' <"$index" |grep "\"name\":\"$1\"")
	# results in, eg, "name":"netstat","platform":["linux","osx"]},

	[[ $desc ]] || return  # nothing found

	# if no page found yet, try the system platform
	[[ $md ]] || [[ $platform = $os ]] || {
			[[ $desc =~ \"$os\" ]] && md=$os/$1.md
	} || {
		notfound+=" or $I$os$XI"
		err=1
	}

	# return the local cached copy of the tldrpage, or retrieve and cache from github
	cached=$cachedir/$md
}

# $1: file (optional); Uses: page stdout; Sets: ln REPLY
Display_tldr(){
	local newfmt len val
	ln=0 REPLY=''
	[[ $md ]] || md=$1
	# Read full lines, and process even when no newline at the end
	while read -r || [[ $REPLY ]]
	do
		((++ln))
		((ln==1)) && {
			[[ ${REPLY:0:1} = '#' ]] && newfmt=0 || newfmt=1
			((newfmt)) && {
				[[ $REPLY ]] || Unlinted "Empty title"
				Out "$TNL$TSP$T$REPLY$XT"
				len=${#REPLY}  # title length
				read -r
				((++ln))
				[[ $REPLY =~ [^=] ]] && Unlinted "Title underline must be equal signs"
				((len!=${#REPLY})) && Unlinted "Underline length not equal to title's"
				read -r
				((++ln))
			}
		}
		case "${REPLY:0:1}" in  # first character
			'#') ((newfmt)) && Unlinted "Bad first character"
				((${#REPLY} <= 2)) && Unlinted "No title"
				[[ ! ${REPLY:1:1} = ' ' ]] && Unlinted "2nd character no space"
				Out "$TNL$TSP$T${REPLY:2}$XT" ;;
			'>') ((${#REPLY} <= 3)) && Unlinted "No valid desciption"
				[[ ! ${REPLY:1:1} = ' ' ]] && Unlinted "2nd character no space"
				[[ ! ${REPLY: -1} = '.' ]] && Unlinted "Description doesn't end in full stop"
				Out "$DNL$DSP$D${REPLY:2}$XD"
				DNL='' ;;
			'-') ((newfmt)) && Unlinted "Bad first character"
				((${#REPLY} <= 2)) && Unlinted "No example content"
				[[ ! ${REPLY:1:1} = ' ' ]] && Unlinted "2nd character no space"
				Out "$ENL$ESP$E${REPLY:2}$XE" ;;
			' ') ((newfmt)) || Unlinted "Bad first character"
				((${#REPLY} <= 4)) && Unlinted "No valid code content"
				[[ ${REPLY:0:4} = '    ' ]] || Unlinted "No four spaces before code"
				val=${REPLY:4}
				# Value: convert {{value}}
				val=${val//\{\{/$CX$V}
				val=${val//\}\}/$XV$C}
				Out "$CNL$CSP$C$val$XC" ;;
			'`') ((newfmt)) && Unlinted "Bad first character"
				((${#REPLY} <= 2)) && Unlinted "No valid code content"
				[[ ! ${REPLY: -1} = '`' ]] && Unlinted "Code doesn't end in backtick"
				val=${REPLY:1:${#REPLY}-2}
				# Value: convert {{value}}
				val=${val//\{\{/$CX$V}
				val=${val//\}\}/$XV$C}
				Out "$CNL$CSP$C$val$XC" ;;
			'') continue ;;
			*) ((newfmt)) || Unlinted "Bad first character"
				[[ -z $REPLY ]] && Unlinted "No example content"
				Out "$ENL$ESP$E$REPLY$XE" ;;
		esac
	done <"$1"
	[[ $TLDR_LESS = 0 ]] && 
		trap 'cat <<<"$stdout"' EXIT ||
		trap 'less +Gg -~RXQFP"%pB\% tldr $I$page$XI - browse up/down, press Q to exit" <<<"$stdout"' EXIT
}

# $1: exit code; Uses: platform index
List_pages(){
	local platformtext c1 c2 c3
	[[ $platform ]] && platformtext="platform $I$platform$XI" ||
		platform=^ platformtext="${I}all$XI platforms"
	[[ $platform = current ]] && platform="-e $os -e common" &&
		platformtext="$I$os$XI platform and ${I}common$XI"
	Inf "Known tldr pages from $platformtext:"
	Out "$(while read -r c1 c2 c3; do printf "%-19s %-19s %-19s %-19s$N" $c1 $c2 $c3; done \
			<<<$(tr '{' '\n' <"$index" |grep $platform |cut -d "$Q" -f4))"
	exit "$1"
}

# $1: regex, $2: exit code; Uses: cachedir
Find_regex(){
	local list=$(grep "$1" "$cachedir"/*/*.md |cut -d: -f1) regex="$U$1$XU"
	local n=$(wc -l <<<"$list")
	list=$(sort -u <<<"$list")
	[[ -z $list ]] && Err "Regex $regex not found" && exit 6
	local t=$(wc -l <<<"$list")
	if ((t==1))
	then
		Display_tldr "$list"
	else
		Inf "Regex $regex $I$n$XI times found in these $I$t$XI tldr pages:"
		Out "$(while read -r c1 c2 c3; do printf "%-19s %-19s %-19s %-19s$N" $c1 $c2 $c3; done \
			<<<$(sed -e 's@.*/@@' -e 's@...$@@' <<<"$list"))"
	fi
	exit "$2"
}

# $@: commandline parameters; Uses: version cached; Sets: platform page
Main(){
	local markdown=0 err=0 nomore='No more command line arguments allowed'
	Config
	case "$1" in
	-s|--search) [[ -z $2 ]] && Err "Search term (regex) needed" && Usage 10
		[[ $3 ]] && Err "$nomore" && err=11
		Find_regex "$2" "$err" ;;
	-l|--list) [[ $2 ]] && {
			platform=$2
			[[ ,common,linux,osx,sunos,windows,current, != *,$platform,* ]] &&
				Err "Unknown platform $I$platform$XI" && Usage 12
			[[ $3 ]] && Err "$nomore" && err=13
		}
		List_pages "$err" ;;
	-a|--list-all) [[ $2 ]] && Err "$nomore" && err=14
		platform=current
		List_pages $err ;;
	-r|--render) [[ -z $2 ]] && Err "Specify a file to render" && Usage 17
		[[ $3 ]] && Err "$nomore" && err=18
		[[ -f "$2" ]] && {
			Display_tldr "$2" && exit "$err"
			Err "A file error occured"
			exit 19
		} || Err "No file: ${I}$2$XI" && exit 20 ;;
	-m|--markdown) shift
		page=$*
		[[ -z $page ]] && Err "Specify a page to display" && Usage 21
		[[ -f "$page" && ${page: -3:3} = .md ]] && Out "$(cat "$page")" && exit 0
		markdown=1 ;;
	''|-h|-\?|--help) [[ $2 ]] && Err "$nomore" && err=22
		Usage "$err" ;;
	-*) Err "Unrecognized option $I$1$XI"; Usage 23 ;;
	*) page=$* ;;
	esac

	[[ -z $page ]] && Err "No command specified" && Usage 24
	[[ ${page:0:1} = '-' || $page = *' '-* ]] && Err "Only one option allowed" && Usage 25
	[[ $page = */* ]] && platform=${page%/*} && page=${page##*/}
	[[ $platform && ,common,linux,osx,sunos,windows, != *,$platform,* ]] && {
		Err "Unknown platform $I$platform$XI"
		Usage 26
	}

	Get_tldr "${page// /-}"
	[[ ! -s $cached ]] && Err "page for command $I$page$XI not found" && exit 27
	((markdown)) && Out "$(cat "$cached")" || Display_tldr "$cached"
}

Main "$@"
exit 0
