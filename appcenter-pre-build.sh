#!/bin/sh

# Script to generate a ConversationsApp.xcodeproj/xcshareddata/xcschemes/ConversationsApp.xcscheme file with properly configured ACCESS_TOKEN_SERVICE_URL from
# the environment, so we don't have to store it in the repository.

[ -z "$ACCESS_TOKEN_SERVICE_URL" ] && exit 1

echo "PRE-BUILD: Replacing token service URL"

sed -e "s replace_me_with_URL ${ACCESS_TOKEN_SERVICE_URL} " -i .bak ConversationsApp.xcodeproj/xcshareddata/xcschemes/ConversationsApp.xcscheme
