#!/bin/bash
DownloadDest="${1}"
TempDest="${2}"
credentialsFile="CREDENTIALS-egp.gu.gov.si.txt"
maxAge=240
baseUrl="https://egp.gu.gov.si/egp/"

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

function extractDownloaded() {
	#----- extract: -------
	for file in "${DownloadDest}"RPE_*.ZIP; do
		extdir=$(basename "$file" .ZIP)
		echo "$extdir"
		unzip -o -d "${TempDest}$extdir" "$file"
	done
	for file in "${TempDest}"RPE_*/*.zip; do unzip -o -d "${TempDest}" "$file"; done

	$STATCMD -c '%y' "${TempDest}OB/OB.shp" | cut -d' ' -f1 >"${TempDest}timestamp.txt"
}

countTooOld=3

if [ -f "${DownloadDest}RPE_PE.ZIP" ] && [ -f "${DownloadDest}RPE_UL.ZIP" ] && [ -f "${DownloadDest}RPE_HS.ZIP" ]; then
	#check age of existing files
	countTooOld=$(find "${DownloadDest}RPE_PE.ZIP" "${DownloadDest}RPE_UL.ZIP" "${DownloadDest}RPE_HS.ZIP" -mmin +${maxAge} | wc -l)
fi

# exit if all are newer than max age
if [ "$countTooOld" -gt "0" ]; then
	echo "Need to download $countTooOld files (they are either missing or older than $maxAge minutes)"
else
	echo "No need to download anything (source files are already there and not older than $maxAge minutes)"
	extractDownloaded
	exit 0
fi


# Clean up leftovers from previous failed runs
rm -f "${DownloadDest}cookies.txt"
rm -f "${DownloadDest}login.html"

commonWgetParams=(--load-cookies "${DownloadDest}cookies.txt" --save-cookies "${DownloadDest}cookies.txt" --directory-prefix "${DownloadDest}" --keep-session-cookies --ca-certificate "sigov-ca2.pem")
# --no-hsts
# --quiet
# --ciphers "HIGH:!aNULL:!MD5:!RC4" \
# --secure-protocol=TLSv1 \	
# --referer "${baseUrl}" \

function prepareCredentials() {
	#------ username & password: ------
	# read possibly existing credentials...
	# shellcheck source=/dev/null
	source "$credentialsFile"

	echo Credentials for ${baseUrl}

	if [ -z "$username" ]; then
		echo -n "	Username: "
		read -r username
		echo "username=\"$username\"" >"$credentialsFile"
	else
		echo "	Username: '$username'"
	fi

	if [ -z "$password" ]; then
		echo -n "	Password: "
		read -r password
		read -p "	Save password in plain text to $credentialsFile for future use? (y/N) " -n 1 -r
		echo # (optional) move to a new line
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			# save it only if wanted
			echo "password=\"$password\"" >>"$credentialsFile"
		fi
	else
		echo "	Password: *********"
	fi
}

function login() {
	#------ Log in to the server.  This can be done only once ------
	wget "${commonWgetParams[@]}" \
		--quiet \
		"${baseUrl}login.html"

	# example login.html content:
	# <input type="hidden" name="_csrf" value="089070ed-b40a-4e3c-ab22-422de0daffff" />
	csrftoken="$($SEDCMD -n 's/.*name="_csrf"\s\+value="\([^"]\+\).*/\1/p' "${DownloadDest}login.html")"

	if [ -z "${csrftoken}" ]; then
		echo "No CSRF token found, exitting!"
		exit 1
	fi

	echo "Got CSRF token: \"${csrftoken}\"."

	echo "TRAVIS=${TRAVIS}"
	if [ "${TRAVIS}" != "true" ]; then
		prepareCredentials
	else
		echo "Running in TRAVIS CI, using encrypted credentials."
	fi


	loginFormData="username=${username}&password=${password}&_csrf=${csrftoken}"
	#echo login form data: $loginFormData

	#exit 1
	wget "${commonWgetParams[@]}" \
		--post-data "${loginFormData}" \
		--delete-after \
		--quiet \
		"${baseUrl}login.html"
}


# pass numeric file id as parameter
function downloadFile() {
	wget "${commonWgetParams[@]}" \
		-q --show-progress \
		--content-disposition -N \
		"${baseUrl}download-file.html?id=$1&format=10&d96=1"
}

# ---------------------------------------------
login

#------ Download all data we care about: ------
#RPE_PE.ZIP
downloadFile 105

#RPE_UL.ZIP
downloadFile 106

#RPE_HS.ZIP
downloadFile 107

# Clean up secrets so they are not cached
rm -f "${DownloadDest}cookies.txt"


extractDownloaded

echo getSource finished.
