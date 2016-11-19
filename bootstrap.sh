#!/bin/sh

set -e

OLD_IFS="${IFS}"
IFS="
"

BOLD="$(tput bold)"
UNBOLD="$(tput sgr0)"

SCRIPT_FILENAME="${0##*/}"
BACKUP_DIR="${HOME}/.dotfiles-old"

# Get the absolute path to the script dir
# (without readlink, for compatibility)
OLD_DIR="$(pwd -P)"
SCRIPT_DIR="${0%/*}"
cd "${SCRIPT_DIR}"
SCRIPT_DIR="$(pwd -P)"
cd "${OLD_DIR}"

# Find the dotfiles
FILES="$(find "${SCRIPT_DIR}/" \
	\( -type f -o -type l \) \
	! -path '*/.git/*' \
	! -name "${SCRIPT_FILENAME}" \
	-print
)"

really_bootstrap() {
	mkdir -p "${BACKUP_DIR}"

	# Get Antigen
	if [ -h "${HOME}/.zsh-antigen" ]; then
		rm -rf "${HOME}/.zsh-antigen"
	elif [ -d "${HOME}/.zsh-antigen" ]; then
		mv -f "${HOME}/.zsh-antigen" "${BACKUP_DIR}/.zsh-antigen"
	fi
	git clone "https://github.com/zsh-users/antigen.git" "${HOME}/.zsh-antigen"

	# Get the dotfiles
	for FILE in ${FILES}; do

		# Get the relative path to the file
		FILE=${FILE#${SCRIPT_DIR}/*}

		printf "%s\n" "${BOLD}${FILE}${UNBOLD}"

		# If there are subdirs in the relative path, create them if necessary
		SUBDIRS="${FILE%/*}"
		if [ "${SUBDIRS}" != "${FILE}" ] && [ ! -d "${HOME}/${SUBDIRS}" ]; then
			printf "%s\n" " - creating directory '${HOME}/${SUBDIRS}'"
			mkdir -p "${HOME}/${SUBDIRS}"
		fi

		if [ -h "${HOME}/${FILE}" ]; then
			# If the file already exists as a symlink,
			# we've probably run the script already,
			# so just delete the symlink
			printf "%s\n" " - deleting existing symlink '${HOME}/${FILE}'"
			rm -f "${HOME}/${FILE}"
		elif [ -f "${HOME}/${FILE}" ]; then
			# If the file already exists as an actual file,
			# create a backup for safety
			if [ "${SUBDIRS}" != "${FILE}" ] && [ ! -d "${BACKUP_DIR}/${SUBDIRS}" ]; then
				printf "%s\n" " - creating directory '${BACKUP_DIR}/${SUBDIRS}'"
				mkdir -p "${BACKUP_DIR}/${SUBDIRS}"
			fi
			printf "%s\n" " - moving existing file '${HOME}/${FILE}' => '${BACKUP_DIR}/${FILE}'"
			mv -f "${HOME}/${FILE}" "${BACKUP_DIR}/${FILE}"
		fi
		printf "%s\n" " - creating symlink '${HOME}/${FILE}' => '${SCRIPT_DIR}/${FILE}'"
		ln -s "${SCRIPT_DIR}/${FILE}" "${HOME}/${FILE}"

	done
}

printf '%s\n' "Your existing dotfiles will be backed up to '${BACKUP_DIR}/'."
printf '%s\n' "If there are existing symlinks, they will be deleted."
printf '%s' "Really bootstrap? (y/n) "
read -r choice
if [ "${choice}" = "y" ] || [ "${choice}" = "Y" ]; then
	printf '\n'
	really_bootstrap
fi

IFS="${OLDIFS}"
