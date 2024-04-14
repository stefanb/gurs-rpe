#!/bin/bash
set -e
DownloadDest="${1}"
TempDest="${2}"
maxAge=240

SEDCMD="sed"
STATCMD="stat"
unameOut="$(uname -s)"
case "${unameOut}" in
Linux*) machine=Linux ;;
Darwin*)
	machine="Mac"
	SEDCMD="gsed"
	STATCMD="gstat"
	;;
CYGWIN*) machine=Cygwin ;;
MINGW*) machine=MinGw ;;
*) machine="UNKNOWN:${unameOut};" ;;
esac
echo Running on: "${machine}", using $SEDCMD and $STATCMD commands

# pass numeric file ids and name as parameter
function downloadFile() {
	mkdir -p "${DownloadDest}"
	echo "Downloading ${DownloadDest}$3..."
	curl \
		--compressed \
		--output "${DownloadDest}$3" \
		--fail \
		--progress-bar \
		"https://ipi.eprostor.gov.si/jgp-service-api/display-views/groups/$1/composite-products/$2/file?filterParam=DRZAVA&filterValue=1"
}

function extractDownloaded() {
	rm -rf "${TempDest}" || true
	mkdir -p "${TempDest}"

	#----- extract: -------
	for file in "${DownloadDest}"RPE_*.ZIP; do
		extdir=$(basename "$file" .ZIP)
		echo "$extdir"
		unzip -o -d "${TempDest}$extdir" "$file"
	done
	# for file in "${TempDest}"RPE_*/*.zip; do unzip -o -d "${TempDest}" "$file"; done

	# $STATCMD -c '%y' ${TempDest}RPE_HS/KN_SLO_NASLOVI_HS_naslovi_hs_????????.csv | cut -d' ' -f1 >"${TempDest}timestamp.txt"
}

countTooOld=3

if [ -f "${DownloadDest}RPE_PE.ZIP" ] && [ -f "${DownloadDest}RPE_UL.ZIP" ] && [ -f "${DownloadDest}RPE_HS.ZIP" ]; then
	#check age of existing files
	countTooOld=$(find "${DownloadDest}RPE_PE.ZIP" "${DownloadDest}RPE_UL.ZIP" "${DownloadDest}RPE_HS.ZIP" -mmin +${maxAge} | wc -l)
fi

# exit if all are newer than max age
if [ "$countTooOld" -gt "0" ]; then
	echo "Need to download $countTooOld files (they are either missing or older than $maxAge minutes)"
	#------ Download all data we care about: ------
	downloadFile 119 12 RPE_PE.ZIP
	downloadFile 119 181 RPE_UL.ZIP
	downloadFile 121 141 RPE_HS.ZIP
else
	echo "No need to download anything (source files are already there and not older than $maxAge minutes)"
fi


extractDownloaded

echo getSource finished.
