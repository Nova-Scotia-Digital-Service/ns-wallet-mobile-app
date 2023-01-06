#!/usr/bin/env bash
echo "MEDIATOR_URL=$MEDIATOR_URL" > .env
cat .env
npm ci --ignore-scripts
cd ../bifold/core && npm i @aries-framework/react-hooks@0.3.0 --force
cd ../../app && npm install npm-run-all --save-dev && npm ci

if [ $IOS == "true" ]; then
  echo "IOS Specific builds";
  cd ios/AriesBifold && sed -i '' -e  "s/{APP_CENTER_KEY_IOS}/$APP_CENTER_KEY_IOS/g" AppCenter-Config.plist;
  cd .. && pod install && git status && git diff Podfile.lock;
fi
