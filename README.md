# Overview

Need to add instant messaging to your new or existing Flutter app? In this article, we’ll be exploring how to implement the Robin SDK with a Flutter app. We’ll be using a sample Flutter application for our demo.

💡 Flutter is a framework managed by Google for building natively compiled cross-platform applications. This guide assumes that you understand the concept of building cross-platform applications with Flutter, if you need a quick refresher, feel free to check [here](https://docs.flutter.dev/reference/tutorials)

## Pre-requisites

Before we begin adding instant messaging to our flutter application, there are a couple of things you should have. First, you would need a **Robin account,** to do that, you can sign up on [dashboard.robinapp.co/](https://dashboard.robinapp.co/). After creating a Robin account, you would need to create a **Robin App**, you should get a prompt to create your first Robin app on successful sign-up. Finally, you would also need to ensure flutter is installed on your machine.

If you have all of the above ready, I guess we can begin.

ℹ️ Want to see the full code for setup? Check [here](https://www.notion.so/FLUTTER-SDK-ROBIN-DOCS-914f03e591ec43398b74851b58a1614c)

## The Robin App

Robin was built with several communication [use cases](https://robinapp.co/usecase) in mind; this means that you could create several applications to leverage all of these use cases with your Robin Account with a proper separation of each concern. This was how we came about the **Robin App**.

<aside>
💡 The Robin App could either be “Fully Authenticated” or “Moderated”.

</aside>

The Fully Authenticated Robin App ensures that every form of communication is fully encrypted in transit, making sure that you (the one with access to the Robin Account) and even Robin cannot see messages from the communication channel. The Moderated Robin App allows you to view communications without any encryption mechanism set up.

# Project Setup

## Create Flutter Application

Navigate to your desired folder and create a new Flutter project, we would call it **robin_test_app**.

```bash
flutter create robin_test_app
```

## Add Robin Flutter SDK to your Flutter application

Open the robin_test_app application on any IDE of choice and add the Robin Flutter SDK to your project; do this simply by adding the `robin_flutter` package to your `pubspec.yaml` file.

```yaml
dependencies:
  robin_flutter: ^version-number
```

And then run the following command in your terminal

```bash
flutter pub get
```

## Permissions

<aside>
ℹ️ **Why does Robin need App Permissions?**
Robin provides a full real-time chat experience, with robust features such as image sharing, and voice recordings, to mention a few; to make sure all of these features are functional, you would need to request permissions of users as you would if you were building your Flutter application from scratch.

</aside>

Robin requires that you request permissions to the resources in your `AndroidManifest.xml` and `info.plist` files for Android and iOS respectively.

### iOS Permissions

Your `info.plist` file is located in `<project root>/ios/Runner/Info.plist`

```markup
<key>NSPhotoLibraryUsageDescription</key>
<string>Explain why your app needs permission to the Photo library</string>

<key>NSCameraUsageDescription</key>
<string>Explain why your app needs permission to the Camera</string>

<key>NSMicrophoneUsageDescription</key>
<string>Explain why your app needs permission to the Microphone</string>

<key>LSApplicationQueriesSchemes</key>
<array>
  <string>https</string>
  <string>http</string>
</array>
```

### Android Permissions

Your `AndroidManifest.xml` file is located in `<project root>/android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<queries>
	<intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
	<intent>
    <action android:name="android.intent.action.SEND" />
    <data android:mimeType="*/*" />
  </intent>
</queries>
```

# Connect Flutter App to Robin

Now that you have created a **Robin account**, a **Robin** **app**, and a **flutter application.** Let us connect our flutter application to the Robin dashboard using the Flutter SDK.

To get started with Robin on Flutter, a couple of items are required; your Robin App’s API key, details relating to the current user, keys in your users model, and a callback function to get all available users on your platform.

## Robin App API Key

We’re going to use our API key for this demo. You can get yours from the [API Configurations](https://dashboard.robinapp.co/apiconfig) tab from your Robin user dashboard.

After you get your app’s API key, store it as a constant `apiKey` for easy reference across your codebase.

```dart
final String apiKey = '/* YOUR API KEY */';
```

You can now proceed to import the Robin SDK into your file

```dart
import 'package:robin_flutter/robin_flutter.dart';
```

## Information of Logged In User

Robin requires certain information about the current user which is then used to personalize the user’s experience while using Robin.

1. **User’s Name:** This is the name you want to be displayed for this user within Robin.
2. **User’s Robin Token:** This is an identifier for each robin user that Robin uses to uniquely identify every user. It should be created when the user is signing up to your platform for the first time, but if you already have existing users, you should then update your users’ information in your database to accept and contain robin tokens.

### Create Robin Tokens for Users

The `metadata` is a bunch of key-value pairs that help Robin know who a Robin token is created for. The `metadata` Map can contain as much information as you wish to share about the user; some example information could be the user’s full name, phone number or email address.

```dart
Map<String, dynamic> metadata = {
	"firstName": user.firstName,
	"lastName": user.lastName,
	"emailAddress": user.email,
	...
};
final String robinToken = await RobinCore.createUserToken(apiKey, metaData);
```

After adding your `metaData` object, you can then create the `robinToken` for that user by making use of the `createUserToken` method and providing your API key and the user’s metadata.

<aside>
💡 Your application’s backend is often where new users are registered, this is why Robin advises that Robin tokens are created for each user upon successful registration. However, the Flutter SDK allows you to create a Robin token for your users on the client-side using the `RobinCore.createUserToken(apiKey, metaData)` method.

</aside>

Now that we have the current user’s name and their `robinToken`, we can now create the `RobinCurrentUser` so the SDK can identify the currently logged-in user.

```dart
RobinCurrentUser currentUser = RobinCurrentUser(
  robinToken: robinToken,
  fullName: userFullName,
);
```

# Users on your Robin Chat Application

## Getting all Users for Robin Chat

To use the Robin Chat feature for a select group of people, you would need to create a function that returns the identity of these people in a List, ideally, it could be all users within your platform but you can limit it to whatever fits your goals such as all moderators or admins within your platform.

This function should return a List of Maps:  `List<Map>` and could look something like the code snippet below.

```dart
List<Map> getAllUsers() async {
	http.Response response = await http.get(
	    Uri.parse('https://my-url.com/api/v1/users'),
	    headers: {
	      "Content-Type": "application/json",
	    },
	  );
      final String res = response.body;
      final int statusCode = response.statusCode;
      return _decoder.convert(res)['users'];
}
```

Your function ultimately should return something similar to the type and structure of the code snippet below. The snippet below is a list of Map objects with the `emailAddress`, `fullName` and `robinToken` fields.

```javascript
[
	{
		emailAddress: "johndoe@mail.com",
		fullName: "John Doe",
		robinToken: "BLAaUGurGvTewxIGKKrVANhn",
		...
	},
	{
		emailAddress: "janedoe@mail.com",
		fullName: "Jane Doe",
		robinToken: "BLAaUGurGvTewxIGKKrVANhn",
		...
	},
	...
]
```

### Parse Robin Chat Users

After we have successfully gotten all of the users we wish to use for our Robin Chat application, the Robin Flutter SDK requires that we parse the `List<Map>` of users, we do this by using `RobinKeys`; `RobinKeys` informs the SDK where to locate the Robin token, full name and other required fields/keys in your User object.

<aside>
ℹ️ All of the users’ data that is parsed is done on the user’s device, hence you can be sure that your users’ data is **not compromised** or **shared** with Robin during parsing.

</aside>

For the Robin Flutter Chat SDK, the **user token**, their **display name** and a **separator** are required to create the `RobinKeys` object, for everyone on your application to have a seamless chat experience.

### User Robin Token

`robinToken` accepts a List of Strings `List<String>` where each string in the list represents the fields that would be referenced in terms of object dot notation. Essentially, you enter all the keys/fields Robin has to go through to get to the robinToken in your User object.

For example, if your User model looks something like this:

```javascript
[{
		"emailAddress": "johndoe@mail.com",
		"fullName": "John Doe",
		"robinDetails": {
			"token": "BLAaUGurGvTewxIGKKrVANhn"
		},...
	},...
]
```

your `robinToken` value would be `["robinDetails", "token"]` since we first need to access the `robinDetails` key before we can access the `token` key to get its value.

### User Display Name

`displayName` is similar to `robinToken` but it accepts a List of Lists of Strings `List<List<String>>`. This is because you might want to concatenate different values such as `firstName` and `lastName` together. You enter all the keys Robin has to go through to get to a value within each individual List.

For example, if your user model looks like this:

```javascript
[{
		"emailAddress": "johndoe@mail.com",
		"firstName": "John",
		"lastName": "Doe",
		...
	},...
]
```

your `displayName` value would be `[["firstName"],["lastName"],]` for “John Doe”.

Or if your user model looks like this:

```javascript
[
	{
		"emailAddress": "johndoe@mail.com",
		"firstName": "John",
		"lastName": "Doe",
		"userDetails": {
			"middleName": "Clay",
			"address": ...,
			}
		...
	},
	...
]
```

your `displayName` value would be `[["firstName"],["userDetails", "middleName"],["lastName"]]` for “John Clay Doe”..

### User Separator

By default, the values of `displayName` are separated by space i.e `" "`, but optionally, you can add any string with which you want the values to be separated.

### Instantiate Robin Keys

At the end, your RobinKeys should look something like this.

```dart
RobinKeys keys =  RobinKeys(
  robinToken: ['robinToken'],
  displayName: [
    ['firstName'],['lastName']
  ],
  separator: " - "
);
```

# Create Robin App Instance

Now, we have all we need to fire up Robin in your application, you can do this however you like; you could make the chat take up a whole page by using your Navigator to push a new screen, or you could set it up as one of your children in a Bottom Navigation Bar.

Anyway you decide, the code to instantiate Robin in your Flutter application, should look something like this:

```dart
Robin(
  apiKey: apiKey,
  getUsers: getAllUsers,
  currentUser: currentUser,
  keys: keys,
);
```

And that would be all! Your users can start using Robin and all of its packed features to chat with each other.

## Your full setup code should look like this

In summary, the whole setup and initialisation of the Robin app would take this form after the steps taken above.

```dart
final String apiKey = '/* YOUR API KEY */';

/* CREATE ROBIN CURRENT USER FOR SDK IDENTIFICATION */
RobinCurrentUser currentUser = RobinCurrentUser(
  robinToken: robinToken,
  fullName: userFullName,
);

/* GET ALL USERS FOR ROBIN CHAT */
List<Map> getAllUsers() async {
	http.Response response = await http.get(
	    Uri.parse('https://my-url.com/api/v1/users'),
	    headers: {
	      "Content-Type": "application/json",
	    },
	  );
	  final String res = response.body;
	  final int statusCode = response.statusCode;
	  return _decoder.convert(res)['users'];
}

/*  */
RobinKeys keys =  RobinKeys(
  robinToken: ['robinToken'],
  displayName: [
    ['firstName'],['lastName']
  ],
	separator: " "
);

/* CREATE ROBIN INSTANCE */
Robin(
  apiKey: apiKey,
  getUsers: getAllUsers,
  currentUser: currentUser,
  keys: keys,
);
```
