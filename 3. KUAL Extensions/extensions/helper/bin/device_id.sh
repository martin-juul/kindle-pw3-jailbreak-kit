#!/bin/sh
##
#
#  Detailed device identification
#
#  $Id: device_id.sh 16746 2019-12-02 19:30:01Z NiLuJe $
#
##

# Defaults...
device_type="Unknown"
boardname="Unknown"
boardplat="Unknown"
boardrev="Unknown"
boardtype="Unknown"
fw_build="Unknown"
fw_ver="Unknown"
kmodel="??"
devicemodel="Unknown"

# Handle both legacy & upstart devices...
if [ -f /etc/upstart/functions ] ; then
	# We're on a recent device
	device_type="upstart"
	source /etc/upstart/functions

	# Board
	boardname="$(f_board)"

	# Platform
	boardplat="$(f_platform)"

	# Revision
	boardrev="$(f_rev)"

	# Hardware build type
	# NOTE: Apparently, that info went poof in those devices? Assume Prod.
	boardtype="Production?"
elif [ -f /etc/rc.d/features ] ; then
	# We're on a legacy device
	device_type="legacy"
	source /etc/rc.d/features

	# Board
	boardname="$(productid)"

	# Platform
	if is_Mario_Platform ; then
		boardplat="Mario"
	elif is_Luigi_Platform ; then
		boardplat="Luigi"
	elif is_Yoshi_Platform ; then
		boardplat="Yoshi"
	else
		# NOTE: Assume Mario for K2 & DX! (they don't have any is_*_Platform functions)
		boardplat="Mario?"
	fi
	# NOTE: This is broken on the K4, because the platform checks only compare against the first character
	# of the board name, and thus Tequila is detected as Turing (and Sauza as Shasta?),
	# which leads to a bogus platform. Fix it on our end.
	# NOTE: I test the full boardname myself instead of using is_Tequila and is_Sauza,
	# because I don't have a K4B to check the accuracy of the 'Sauza' name...
	if [ "${boardname}" == "Tequila" -o "${boardname}" == "Sauza" ] ; then
		# By elimination, it can only be Yoshi, and that's been confirmed.
		boardplat="Yoshi"
	fi

	# Revision
	boardrev="$(hwrevision)"

	# Hardware build type
	boardtype="$(hwbuildid)"
else
	# Hu oh...
	device_type="unknown"
fi

# Make the board type human-readable...
case "${boardtype}" in
	"PROTO" )
		boardtype="Prototype"
	;;
	"EVT" )
		boardtype="EVT"
	;;
	"DVT" )
		boardtype="DVT"
	;;
	"PVT" )
		boardtype="Production"
	;;
	* )
		boardtype="${boardtype}"
	;;
esac

# Get the FW version
fw_build_maj="$(awk '/Version:/ { print $NF }' /etc/version.txt | awk -F- '{ print $NF }')"
fw_build_min="$(awk '/Version:/ { print $NF }' /etc/version.txt | awk -F- '{ print $1 }')"
# Legacy major versions used to have a leading zero, which is stripped from the complete build number. Except on really ancient builds, that (or an extra) 0 is always used as a separator between maj and min...
fw_build_maj_pp="${fw_build_maj#0}"
# That only leaves some weird diags build that handle this stuff in potentially even weirder ways to take care of...
if [ "${fw_build_maj}" -eq "${fw_build_min}" ] ; then
	# Weird diags builds... (5.0.0)
	fw_build="${fw_build_maj_pp}0???"
else
	# Most common instance... maj#6 + 0 + min#3 or maj#5 + 0 + min#3 (potentially with a leading 0 stripped from maj#5)
	if [ ${#fw_build_min} -eq 3 ] ; then
		fw_build="${fw_build_maj_pp}0${fw_build_min}"
	else
		# Truly ancient builds... For instance, 2.5.6, which is maj#5 + min#4 (with a leading 0 stripped from maj#5)
		fw_build="${fw_build_maj_pp}${fw_build_min}"
	fi
fi
# NOTE: These weird differences mean I can't use a nice one-liner regex like this... ;'(
#fw_build="$(head -n 1 /etc/version.txt | sed -re 's/^(.*?)(Version: )([[:digit:]]*)(-)(.*?)(-)([[:digit:]]*)$/\70\3/')"

# And the human-readable version...
fw_ver="$(sed -re 's/(^Kindle )([[:digit:].]*)(.*?$)/\2/' /etc/prettyversion.txt)"

# Do the model dance...
kmodel="$(cut -c3-4 /proc/usid)"
case "${kmodel}" in
	"01" )
		devicemodel="Kindle 1"
	;;
	"02" )
		devicemodel="Kindle 2 U.S."
	;;
	"03" )
		devicemodel="Kindle 2 International"
	;;
	"04" )
		devicemodel="Kindle DX U.S."
	;;
	"05" )
		devicemodel="Kindle DX International"
	;;
	"09" )
		devicemodel="Kindle DX Graphite"
	;;
	"08" )
		devicemodel="Kindle 3 WiFi"
	;;
	"06" )
		devicemodel="Kindle 3 3G U.S."
	;;
	"0A" )
		devicemodel="Kindle 3 3G Europe"
	;;
	"0E" )
		devicemodel="Silver Kindle 4"
	;;
	"0F" )
		devicemodel="Kindle Touch 3G U.S"
	;;
	"11" )
		devicemodel="Kindle Touch WiFi"
	;;
	"10" )
		devicemodel="Kindle Touch 3G Europe"
	;;
	"12" )
		devicemodel="Kindle 5 (Unknown)"
	;;
	"23" )
		devicemodel="Black Kindle 4"
	;;
	"24" )
		devicemodel="Kindle PaperWhite WiFi"
	;;
	"1B" )
		devicemodel="Kindle PaperWhite 3G U.S."
	;;
	"20" )
		devicemodel="Kindle PaperWhite 3G Brazil"
	;;
	"1C" )
		devicemodel="Kindle PaperWhite 3G Canada"
	;;
	"1D" )
		devicemodel="Kindle PaperWhite 3G Europe"
	;;
	"1F" )
		devicemodel="Kindle PaperWhite 3G Japan"
	;;
	"D4" )
		devicemodel="Kindle PaperWhite 2 (2013) WiFi U.S & Intl"
	;;
	"5A" )
		devicemodel="Kindle PaperWhite 2 (2013) WiFi Japan"
	;;
	"D5" )
		devicemodel="Kindle PaperWhite 2 (2013) 3G U.S."
	;;
	"D6" )
		devicemodel="Kindle PaperWhite 2 (2013) 3G Canada"
	;;
	"D7" )
		devicemodel="Kindle PaperWhite 2 (2013) 3G Europe"
	;;
	"D8" )
		devicemodel="Kindle PaperWhite 2 (2013) 3G Russia"
	;;
	"F2" )
		devicemodel="Kindle PaperWhite 2 (2013) 3G Japan"
	;;
	"17" )
		devicemodel="Kindle PaperWhite 2 (2013) WiFi 4GB Europe"
	;;
	"60" )
		devicemodel="Kindle PaperWhite 2 (2013) 3G 4GB Europe"
	;;
	"F4" )
		devicemodel="Unknown Kindle PaperWhite 2 (2013) (0xF4)"
	;;
	"F9" )
		devicemodel="Unknown Kindle PaperWhite 2 (2013) (0xF9)"
	;;
	"62" )
		devicemodel="Kindle PaperWhite 2 (2013) 3G 4GB U.S."
	;;
	"61" )
		devicemodel="Kindle PaperWhite 2 (2013) 3G 4GB Brazil"
	;;
	"5F" )
		devicemodel="Kindle PaperWhite 2 (2013) 3G 4GB Canada"
	;;
	"C6" )
		devicemodel="Kindle Basic"
	;;
	"DD" )
		devicemodel="Kindle Basic Australia"
	;;
	"13" )
		devicemodel="Kindle Voyage WiFi"
	;;
	"54" )
		devicemodel="Kindle Voyage 3G U.S."
	;;
	"2A" )
		devicemodel="Kindle Voyage 3G Japan"
	;;
	"4F" )
		devicemodel="Unknown Kindle Voyage (0x4F)"
	;;
	"52" )
		devicemodel="Kindle Voyage 3G Mexico"
	;;
	"53" )
		devicemodel="Kindle Voyage 3G Europe"
	;;
	* )
		# Try the new device ID scheme...
		kmodel="$(cut -c4-6 /proc/usid)"
		case "${kmodel}" in
			"0G1" )
				devicemodel="Kindle PaperWhite 3 (2015) WiFi"
			;;
			"0G2" )
				devicemodel="Kindle PaperWhite 3 (2015) 3G U.S."
			;;
			"0G4" )
				devicemodel="Kindle PaperWhite 3 (2015) 3G Mexico"
			;;
			"0G5" )
				devicemodel="Kindle PaperWhite 3 (2015) 3G Europe"
			;;
			"0G6" )
				devicemodel="Kindle PaperWhite 3 (2015) 3G Canada"
			;;
			"0G7" )
				devicemodel="Kindle PaperWhite 3 (2015) 3G Japan"
			;;
			"0KB" )
				devicemodel="White Kindle PaperWhite 3 (2016) WiFi"
			;;
			"0KC" )
				devicemodel="White Kindle PaperWhite 3 (2016) 3G Japan"
			;;
			"0KD" )
				devicemodel="Unknown White Kindle PaperWhite 3 (2016) (0KD)"
			;;
			"0KE" )
				devicemodel="White Kindle PaperWhite 3 (2016) WiFi+3G International"
			;;
			"0KF" )
				devicemodel="White Kindle PaperWhite 3 (2016) WiFi+3G International (Bis)"
			;;
			"0KG" )
				devicemodel="Unknown White Kindle PaperWhite 3 (2016) (0KG)"
			;;
			"0LK" )
				devicemodel="Black PaperWhite 3 (2016) WiFi 32GB Japan"
			;;
			"0LL" )
				devicemodel="White PaperWhite 3 (2016) WiFi 32GB Japan"
			;;
			"0GC" )
				devicemodel="Kindle Oasis WiFi"
			;;
			"0GD" )
				devicemodel="Kindle Oasis 3G U.S."
			;;
			"0GR" )
				devicemodel="Kindle Oasis WiFi+3G International"
			;;
			"0GS" )
				devicemodel="Unknown Kindle Oasis (0GS)"
			;;
			"0GT" )
				devicemodel="Kindle Oasis WiFi+3G China"
			;;
			"0GU" )
				devicemodel="Kindle Oasis 3G Europe"
			;;
			"0DU" )
				devicemodel="Unknown Kindle Basic 2 (2016) (0DU)"
			;;
			"0K9" )
				devicemodel="Kindle Basic 2 (2016)"
			;;
			"0KA" )
				devicemodel="White Kindle Basic 2 (2016)"
			;;
			"0LM" )
				devicemodel="Kindle Oasis 2 (2017) (Unknown Variant 0LM)"
			;;
			"0LN" )
				devicemodel="Kindle Oasis 2 (2017) (Unknown Variant 0LN)"
			;;
			"0LP" )
				devicemodel="Kindle Oasis 2 (2017) (Unknown Variant 0LP)"
			;;
			"0LQ" )
				devicemodel="Kindle Oasis 2 (2017) (Unknown Variant 0LQ)"
			;;
			"0P1" )
				devicemodel="Champagne Kindle Oasis 2 (2017) WiFi (32GB)"
			;;
			"0P2" )
				devicemodel="Kindle Oasis 2 (2017) (Unknown Variant 0P2)"
			;;
			"0P6" )
				devicemodel="Kindle Oasis 2 (2017) (Unknown Variant 0P6)"
			;;
			"0P7" )
				devicemodel="Kindle Oasis 2 (2017) (Unknown Variant 0P7)"
			;;
			"0P8" )
				devicemodel="Kindle Oasis 2 (2017) WiFi (8GB)"
			;;
			"0S1" )
				devicemodel="Kindle Oasis 2 (2017) WiFi+3G (32GB)"
			;;
			"0S2" )
				devicemodel="Kindle Oasis 2 (2017) WiFi+3G (32GB) Europe"
			;;
			"0S3" )
				devicemodel="Kindle Oasis 2 (2017) (Unknown Variant 0S3)"
			;;
			"0S4" )
				devicemodel="Kindle Oasis 2 (2017) (Unknown Variant 0S4)"
			;;
			"0S7" )
				devicemodel="Kindle Oasis 2 (2017) (Unknown Variant 0S7)"
			;;
			"0SA" )
				devicemodel="Kindle Oasis 2 (2017) WiFi (32GB)"
			;;
			"0PP" )
				devicemodel="Kindle PaperWhite 4 (2018) WiFi (8GB)"
			;;
			"0T1" )
				devicemodel="Kindle PaperWhite 4 (2018) WiFi+4G (32GB)"
			;;
			"0T2" )
				devicemodel="Kindle PaperWhite 4 (2018) WiFi+4G (32GB) Europe"
			;;
			"0T3" )
				devicemodel="Kindle PaperWhite 4 (2018) WiFi+4G (32GB) Japan"
			;;
			"0T4" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 0T4)"
			;;
			"0T5" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 0T5)"
			;;
			"0T6" )
				devicemodel="Kindle PaperWhite 4 (2018) WiFi (32GB)"
			;;
			"0T7" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 0T7)"
			;;
			"0TJ" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 0TJ)"
			;;
			"0TK" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 0TK)"
			;;
			"0TL" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 0TL)"
			;;
			"0TM" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 0TM)"
			;;
			"0TN" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 0TN)"
			;;
			"102" )
				devicemodel="Kindle PaperWhite 4 (2018) WiFi (8GB) (India)"
			;;
			"103" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 103)"
			;;
			"16Q" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 16Q)"
			;;
			"16R" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 16R)"
			;;
			"16S" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 16S)"
			;;
			"16T" )
				devicemodel="Twilight Blue Kindle PaperWhite 4 (2018) WiFi (8GB)"
			;;
			"16U" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 16U)"
			;;
			"16V" )
				devicemodel="Kindle PaperWhite 4 (2018) (Unknown Variant 16V)"
			;;
			"10L" )
				devicemodel="Kindle Basic 3 (2019)"
			;;
			"0WF" )
				devicemodel="Kindle Basic 3 (2019) (Unknown Variant 0WF)"
			;;
			"0WG" )
				devicemodel="Kindle Basic 3 (2019) (Unknown Variant 0WG)"
			;;
			"0WH" )
				devicemodel="White Kindle Basic 3 (2019)"
			;;
			"0WJ" )
				devicemodel="Kindle Basic 3 (2019) (Unknown Variant 0WJ)"
			;;
			"0VB" )
				devicemodel="Kindle Basic 3 (2019) (Unknown Variant 0VB)"
			;;
			"11L" )
				devicemodel="Champagne Kindle Oasis 3 (2019) WiFi (32GB)"
			;;
			"0WQ" )
				devicemodel="Kindle Oasis 3 (2019) WiFi+4G (32GB) Japan"
			;;
			"0WP" )
				devicemodel="Kindle Oasis 3 (2019) (Unknown Variant 0WP)"
			;;
			"0WN" )
				devicemodel="Kindle Oasis 3 (2019) WiFi+4G (32GB)"
			;;
			"0WM" )
				devicemodel="Kindle Oasis 3 (2019) WiFi (32GB)"
			;;
			"0WL" )
				devicemodel="Kindle Oasis 3 (2019) WiFi (8GB)"
			;;
			* )
				devicemodel="Unknown"
			;;
		esac
	;;
esac

# And now that we have out data, setup what we'll need to show it...
# NOTE: Keep this in sync w/ BatteryStatus!
# We need to get the proper constants for our model...
case "${kmodel}" in
	"13" | "54" | "2A" | "4F" | "52" | "53" )
		# Voyage...
		SCREEN_X_RES=1088	# NOTE: Yes, 1088, not 1072 or 1080...
		SCREEN_Y_RES=1448
		EIPS_X_RES=16
		EIPS_Y_RES=24		# Manually measured, should be accurate.
	;;
	"24" | "1B" | "1D" | "1F" | "1C" | "20" | "D4" | "5A" | "D5" | "D6" | "D7" | "D8" | "F2" | "17" | "60" | "F4" | "F9" | "62" | "61" | "5F" )
		# PaperWhite...
		SCREEN_X_RES=768	# NOTE: Yes, 768, not 758...
		SCREEN_Y_RES=1024
		EIPS_X_RES=16
		EIPS_Y_RES=24		# Manually measured, should be accurate.
	;;
	"C6" | "DD" )
		# KT2...
		SCREEN_X_RES=608
		SCREEN_Y_RES=800
		EIPS_X_RES=16
		EIPS_Y_RES=24
	;;
	"0F" | "11" | "10" | "12" )
		# Touch
		SCREEN_X_RES=600
		SCREEN_Y_RES=800
		EIPS_X_RES=12
		EIPS_Y_RES=20
	;;
	# Try the new device ID scheme... kmodel always points to our actual device code, no matter the scheme.
	"0G1" | "0G2" | "0G4" | "0G5" | "0G6" | "0G7" | "0KB" | "0KC" | "0KD" | "0KE" | "0KF" | "0KG" | "0LK" | "0LL" )
		# PW3...
		SCREEN_X_RES=1088
		SCREEN_Y_RES=1448
		EIPS_X_RES=16
		EIPS_Y_RES=24
	;;
	"0GC" | "0GD" | "0GR" | "0GS" | "0GT" | "0GU" )
		# Oasis...
		SCREEN_X_RES=1088
		SCREEN_Y_RES=1448
		EIPS_X_RES=16
		EIPS_Y_RES=24
	;;
	"0DU" | "0K9" | "0KA" )
		# KT3...
		SCREEN_X_RES=608
		SCREEN_Y_RES=800
		EIPS_X_RES=16
		EIPS_Y_RES=24
	;;
	"0LM" | "0LN" | "0LP" | "0LQ" | "0P1" | "0P2" | "0P6" | "0P7" | "0P8" | "0S1" | "0S2" | "0S3" | "0S4" | "0S7" | "0SA" )
		# Oasis 2...
		SCREEN_X_RES=1280
		SCREEN_Y_RES=1680
		EIPS_X_RES=16
		EIPS_Y_RES=24
	;;
	"0PP" | "0T1" | "0T2" | "0T3" | "0T4" | "0T5" | "0T6" | "0T7" | "0TJ" | "0TK" | "0TL" | "0TM" | "0TN" | "102" | "103" | "16Q" | "16R" | "16S" | "16T" | "16U" | "16V" )
		# PW4...
		SCREEN_X_RES=1088
		SCREEN_Y_RES=1448
		EIPS_X_RES=16
		EIPS_Y_RES=24
	;;
	"10L" | "0WF" | "0WG" | "0WH" | "0WJ" | "0VB" )
		# KT4...
		SCREEN_X_RES=608
		SCREEN_Y_RES=800
		EIPS_X_RES=16
		EIPS_Y_RES=24
	;;
	"11L" | "0WQ" | "0WP" | "0WN" | "0WM" | "0WL" )
		# Oasis 3...
		SCREEN_X_RES=1280
		SCREEN_Y_RES=1680
		EIPS_X_RES=16
		EIPS_Y_RES=24
	;;
	* )
		# Handle legacy devices...
		if [ -f "/etc/rc.d/functions" ] && grep -q "EIPS" "/etc/rc.d/functions" ; then
			. /etc/rc.d/functions
		else
			# Fallback... We shouldn't ever hit that.
			SCREEN_X_RES=600
			SCREEN_Y_RES=800
			EIPS_X_RES=12
			EIPS_Y_RES=20
		fi
	;;
esac
# And now we can do the maths ;)
EIPS_MAXCHARS="$((${SCREEN_X_RES} / ${EIPS_X_RES}))"
EIPS_MAXLINES="$((${SCREEN_Y_RES} / ${EIPS_Y_RES}))"

# From libotautils[5], adapted from libkh[5]
# Default to something that won't horribly blow up...
FBINK_BIN="true"
for my_hackdir in linkss linkfonts libkh usbnet ; do
	my_fbink="/mnt/us/${my_hackdir}/bin/fbink"
	if [ -x "${my_fbink}" ] ; then
		FBINK_BIN="${my_fbink}"
		# Got it!
		break
	fi
done
has_fbink()
{
	# Because the fallback is the "true" binary/shell built-in ;).
	if [ "${FBINK_BIN}" != "true" ] ; then
		# Got it!
		return 0
	fi

	# If we got this far, we don't have fbink installed
	return 1
}

do_fbink_print()
{
	# We need at least two args
	if [ $# -lt 2 ] ; then
		echo "not enough arguments passed to do_fbink_print ($# while we need at least 2)"
		return
	fi

	kh_eips_string="${1}"
	kh_eips_y_shift_up="${2}"

	# Unlike eips, we need at least a single space to even try to print something ;).
	if [ "${kh_eips_string}" == "" ] ; then
		kh_eips_string=" "
	fi

	# Check if we asked for a highlighted message...
	if [ "${3}" == "h" ] ; then
		fbink_extra_args="h"
	else
		fbink_extra_args=""
	fi

	# NOTE: FBInk will handle the padding. FBInk's default font is square, not tall like eips,
	#       so we compensate by tweaking the baseline ;).
	${FBINK_BIN} -qpm${fbink_extra_args} -y $(( -4 - ${kh_eips_y_shift_up} )) "${kh_eips_string}"
}

do_eips_print()
{
	# We need at least two args
	if [ $# -lt 2 ] ; then
		echo "not enough arguments passed to do_eips_print ($# while we need at least 2)"
		return
	fi

	kh_eips_string="${1}"
	kh_eips_y_shift_up="${2}"

	# Get the real string length now
	kh_eips_strlen="${#kh_eips_string}"

	# Add the right amount of left & right padding, since we're centered, and eips doesn't trigger a full refresh,
	# so we'll have to padd our string with blank spaces to make sure two consecutive messages don't run into each other
	kh_padlen="$(((${EIPS_MAXCHARS} - ${kh_eips_strlen}) / 2))"

	# Left padding...
	while [ ${#kh_eips_string} -lt $((${kh_eips_strlen} + ${kh_padlen})) ] ; do
		kh_eips_string=" ${kh_eips_string}"
	done

	# Right padding (crop to the edge of the screen)
	while [ ${#kh_eips_string} -lt ${EIPS_MAXCHARS} ] ; do
		kh_eips_string="${kh_eips_string} "
	done

	# And finally, show our formatted message centered on the bottom of the screen (NOTE: Redirect to /dev/null to kill unavailable character & pixel not in range warning messages)
	eips 0 $((${EIPS_MAXLINES} - 2 - ${kh_eips_y_shift_up})) "${kh_eips_string}" >/dev/null
}

eips_print_bottom_centered()
{
	# We need at least two args
	if [ $# -lt 2 ] ; then
		echo "not enough arguments passed to eips_print_bottom_centered ($# while we need at least 2)"
		return
	fi

	kh_eips_string="${1}"
	kh_eips_y_shift_up="${2}"

	# Sleep a tiny bit to workaround the logic in the 'new' (K4+) eInk controllers that tries to bundle updates
	if [ "${EIPS_SLEEP}" == "true" ] ; then
		usleep 150000	# 150ms
	fi

	# Can we use FBInk?
	if has_fbink ; then
		do_fbink_print "${kh_eips_string}" ${kh_eips_y_shift_up}
	else
		do_eips_print "${kh_eips_string}" ${kh_eips_y_shift_up}
	fi
}

# Showtime!
# Sleep for a bit, FBInk is likely to go faster than KUAL ;).
sleep 1

# Begin by warning if we failed to get our data...
if [ "${device_type}" == "unknown" ] ; then
	eips_print_bottom_centered "Could not collect data" 7
fi
eips_print_bottom_centered "Device: ${devicemodel}" 6
eips_print_bottom_centered "Platform: ${boardplat}" 5
eips_print_bottom_centered "Board: ${boardname} rev. ${boardrev}" 4
eips_print_bottom_centered "Device Code: ${kmodel}" 3
eips_print_bottom_centered "Type: ${boardtype}" 2
eips_print_bottom_centered "FW: ${fw_ver} (${fw_build})" 1

return 0
