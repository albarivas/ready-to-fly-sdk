# Ready to Fly (Apex SDK version) [WIP]

<img src="./airplaneLogo.png" width=30% height=30%>

Sample app to showcase Slack + Salesforce integrations using the Apex SDK for Slack.

## Prerequisites

To be able to run this project you will need:

-   A brand new [free Developer Edition org](https://developer.salesforce.com/signup) or a scratch org.
-   A Slack workspace. You can create a free workpaces following the instructions [here](https://slack.com/help/articles/206845317-Create-a-Slack-workspace).
-   `git` (download [here](https://git-scm.com/downloads))
-   `node` >= 14 (download [here](https://nodejs.org/en/download/))
-   `sfdx` CLI >= sfdx-cli/7.142.0 (download [here](https://developer.salesforce.com/tools/sfdxcli))

## Setup Steps

### Accept Slack terms in your org

1. In your org, accept Slack integrations terms on `setup --> Initial Slack setup`

1. In your org, accept Apex SDK terms on `setup --> Build Slack Apps with Apex`

Note: if you're using scratch orgs, you'll have to accept terms in your Dev Hub

### Creating a Slack app at api.slack.com

1. Open [https://api.slack.com/apps/new](https://api.slack.com/apps/new) and choose **From an app manifest**
1. Select the workspace you created in the Prerequisites section
1. Copy the contents of [manifest.json](./manifest.json) into the text box that says **Enter app manifest below** and click _Next_
1. Review the configuration and click _Create_
1. Replace APP_ID on the app manifest with the Id of your app and save changes. You can copy it from the URL for the app in api.slack.com.
1. In _Basic Information_ scroll down to the _Display Information_ section. Upload a picture for the app. You can use [this logo](./airplaneLogo.png)
1. In _Basic Information_ Generate an app level token for the `connections.write` scope
1. Now click _Install App_ on the left menu. Then click the _Install to Workspace_ button and then click on _Allow_

### Prepare the Slack app metadata and deploy

1. Clone the ready-to-fly-sdk repository

```
git clone https://github.com/albarivas/ready-to-fly-sdk
```

1. Open [ReadyToFlyPlaceHolder.slackapp-meta.xml](./force-app/main/default/slackapps/ReadyToFlyPlaceHolder.slackapp-meta.xml) and modify the secrets that you can copy from the _Basic Information_ tab of your app at api.slack.com. Rename the file to be called `ReadyToFlyPlace.slackapp-meta.xml`. This file is ignored and won't be commited to the repo.

1. Replace your team Id into [Slack_Workspace_Configuration.Apex_SDK_Starter_Kit.md-meta.xml](./force-app/main/default/customMetadata/Slack_Workspace_Configuration.Apex_SDK_Starter_Kit.md-meta.xml). You can get it from the URL when you navigate to https://your_workspace.slack.com/.

1. Deploy the code

```
sfdx force:source:deploy -p force-app/main/default
```

or, if using a scratch org:

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

1. Make sure your user has the System Permission `Connect to Slack`

### Resources

1. [Apex SDK Documentation](developer.salesforce.com/docs/platform/salesforce-slack-sdk)

1. [Ready to Fly (Bolt.js)](github.com/trailheadapps/ready-to-fly)

1. [Slack Next Generation Platform](api.slack.com/future)
