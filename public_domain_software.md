# Public Domain Software

The term “public domain” refers to creative materials that are not protected by intellectual property laws such as copyright, trademark, or patent laws. The public owns these works, not an individual author or artist. Anyone can use a public domain work without obtaining permission, but no one can ever own it. - [Stanford University definition](https://fairuse.stanford.edu/overview/public-domain/welcome/)

Public Domain implies waiving all copyright and thus **Public Domain is not a license**. That's not to say that all software require a license. They perfectly fine without a license while dedicated to Public Domain.

By definition, a software license assert some form of copyright and therefore **no license is Public Domain**.


**Can** | **Cannot**
--- | ---
✅ Sell| ❌ Copyright
✅ Copy| ❌ Patent **inventions** found in Public Domain work [3]
✅ Rename| ❌ Revoke Public Domain status of a third-party held copy [4]
✅ Distribute| ❌ Dedicate someone else's licensed work to Public Domain
✅ Modify| ❌ Dedicate paid-for work to Public Domain unless employer allows
✅ Study| ❌ Claim unrightful authorship of Public Domain work [5]
✅ Publish| ❌ Use as basis for legal action against the author [6]
✅ Compile|
✅ Use|
✅ Mix with non Public Domain work if no license is broken|
✅ Omit author|
✅ Dedicate your work to Public Domain regardless of current license [1]|
✅ License Public Domain work under any license [2]|

**[1]** All copyright holders must agree. Dedicating to Public Domain requires waiving of copyright causing any license to become null and void. This action is not retroactive in the sense that copies of previous versions retain original licenses.

**[2]** This invariably revokes Public Domain status of that copy going forward, regardless of license chosen. Other copies of previous versions of the work remain in Public Domain. i.e Forks of commits before license changes.

In practice, Public Domain status can be completely revoked from a work provided no previous copies are held by third-party. This might involve, for example, deleting relevant commits from all public git repositories to prevent someone from forking the project from that commit.

**[3]** Patents apply to inventions, not creative works. It is possible to patent inventions before using them in them in Public Domain work.

**[4]** Unless proven that it was unrightfully dedicated to Public Domain.

**[5]** Even though you can freely omit authorship, you cannot wrongfully claim authorship of work dedicated to Public Domain.

**[6]** Local laws apply.

## Controversy

In general, open-source advocates [do not sympathise](https://opensource.org/faq#public-domain) with Public Domain arguing that it [revokes all copyright rights in open-source software](https://opensource.org/faq#cc-zero) allowing it to be licensed under closed-source licenses, which is true. They prefer copyleft licenses such as [GNU GPL](https://en.wikipedia.org/wiki/GNU_General_Public_License) which enforces that any derivative work remains open-source and with unaltered license.

## Profitable Public Domain software

* SQLite - A free, reliable, portable and [most widely deployed](https://www.sqlite.org/mostdeployed.html) database engine in the world. While the database engine is in Public Domain, its automated test suit which is paramount to ensure reliability and performance [has 700 times as much code than the engine](https://www.sqlite.org/testing.html) is closed source. This strongly discourages any competition from copying the engine code when faced with that daunting task of writing all tests from scratch.

## Popular "Public Domain like" licenses

* [CC0](https://creativecommons.org/publicdomain/zero/1.0/legalcode) - According to [Stanford University definition of Public Domain](https://fairuse.stanford.edu/overview/public-domain/welcome/) this is not a true Public Domain because it reserves rights of Patents to the author.

* [WTFPL (Do What the Fuck You Want To Public License)](https://en.wikipedia.org/wiki/WTFPL#Version_2) - Informal license that implies total freedom of use. Cannot be considered Public Domain compatible as it contains copyright.

## License

This Gist is dedicated to Public Domain.