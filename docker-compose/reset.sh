#!/bin/bash
echo "This will delete your database initialize scripts (./data/)"
echo "          delete your certs files       (./nginx/ssl/)"
echo ""
read -p "Are you sure? " -n 1 -r
echo ""   # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then # do dangerous stuff
 sudo rm -r -f ./init/ ./nginx/ssl/
fi

