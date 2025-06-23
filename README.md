# Ermis

[ilias.koukovinis@gmail.com]: https://mail.google.com/mail/u/0/?tab=rm&ogbl#search/ilias.koukovinis%40gmail.com

[![GitHub Stars](https://img.shields.io/github/stars/Koukobin/Chatapp?style=social)](https://github.com/Koukobin/Ermis/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/Koukobin/Chatapp?style=social)](https://github.com/Koukobin/Ermis/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/Koukobin/Chatapp)](https://github.com/Koukobin/Ermis/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/Koukobin/Chatapp)](https://github.com/Koukobin/Ermis/pulls)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-1.4-0baaaa.svg)](code_of_conduct.md)
[![License](https://img.shields.io/github/license/Koukobin/Chatapp)](https://github.com/Koukobin/Ermis/blob/master/LICENSE)

Ermis is a suite of applications designed for secure and seamless communication. The project consists of the following components:

- **Ermis-Client**: The user-facing client application for communication.
- **Ermis-Server**: The backend server that handles everything related to server-side.
- **Ermis-Common**: The shared library containing common functionalities and utilities used by both the client and server.

## Vision

My vision while creating Ermis was to develop a server-side application that anyone can deploy with ease and efficiency to ensure it can run on even the oldest hardware. Alongside this, I aimed to build a client-side application - that boasts an intuitive and user-friendly interface - with a solid performance to complement the server. With a primary focus on security, the Ermis platform employs robust encryption methods to ensure the protection of user data and privacy. Ultimately, I aimed to create a platform where users can communicate freely and openly, knowing their information is safe from prying eyes. My ultimate aim is to create a platform that anyone can host with ease and communicate with.

## Features

- **Real-time Communication**: Communicate seamlessly with others in real-time.
- **Media Sharing**: Easily share media within your chats.
- **Secure Connections**: Integrated with TLS encryption to ensure privacy and security.
- **PostgreSQL Integration**: Manage user data, messages, and logs in a reliable relational database geared towards data integrity.

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

1. [Ermis-Client (Dekstop)](./ErmisClient/Desktop/README.md)
2. [Ermis-Client (Mobile)](./ErmisClient/Mobile/ermis_client/README.md)
3. [Ermis-Server](./ErmisServer/README.md)
4. [Ermis-Common](./ErmisCommon/README.md)

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

1. **Fork the repository.**
2. **Open a new issue** — if you are intending to fix a bug or feature — describing it thoroughly.
3. **Create a new branch** for your feature or bug fix.
4. **Ensure your code is clean and readable** — at least to some extent.  
   It doesn't have to be perfect, but aim for clarity, and avoid ambiguity and complexity as much as possible.  
   
   Remember:
   >  _"An idiot admires complexity, while a genius appreciates simplicity"_  
   >  — **Terry A. Davis**  
   > 
   > _"Truth is ever to be found in simplicity, and not in the multiplicity and confusion of things"_  
   > — **Sir Isaac Newton**  
   
   Lastly, try adhering to the most rudimental and basic [programming principles].

> **Note:** if you are wondering what this project's style guide is — it doesn't have one. Nevertheless, if you are looking for a reference of how files should be formatted:
> 
> - For code formatting, I have found that [Google's Style guide] is thorough, comprehensive — and broadly applicable.
> - In terms of documentation, I would suggest [Microsoft's Writing Style Guide].
> 
> That said, don't sweat too much about following these strictly — I myself probably don't conform to most of their conventions.

5. **Submit a pull request** with a detailed description of your changes — and I may review it eventually.

For further details, see [CONTRIBUTING.md](./CONTRIBUTING.md).

[Microsoft's Writing Style Guide]: https://learn.microsoft.com/en-us/style-guide/welcome
[Google's Style guide]: https://google.github.io/styleguide
[programming principles]: https://github.com/webpro/programming-principles

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct][code-of-conduct]. By participating in this project you agree to abide by its terms.

[code-of-conduct]: CODE_OF_CONDUCT.md

## Report an issue

To report bugs, security vulnerabilities, or any other issues for that matter, please use the GitHub Issues tab to report them. Alternatively, you can contact me directly via email here: [ilias.koukovinis@gmail.com]

When reporting an issue, please include:
- A clear and descriptive title.
- Steps to reproduce the issue.
- Helpful log or error messages if available.
- Your environment details (OS, app version, etc.).

## Authors

* Ilias Koukovinis (2021) [ilias.koukovinis@gmail.com]

## License

Ermis is distributed under the _**GNU Affero General Public License Version 3.0**_ which can be found in the `LICENSE` file.  
For a brief synopsis of the license refer to [Wiki](https://github.com/Koukobin/Ermis/wiki/License).

By using this software, you agree to the terms outlined in the license agreement.

