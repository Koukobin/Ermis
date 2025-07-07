# How to contribute

[ilias.koukovinis@gmail.com]: https://mail.google.com/mail/u/0/?tab=rm&ogbl#search/ilias.koukovinis%40gmail.com

Thank you so much for wanting to contribute to Ermis! Your help is essential for keeping it great! 

Please note that this project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md).  
By participating, you are expected to uphold this code. Please report unacceptable behavior to [ilias.koukovinis@gmail.com].

[code-of-conduct]: CODE_OF_CONDUCT.md

---

In order to contribute:

1. **Fork the repository.**
2. **Open a new issue** — if you are intending to fix a bug or feature — describing it thoroughly.
3. **Create a new branch** for your feature or bug fix.
4. **Ensure your code is clean and readable** — at least to some extent.  
   It doesn't have to be perfect, but aim for clarity, and avoid ambiguity and complexity as much as possible.  

   Remember:
> [!IMPORTANT]
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _"An idiot admires complexity, while a genius appreciates simplicity"_  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; — **Terry A. Davis**  
> 
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _"Truth is ever to be found in simplicity, and not in the multiplicity and confusion of things"_  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; — **Sir Isaac Newton**  
>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_"Simplicity is prerequisite for reliability"_  
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; — **Dr. Edsger Dijkstra**

   Lastly, try adhering to the most rudimental and basic [programming principles].

> [!NOTE]
> **Note:** if you are wondering what this project's style guide is — it doesn't have one. Nevertheless, if you are looking for a reference
> of how files should be formatted:
> 
> - For code formatting, I have found that [Google's Style guide] is thorough, comprehensive — and broadly applicable.
> - In terms of documentation, I would suggest [Microsoft's Writing Style Guide].
> 
> That said, don't sweat too much about following these strictly, adhere to _your_ own style — I myself probably don't conform to most of their conventions.
>  
> As a rule of thumbs, though, try to imitate the coding style of similar lines of codes around your contribution. Consistency is essential in ensuring that the codebase is easy to navigate.
> 
> I think **Linus Torvalds** put it best:
> 
> *"Coding style is very personal, and I won’t force my views on anybody,  
> but this is what goes for anything that I have to be able to maintain, and  
> I’d prefer it for most other things too"*
> 

5. **Submit a pull request** with a detailed description of your changes — and I may review it eventually.

[Microsoft's Writing Style Guide]: https://learn.microsoft.com/en-us/style-guide/welcome
[Google's Style guide]: https://google.github.io/styleguide
[programming principles]: https://github.com/webpro/programming-principles

## Pull requests

Unless the change is something very trivial, such as correcting a typo, it's 
generally best to begin by opening a new issue outlining the bug or feature you 
intend to address. Even if you think it's relatively insignificant, it's helpful 
to know what people are working on.

Some examples of types of pull requests that are immediately helpful:

  - Fixing a typo.
  - Improving documentation.
  - Removing redundant configurations.

Guidelines for any code contributions:

  1. All contributions must be licensed under AGPL 3.0 (As dictated by the license) and all files must have a
     copy of the boilerplate license comment; i.e `LICENSE.txt`.
  2. Please squash all commits for a change into a single commit (this can be done using `git rebase -i`).  
     Do your best to have a [well-formed commit message] for the change.

[well-formed commit message]: https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

## Dependencies

Dependencies in our projects have hidden costs when added. Dependency management tools such as Pub Package Manager and NPM make adding 3rd party libraries exceptionally easy — sometimes **_too easy_**. With just a single line of YAML, you can import thousands of lines of code into your project and call it a day. Great! You got the task done. But at what cost? Did you contemplate the maintainability of the code on the long-term, the potential security implications, or the extraneous complexity of what you just introduced in the codebase?

Bottom line is: dependencies add hidden costs. Whilst during initial implementation dependencies can enchance productivity and speed up the development process — their costs eventually manifest and can cause catastrophic problems (tech debt, dependency hell, bugs etc.), significantly impacting long-term maintainability, security, and overall project wellbeing. Any dependency should be considered “bad” by default, and only tolerated because it provides a service in a better way than can be achieved locally. In addition to that, ensure added dependencies are actively maintained and also originate from a trusted dev team.

Thus, a foundational pillar when contributing to Ermis is:  
<p align="center">
   <b><i>Reduce dependencies to the minimum possible level</i></b>
</p>

## Code documentation

* Avoid code documentation that simply restates what the code already illustrates.
  When possible, employ the code itself to express intent clearly, rather than relying on comments.  
  Example 1 : `int temperatureCelsius = 35;` instead of `int temperature = 35; // In Celsius`.  
  Example 2 : `assert(user != nullptr);` instead of `/* presume user is not null here */`.
* At declaration level, the documentation should explain how to use a function, variable or API; when its applicable; why it's needed; and scenarios where it can be useful.
* At implementation level, comments should offer a high-level overview of the logic and explain why a certain approach was chosen — if it's not immediately self-evident.

## Resources

- [How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)
- [Using Pull Requests](https://help.github.com/articles/about-pull-requests/)
- [GitHub Help](https://help.github.com)
- [How to Import Project into different IDEs](https://github.com/Koukobin/Ermis/wiki/Importing-Maven-Java-Project-in-Different-IDEs)

