# JamNavigator

![JN256](https://user-images.githubusercontent.com/34669114/145498929-dadff436-fe3c-4198-a269-2d0ac8fda85a.png)

Record your music and share with your virtual session member.
Help us to find instant jam session members !
Enjoy!

Run it in the folder that contains the "JamNvigator.xcodeproj"


1.Amplify CLI install command
```
sudo npm install -g @aws-amplify/cli
```

2.Check the Amplify version.
```
amplify -v
```

3.Check the folder.(If this is file not found, include team-provider-info.json.)

~/JamNavigator/JamNavigator/amplify/team-provider-info.json


4.Amplyfi setup start.
```
amplify pull --appId <appId> --envName <envName>
```

```
? Select the authentication method you want to use: AWS access keys
? accessKeyId:  ********************
? secretAccessKey:  ****************************************
? region:  us-east-2
Amplify AppID found: d24c76i0kkvldp. Amplify App name is: JamNavigator
Backend environment dev found in Amplify Console app: JamNavigator
? Choose your default editor: Visual Studio Code
? Choose the type of app that you're building ios
? Do you plan on modifying this backend? Yes
⠏ Fetching updates to backend environment: dev from the cloud.
```
5.Run the following command again.

```
amplify codegen models
```

Setup compeleted!!

---
### Powerd by Team Toy Poodle
- Tech Leader : Misaki
- member : Tono, Tasuku

#### assignment task
- PoC : 
  - Tono
- UI maker : 
  - Tasuku : Driver
  - Misaki : Navigator
- Development
  - All member



