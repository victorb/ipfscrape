#! /bin/bash
RED="$(tput setaf 1 2>/dev/null || :)"
GREEN="$(tput setaf 2 2>/dev/null || :)"
BLUE="$(tput setaf 4 2>/dev/null || :)"
NC="$(tput sgr0 2>/dev/null || :)"

command -v ipfs >/dev/null 2>&1 || { echo -e >&2 "${RED}You need \"IPFS\" but it was not found.${NC}  Aborting..."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo -e >&2 "${RED}You need \"wget\" but it was not found.${NC}  Aborting..."; exit 1; }

# Just to check if we're online or not
ipfs swarm peers >& /dev/null
RETVAL=$?

[ $RETVAL -ne 0 ] && echo -e "${RED}You need to have the IPFS daemon running! ${NC}   Aborting..." && exit 1

set -e
set -o pipefail

URL=$1

echo ""
echo -e "${GREEN}Dumping \"$URL\" into IPFS${NC}"

echo -e "${BLUE}"
mkdir -p /tmp/ipfscrape/site
cd /tmp/ipfscrape/site
wget -q --show-progress --page-requisites --html-extension --convert-links --random-wait -e robots=off -nd $URL || true

INDEX_FILE=$(ls -S | grep -i html | head -n1)

echo "Moving $INDEX_FILE to index.html"
mv /tmp/ipfscrape/site/$INDEX_FILE /tmp/ipfscrape/site/index.html

ipfs add -r . > ipfs_log

HASH=$(tail -n 1 ipfs_log | cut -d ' ' -f 2)

echo -e "${NC}"
echo "###############"
echo -e "## ${GREEN}DUMP COMPLETE${NC}"
echo "##"
echo "## Urls:"
echo -e "## ${BLUE}http://localhost:8080/ipfs/$HASH${NC}"
echo -e "## ${BLUE}https://ipfs.io/ipfs/$HASH${NC}"
echo ""

rm -rf /tmp/ipfscrape/site
