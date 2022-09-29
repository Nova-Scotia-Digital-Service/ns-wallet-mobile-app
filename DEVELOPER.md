# Building and Testing NS Wallet

* [Prerequisite Software](#prerequisite-software)
* [Getting the Sources](#getting-the-sources)
* [Installing NPM Modules](#installing-npm-modules)
* [Running in an Android emulator](#running-in-an-android-emulator)

## Prerequisite Software

Before you can build and test Angular, you must install and configure the
following products on your development machine:

* [Git](https://git-scm.com/) and/or the [**GitHub app**](https://desktop.github.com/) (for Mac and Windows);
  [GitHub's Guide to Installing Git](https://help.github.com/articles/set-up-git) is a good source of information.
* [Node.js](https://nodejs.org) & [npm](https://docs.npmjs.com/cli/), (version specified in the `engines` field of [`package.json`](./bcwallet-app/package.json)) which is used to run a development web server,
  run tests, and generate distributable files.
  > **Tip**: use [nvm](https://github.com/nvm-sh/nvm) to install node & npm. It helps to easily switch node & npm version for each project.
* Android SDK and Android Emulator
  > **Tip**: Easiest way is to install [Android Studio](https://developer.android.com/studio) it comes with android sdk, 
  > device manager to install emulators. 
* Java 8 or 11 (Preferably OpenJDK or ZuluJDK)


## Environment Setup
Make sure you have Android sdk installed, if you have android studio installed then you should already have it.

**Linux:**
```shell
# Update the PATH and add the variable ANDROID_SDK_ROOT

# Replace <YOUR_USER_NAME> with your user name. 
# /home/<YOUR_USER_NAME>/Android/Sdk is the default location of the sdk when using android studio. 
# Depending on how you installed the SDK, it may be in a different folder. 
# Make sure that ANDROID_SDK_ROOT is set to the "Sdk" folder in your android SDK installation
export ANDROID_SDK_ROOT=/home/<YOUR_USER_NAME>/Android/Sdk
export PATH="${PATH}:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin"
```
<small><kbd>Esc</kbd> + <kbd>:</kbd> + <kbd>wq</kbd> - to save and quit  </small>

**MacOS:**

```
vi ~/.zprofile
```
add the following to the end of the file.
```shell
# Android
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
```
<small><kbd>Esc</kbd> + <kbd>:</kbd> + <kbd>wq</kbd> - to save and quit</small>

### Create Android emulator

1. Open <kbd>Android Studio</kbd> -> <kbd> ⠇settings</kbd> -> <kbd> 📲 Virtual Device Manager</kbd> -> <kbd> Create Device </kbd>

| Name          | Details                               | Comments                                                                                                          |
|---------------|---------------------------------------|-------------------------------------------------------------------------------------------------------------------|
| Device        | Pixel 4 or Higher (Without PlayStore) | **Note** - To root the emulator you need the one without Play Store. If you want to update the `/etc/hosts` file. |
| System Image  | Release Name - `S`, API Level - `31`  |                                                                                                                   | 

2. (Optional) Start a Rooted Android emulator
   > **Why do I need to root my android emulator?**
   > _<br>In order for the mobile app to talk to the ledger and mediator service that is running locally.
   > We have to add an entry in device's - `/etc/host` file. The emulator is isolated from your host network won't be able to
   > access the services that are running on your host machine. For more info [Refer Official Docs - Local Network limitation](https://developer.android.com/studio/run/emulator-networking#networkinglimitations)._     

   1. List emulator
      ```shell
      emulator -list-avds
      Pixel_4_XL_API_31    
      
      # Note - Your output might be different depending on the AVD you created above.
      ```
   2. Start emulator as writable system
      ```shell
      emulator -avd Pixel_4_XL_API_31 -writable-system -no-snapshot-load
      ```
   3. In a new terminal, run the following commands in sequence.
      ```shell
      adb -s emulator-5554 remount
      remount succeeded
      ```
   4. Create a file with following host entries. We will copy this file into the emulator.
      1. create a file 
      ```shell
      vi myhosts 
      ```
      ```shell
      # Enter your local machines IP address. 192.168.0.107 is an example.      
      192.168.0.107 host.docker.internal  
      # Ensure to add a new line 
      ```
      2. Push the file into emulator
      ```shell
      adb -s emulator-5554 push myhosts /system/etc/hosts 
      ```
# Development
### Workspace Setup
1. Clone git repo
    ```shell
    # Clone your GitHub repository:
    git clone git@git.novascotia.ca:digitalplatformservices/ns-wallet/ns-wallet-mobile-app.git
    
    # Go to the NS Wallet directory:
    cd ns-wallet-mobile-app
    ```

2. Initialize the Aries `bifold` git sub-module
    ```shell
    # Initialize the aries bifold submodule:
    git submodule update --init
    ```
   (Optional) Updating `package.json`
    ```
    cd app
    npx --package=../bifold/core bifold sync-package-json
    ```

3. Setup Ledger & Mediator URLs
   > NS wallet will require these services for E2E working.
    ```shell
    vi .env
    ```
    and add the following configuration the file.
    ```shell
    MEDIATOR_URL=https://<YOUR_NGROK_UUID>.ngrok.io?c_i=<YOUR_NGROK_JWT_TOKEN>
    GENESIS_URL=http://localhost:9000/genesis
    ```
    <small><kbd>Esc</kbd> + <kbd>:</kbd> + <kbd>wq</kbd> - to save and quit  </small>

4. npm build
    ```shell
    # Install NS Wallet project dependencies (package.json)
    # from the root of the cloned repository
    npm install:all --legacy-peer-deps
    ```
   > **IMPORTANT:** If you are running `npm install:all` manually, you must provide `--legacy-peer-deps`

### Running in an Android emulator

5. Run the app in the emulator
   > Note - This step requires Android emulator to be up and running.
   
   Start metro
   ```shell
   cd app
   export RCT_METRO_PORT=10001   # (Optional) Default port is 8081 - often runs into conflicts
   npm run start
   ```
   and in a new terminal window, run the following command to deploy the app in emulator.

   ```shell
   cd app
   export RCT_METRO_PORT=10001   # (Optional) Default port is 8081 - often runs into conflicts
   npm run android
   ```


## Source Code Information

**Folder structure:**

``` bash
.
├── COMPLIANCE.yaml
├── CONTRIBUTING.md
├── DEVELOPER.md
├── LICENSE
├── README.md
├── RELEASE.md
├── app
├── bifold            # aries-bifold git submodule (contains the core implementation)
├── docs
├── jest.config.js
├── options.plist
├── package-lock.json
├── package.json
├── patch
├── release.xcconfig
├── scripts
└── tsconfig-base.json
```