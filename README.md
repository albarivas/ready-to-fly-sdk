# Ready to Fly (Apex SDK version) [WIP]

<img src="./airplaneLogo.png" width=30% height=30%>

Sample app to showcase Slack + Salesforce integrations using the Apex SDK for Slack.

## Prerequisites

To be able to run this project you will need:

-   A brand new [Trailhead Playground](https://trailhead.salesforce.com/content/learn/modules/trailhead_playground_management), or sign up for a [free Developer Edition org](https://developer.salesforce.com/signup).
    -   Optional: If you want to use scratch orgs follow the [instructions](https://help.salesforce.com/articleView?id=sfdx_setup_enable_devhub.htm&type=5) to enable Dev Hub in your Salesforce Developer Org.
    -   Enable [Slack for Salesforce beta](https://developer.salesforce.com/docs/platform/salesforce-slack-sdk/guide/enable-beta.html)
-   A new Slack workspace. You will need to create this workspace through a personal Slack account. (instructions [here](https://slack.com/help/articles/206845317-Create-a-Slack-workspace)).
-   `git` (download [here](https://git-scm.com/downloads))
-   `node` >= 14 (download [here](https://nodejs.org/en/download/))
-   `sfdx` CLI >= sfdx-cli/7.142.0 (download [here](https://developer.salesforce.com/tools/sfdxcli))

## Setup Steps

### Configuring Slack app at api.slack.com

1. Open [https://api.slack.com/apps/new](https://api.slack.com/apps/new) and choose **From an app manifest**
1. Select the workspace you created in the Prerequisites section
1. Copy the contents of [manifest.json](./apps/ready-to-fly-sdk/manifest.json) into the text box that says **Enter app manifest below** and click _Next_
1. Review the configuration and click _Create_
1. Replace APP_ID on the app manifest with the Id of your app and save changes. You can copy it from the URL for the app in api.slack.com.
1. In _Basic Information_ scroll down to the _Display Information_ section. Upload a picture for the app. You can use [this logo](./airplaneLogo.png)
1. In _Basic Information_ Generate an app level token for the connections.write scope
1. Now click _Install App_ on the left menu. Then click the _Install to Workspace_ button and then click on _Allow_

### Preparing the Slack app metadata before deploy

1. Clone the ready-to-fly-sdk repository

```
git clone https://github.com/trailheadapps/ready-to-fly-sdk
```

1. Open [ReadyToFlyPlaceHolder.slackapp-meta.xml](./force-app/main/default/slackapps/ReadyToFlyPlaceHolder.slackapp-meta.xml) and modify the secrets that you can copy from the _Basic Information_ tab of your app at api.slack.com. Rename the file to be called `ReadyToFlyPlace.slackapp-meta.xml`. This file is ignored and won't be commited to the repo.

### Deploying the app using a Salesforce Non-scratch org or a Trailhead Playground

1. Authenticate to your Salesforce org and set as default:

```
sfdx auth:web:login --setdefaultusername -a mydevorg
```

1. Deploy

```
sfdx force:source:deploy -p force-app/main/default
```

1. Assign permission set

```
sfdx force:user:permset:assign --permsetname Ready_to_Fly
```

1. Load sample data

```
sfdx force:apex:execute --apexcodefile data/setup.apex
```

### Deploying the app using a Salesforce scratch org

1. Authenticate to your Salesforce org that has DevHub enabled

```
sfdx auth:web:login --setdefaultdevhubusername -a DevHub
```

1. Deploy

```
sfdx force:source:push
```

1. Assign permission set

```
sfdx force:user:permset:assign --permsetname Ready_to_Fly
```

1. Load sample data

```
sfdx force:apex:execute --apexcodefile data/setup.apex
```
