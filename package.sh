#!/bin/sh

stack build

cp $(stack exec -- which blight | tail -n1) .

zip blight-$1.zip blight give_permissions.sh LICENSE LICENSE-3RD-PARTY README.md

rm blight