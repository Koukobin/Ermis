# Ermis

[ilias.koukovinis@gmail.com]: https://mail.google.com/mail/u/0/?tab=rm&ogbl#search/ilias.koukovinis%40gmail.com

[![GitHub Stars](https://img.shields.io/github/stars/Koukobin/Chatapp?style=social)](https://github.com/Koukobin/Ermis/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/Koukobin/Chatapp?style=social)](https://github.com/Koukobin/Ermis/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/Koukobin/Chatapp)](https://github.com/Koukobin/Ermis/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/Koukobin/Chatapp)](https://github.com/Koukobin/Ermis/pulls)
[![License](https://img.shields.io/github/license/Koukobin/Chatapp)](https://github.com/Koukobin/Ermis/blob/master/LICENSE)

Ermis is a suite of applications designed for secure and seamless communication. The project consists of the following components:

- **Ermis-Client**: The user-facing client application for communication.
- **Ermis-Server**: The backend server that handles everything related to server-side.
- **Ermis-Common**: The shared library containing common functionalities and utilities used by both the client and server.

## Vision

My vision while creating Ermis was to develop a server-side application that anyone can deploy with ease and efficiency to ensure it can run on even the oldest hardware. Alongside this, I aimed to build a client-side application - that boasts an intuitive and user-friendly interface - with a solid performance to complement the server. With a primary focus on security, the Ermis platform employs robust encryption methods to ensure the protection of user data and privacy. By prioritizing security measures, I aimed to create a platform where users can communicate freely and openly, knowing their information is safe from prying eyes. The ultimate goal is to create a platform that anyone can host and communicate with.

## Features

- **Real-time communication:** Efficiently handle multiple concurrent users.
- **Media Sharing**: Easily share images, videos, and documents within your chats.
- **Secure Connections**: Integrated with TLS encryption to ensure privacy and security.
- **PostgreSQL integration:** Manage user data, messages, and logs in a reliable relational database.

## Future Enhancements

Moving forward, I do not have any particular plans regarding Ermis's development in mind right now. As a general idea I would like to:

- **Enhance Scalability**: Further optimize the server-side application to handle even larger loads.
- **Improve Code Readability**: Refactor the codebase to improve maintainability and readability.
- **Expand Features**: Introduce new functionalities in order to enrich user experience.

## Screenshots

<div align="center">
    <h3>Messaging Interface (Mobile)</h3>
    <img width="500" alt="Messaging Interface" src="https://github.com/Koukobin/Ermis/blob/master/Images/messaging-interface-mobile.png"/>
</div>

<div align="center">
    <h3>Chats Screen (Mobile)</h3>
    <img width="500" alt="Chats Screen" src="https://github.com/Koukobin/Ermis/blob/master/Images/chats-screen-mobile.png"/>
</div>

<div align="center">
    <h3>Voice Call Screen (Mobile)</h3>
    <img width="500" alt="Voice Call Screen" src="https://github.com/Koukobin/Ermis/blob/master/Images/voice-call-mobile.png"/>
</div>

<div align="center">
    <h3>Video Call Screen (Mobile)</h3>
    <img width="500" alt="Video Call Screen" src="https://github.com/Koukobin/Ermis/blob/master/Images/video-call-mobile.png"/>
</div>

<div align="center">
    <h3>Chat Requests Screen (Mobile)</h3>
    <img width="500" alt="Chat Requests Screen" src="https://github.com/Koukobin/Ermis/blob/master/Images/chat-requests-screen-mobile.png"/>
</div>

<div align="center">
    <h3>Settings Screen (Mobile)</h3>
    <img width="500" alt="Settings Screen" src="https://github.com/Koukobin/Ermis/blob/master/Images/settings-screen-mobile.png"/>
</div>

<div align="center">
    <h3>Profile Screen (Mobile)</h3>
    <img width="500" alt="Profile Screen" src="https://github.com/Koukobin/Ermis/blob/master/Images/profile-screen-mobile.png"/>
</div>

### Login Screen (Desktop)
<img width="1000" alt="Login Screen" src="https://github.com/Koukobin/Ermis/blob/master/Images/login-screen.png"/>

### Create Account Screen (Desktop)
<img width="1000" alt="Create Account screen" src="https://github.com/Koukobin/Ermis/blob/master/Images/create_account-screen.png"/>

### Messaging Interface (Desktop)
<img width="1000" alt="Messaging Interface" src="https://github.com/Koukobin/Ermis/blob/master/Images/messaging-interface.png"/>

### Choose Server Screen (Desktop)
<img width="1000" alt="Choose Server Screen" src="https://github.com/Koukobin/Ermis/blob/master/Images/choose_server-screen.png"/>

## Wiki/Documentation

You can find thorough documentation and a more in-depth analysis of Ermis here: [Wiki](https://github.com/Koukobin/Ermis/wiki/)

## Getting Started

To set up the project locally, follow the instructions for each component:

1. [Ermis-Client](./ermis-client/README.md)
2. [Ermis-Server](./ermis-server/README.md)
3. [Ermis-Common](./ermis-common/README.md)

## Potential Questions

* Q: Is there a mobile version of Ermis?
	- A: Yes! The Ermis-Client is designed not only for desktop platforms (Linux, Windows) but also for mobile devices running Android.
* Q: Is there a IOS version of Ermis?
    - A: Although the mobile client is developed using Flutter - a cross-platform UI framework -, Apple's stringent/rigorous requirements make building an iOS version (IPA) a pain in the ass. Requiring Apple hardware, compiling in Xcode and I don't even know what else. One thing is for certain - I am not spending money tantamount to buying a car to solely build an iOS version. Consequently, the release of an iOS version is *non potest fieri*.
* Q: Is there a macOS version of Ermis?
	- A: At the moment, Ermis-Client is designed for Windows and Linux. A macOS version is not available at this time, but future updates may include support for the macOS platform as well.
* Q: Is Ermis available for all Linux distributions?
	- A: Unfortunately, at present, Ermis is available exclusively for Debian-based distributions (such as Ubuntu, Linux Mint, Kali Linux). In the future, I hope to include support for Red Hat-based distributions (like Fedora and CentOS) and other distros, such as Arch Linux.
* Q: Is my data secure while using Ermis?
    - A: Yes, Ermis employs robust encryption methods to ensure the protection of user data and privacy.
    
## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Ensure your code adheres to the project's style and conventions.
4. Submit a pull request with a detailed description of your changes.

## Report an issue

To report bugs, security vulnerabilities, or any other issues for that matter, please use the GitHub Issues tab to report them. Alternatively, you can contact me directly via email here: [ilias.koukovinis@gmail.com]

When reporting an issue, please include:
- A clear and descriptive title.
- Steps to reproduce the issue.
- Logs or error messages if available.
- Your environment details (OS, version, etc.).

## Authors

* Ilias Koukovinis (2023) [ilias.koukovinis@gmail.com]

## License

Ermis is distributed under the GNU Affero General Public License Version 3.0 which can be found in the `LICENSE` file.

By using this software, you agree to the terms outlined in the license agreement.
