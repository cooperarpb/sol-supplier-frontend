#!/bin/bash 

yarn run build

DATE=$(date +%Y%m%d%H%M%S)

rsync -av --delete ./dist/ sol@10.70.0.46:/app/sol-supplier-frontend/production/releases/$DATE

ssh sol@10.70.0.46 "cd /app/sol-supplier-frontend/production && unlink current && ln -s releases/$DATE/ current"