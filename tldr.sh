#!/usr/bin/env bash
set +vx -o pipefail
[[ $- = *i* ]] && echo "Don't source this script!" && return 1
: "${TLDR_TITLE_STYLE:= Newline Space Bold Yellow }"
: "${TLDR_DESCRIPTION_STYLE:= Space Yellow }"
: "${TLDR_EXAMPLE_STYLE:= Newline Space Bold Green }"
: "${TLDR_CODE_STYLE:= Space Bold Blue }"
: "${TLDR_VALUE_ISTYLE:= Space Bold Cyan }"
: "${TLDR_DEFAULT_ISTYLE:= White }"
: "${TLDR_URL_ISTYLE:= Yellow }"
: "${TLDR_HEADER_ISTYLE:= Bold }"
: "${TLDR_OPTION_ISTYLE:= Bold Yellow }"
: "${TLDR_PLATFORM_ISTYLE:= Bold Blue }"
: "${TLDR_COMMAND_ISTYLE:= Bold Cyan }"
: "${TLDR_FILE_ISTYLE:= Bold Magenta }"
: "${TLDR_ERROR_COLOR:= Newline Space Red }"
: "${TLDR_INFO_COLOR:= Newline Space Green }"
: "${TLDR_CACHE:= .}"

usage(){
	Out "$(cat <<-EOF

		 ${HDE}USAGE: $HHE$(basename "$0")$XHHE [${HOP}option$XHOP] ${HCO}command$XHCO

		 ${HCO}command$XHCO:                      Show page for ${HCO}command$XHCO

		 ${HOP}option$XHOP is optionally one of:
		  $HOP-s$XHOP, $HOP--search$XHOP ${HFI}regex$XHFI:          Search for ${HFI}regex$XHFI in all tldr pages
		  $HOP-a$XHOP, $HOP--list-all$XHOP:              List all pages
		  $HDE[$HOP-h$XHOP, $HOP-?$XHOP, $HOP--help$XHOP]:            This help overview

		 ${HDE}Element styling:$XHDE ${T}Title$XT ${D}Description$XD ${E}Example$XE ${C}Code$XC ${V}Value$XV

		EOF
	)"
	exit "${1:-0}"
}

Out(){ stdout+=$1$N;}

Err(){ Out "$ERRNL$ERRSP$ERR$B$1$XB$XERR";}

Inf(){ Out "$INFNL$INFSP$INF$B$1$XB$XINF";}

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

init_term(){
	[[ -t 2 ]] && {
			B=$'\e[1m'
			XB=$'\e[0m'
			U=$'\e[4m'
			XU=$'\e[24m'
			I=$'\e[3m'
			XI=$'\e[23m'
			R=$'\e[7m'
			XR=$'\e[27m'

		[[ $TERM != *-m ]] && {
				BLA=$'\e[30m'
				RED=$'\e[31m'
				GRE=$'\e[32m'
				YEL=$'\e[33m'
				BLU=$'\e[34m'
				MAG=$'\e[35m'
				CYA=$'\e[36m'
				WHI=$'\e[37m'
				DEF=$'\e[39m'
				BLAB=$'\e[40m'
				REDB=$'\e[41m'
				GREB=$'\e[42m'
				YELB=$'\e[43m'
				BLUB=$'\e[44m'
				MAGB=$'\e[45m'
				CYAB=$'\e[46m'
				WHIB=$'\e[47m'
				DEFB=$'\e[49m'
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

config(){
	type -p less >/dev/null
	os=common stdout='' Q='"' N=$'\n'
    os='linux'
	init_term
    trap 'less -~RXQFP"Browse up/down, press Q to exit " <<<"$stdout"' EXIT
	cachedir=$(echo $TLDR_CACHE)
	[[ -d "$cachedir" ]] || mkdir -p "$cachedir" || {
		Err "Can't create the pages cache location $cachedir"
		exit 4
	}
	index=$cachedir/index.json
}

Get_tldr(){
	local desc err=0 notfound
	desc=$(tr '{' '\n' <"$index" |grep "\"name\":\"$1\"")

	[[ $desc ]] || return  # nothing found

	[[ $md ]] || [[ $platform = $os ]] || {
			[[ $desc =~ \"$os\" ]] && md=$os/$1.md
	} || {
		notfound+=" or $I$os$XI"
		err=1
	}

	cached=$cachedir/$md
}

display(){
	local newfmt len val
	ln=0 REPLY=''
	[[ $md ]] || md=$1
	while read -r || [[ $REPLY ]]
	do
		((++ln))
		((ln==1)) && {
			[[ ${REPLY:0:1} = '#' ]] && newfmt=0 || newfmt=1
			((newfmt)) && {
				[[ $REPLY ]] || Unlinted "Empty title"
				Out "$TNL$TSP$T$REPLY$XT"
				len=${#REPLY}
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
    trap 'less +Gg -~RXQFP"%pB\% tldr $I$page$XI - browse up/down, press Q to exit" <<<"$stdout"' EXIT
}

list_pages(){
	local platformtext c1 c2 c3
    platformtext="$I$os$XI platform"
	Inf "Known pages from $platformtext:"
	Out "$(while read -r c1 c2 c3; do printf "%-19s %-19s %-19s %-19s$N" $c1 $c2 $c3; done \
			<<<$(tr '{' '\n' <"$index" |grep $platform |cut -d "$Q" -f4))"
	exit "$1"
}

find_regex(){
	local list=$(grep -P "$1" "$cachedir"/*/*.md |cut -d: -f1) regex="$U$1$XU"
	local n=$(wc -l <<<"$list")
	list=$(sort -u <<<"$list")
	[[ -z $list ]] && Err "Regex $regex not found" && exit 6
	local t=$(wc -l <<<"$list")
	if ((t==1))
	then
		display "$list"
	else
		Inf "Regex $regex $I$n$XI times found in these $I$t$XI tldr pages:"
		Out "$(while read -r c1 c2 c3; do printf "%-19s %-19s %-19s %-19s$N" $c1 $c2 $c3; done \
			<<<$(sed -e 's@.*/@@' -e 's@...$@@' <<<"$list"))"
	fi
	exit "$2"
}

main(){
	local err=0 nomore='No more command line arguments allowed'
	config
	case "$1" in
	-s|--search) [[ -z $2 ]] && Err "Search term (regex) needed" && usage 10
		[[ $3 ]] && Err "$nomore" && err=11
		find_regex "$2" "$err" ;;
	-a|--list-all) [[ $2 ]] && Err "$nomore" && err=14
		platform=linux
		list_pages $err ;;
	''|-h|-\?|--help) [[ $2 ]] && Err "$nomore" && err=22
		usage "$err" ;;
	-*) Err "Unrecognized option $I$1$XI"; usage 23 ;;
	*) page=$* ;;
	esac

	[[ -z $page ]] && Err "No command specified" && usage 24
	[[ ${page:0:1} = '-' || $page = *' '-* ]] && Err "Only one option allowed" && usage 25
	[[ $page = */* ]] && platform=${page%/*} && page=${page##*/}
	
	Get_tldr "${page// /-}"
	[[ ! -s $cached ]] && Err "page for command $I$page$XI not found" && exit 27
	display "$cached"
}

main "$@"
exit 0
