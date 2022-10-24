# Building and Testing NS Wallet

<!-- TOC -->
* [Building and Testing NS Wallet](#building-and-testing-ns-wallet)
  * [Prerequisite Software](#prerequisite-software)
  * [Environment Setup](#environment-setup)
    * [React Native & Android Emulator](#react-native--android-emulator)
    * [Create Android emulator](#create-android-emulator)
* [Development](#development)
    * [Workspace Setup](#workspace-setup)
    * [Running in an Android emulator](#running-in-an-android-emulator)
  * [Source Code Information](#source-code-information)
<!-- TOC -->

## Prerequisite Software

Before you can build and test, you must install and configure the
following products on your development machine:

* [Git](https://git-scm.com/)
* [Node.js](https://nodejs.org) & [npm](https://docs.npmjs.com/cli/) - (version specified in the `engines` field
  of [./app/package.json](./app/package.json))
  > **Tip**: use [nvm](https://github.com/nvm-sh/nvm) to install node & npm. It helps to easily switch node & npm
  version for each project.
* Android SDK and Android Emulator
  > **Tip**: It is recommended to install the [Android Studio](https://developer.android.com/studio), it comes with
  android sdk,
  > device manager to install emulators.
* JDK 8 or 11 (Preferably OpenJDK or ZuluJDK)

## Environment Setup

### React Native & Android Emulator

React Native requires the following environment variables to be set in order to start the Android Emulator.

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

1. Open <kbd>Android Studio</kbd> -> <kbd> ⠇settings</kbd> -> <kbd> 📲 Virtual Device Manager</kbd> -> <kbd> Create
   Device </kbd>

| Name          | Details                              | Comments                                                                                                         |
|---------------|--------------------------------------|------------------------------------------------------------------------------------------------------------------|
| Device        | Pixel 4 or Higher (Without PlayStore) | **Note** - To root the emulator you need the one without Play Store. If you want to update the `/etc/hosts` file. |
| System Image  | Latest Android operating system      | Preferrabily - Release Name - `S`, API Level - `31` or higher                                                    | 

2. (Optional) Start a Rooted Android emulator (Required to be rooted to access the ledger running locally in order to 
    update the device's `/etc/hosts` file.). For accessing ledgers available on the internet does not require rooting the device. 
     
    > For more info - [Refer Official Docs - Local Network limitation](https://developer.android.com/studio/run/emulator-networking#networkinglimitations)


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
   3. Open a new terminal session, and run commands described in steps 3 & 4. 
       ```shell
       adb -s emulator-5554 remount
       ```
      output: 
      ```
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
        2. Push the file into the emulator
       ```shell
       adb -s emulator-5554 push myhosts /system/etc/hosts 
       ```
   5. Verify if the host entries are updated correctly!
      ```shell
       # To Verify
       $ adb shell
       $ cat /etc/hosts 
      
       127.0.0.1       localhost
       ::1             ip6-localhost
       192.168.0.117   host.docker.internal
      ``` 
   6. Goto Emulator -> ⚙️ <kbd> Settings</kbd>  -> 🔒 Security
      1. Set a pin for screen lock
      2. Add a Fingerprint (To enable biometric authentication)
      <br>
      
   7. Done! 
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

3. Setup Ledger & Mediator URLs in `.env` file

    ```shell
    vi .env
    ```
    and add the following configuration the file.
    ```shell
    MEDIATOR_URL=https://<YOUR_NGROK_UUID>.ngrok.io?c_i=<YOUR_NGROK_JWT_TOKEN>
    GENESIS_URL=http://localhost:9000/genesis
    ```
   <small><kbd>Esc</kbd> + <kbd>:</kbd> + <kbd>wq</kbd> - to save and quit  </small>
   <br>
   <br>
4. npm build
    ```shell
    # Install NS Wallet project dependencies (package.json)
    # from the root of the cloned repository
    npm install:all --legacy-peer-deps
    ```
   > **IMPORTANT:** If you are running `npm install:all` manually, you must provide `--legacy-peer-deps`
   
   > **Troubleshooting**
   >  - If you get this error: ```run-s: command not found``` <br>
   >    **Solution**: Run the following command to install npm-run-all
   >    ```
   >    npm i npm-run-all
   >    ```
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