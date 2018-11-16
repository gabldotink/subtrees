# Public Domain

Any creation published as Public Domain belongs to everyone and can be used in any way without conditions, not even crediting the author.

There are [four common ways](https://fairuse.stanford.edu/overview/public-domain/welcome/) that works arrive in the Public Domain:

* The copyright has expired
* The copyright owner failed to follow copyright renewal rules
* The copyright owner deliberately places it in the public domain, known as “dedication,”
* Copyright law does not protect this type of work.

You can | You cannot
--- | ---
✅ Without consent | ❌ Patent someone else's Public Domain work
✅ Copy | ❌ Use as basis for legal action against the author [1]
✅ Rename | ❌ Revoke Public Domain status of someone else's copy of a version of your work that was released under Public Domain [2][3]
✅ Redistribute | ❌ Relicense someone else's non-Public Domain work as Public Domain
✅ Modify | ❌ Release code you write to an employer as Public Domain
✅ Study |
✅ Sell |
✅ Use as inspiration |
✅ Omit author |
✅ Relicense under any other license |
✅ Relicense your own work as Public Domain regardless of previous license |
✅ Relicense your own Public Domain work under any other license [4] |
✅ Hold patents of your own Public Domain works [5][6] |

[1] Subject to local laws

[2] Unless proven that it was unrightfully released as Public Domain.

[3] In practice, you can effectively revoke status of your own Public Domain work if you manage to relicense it before anyone else obtains a copy. That includes, for example, deleting relevant commits from a public git repo to prevent someone from fork the project from that commit and relicense it from there.

[4] Whoever obtained a copy of your while under Public Domain can still use that specific version however pleases. Github forks for example.

[5] Patents apply to inventions, not creative works. It seems you can hold patents of your own Public Domain works at least when licensed under [CC0 1.0 Universal - Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/legalcode) [1] which contains:

 > "No trademark or patent rights held by Affirmer are waived, abandoned, surrendered, licensed or otherwise affected by this document."
 
[6] However, that CC0 license clause conflicts with [Stanford University definition of Public Domain](https://fairuse.stanford.edu/overview/public-domain/welcome/) which starts with:
 
 > "The term “public domain” refers to creative materials that are not protected by intellectual property laws such as copyright, trademark, or **patent laws**. The public owns these works, not an individual author or artist. Anyone can use a public domain work without obtaining permission, but no one can ever own it."
 
 Perhaps both are right and CC0 license is a specialization of the term Public Domain. Or perhaps CC0 is not a real Public Domain license if it reserves some rights to the author of a work lincesed under it.

## Controversy

In general, open-source advocates [do not sympathise](https://opensource.org/faq#public-domain) with Public Domain arguing that it [allows for open-source software to be copyrighted](https://opensource.org/faq#cc-zero) and relicensed under closed-source licenses, which is true. They prefer copyleft licenses such as [GNU GPL](https://en.wikipedia.org/wiki/GNU_General_Public_License) which enforces that any derivative work remains open-source.

## Profitable Public Domain Software

* SQLite - A free, reliable, portable and [most widely deployed](https://www.sqlite.org/mostdeployed.html) database engine in the world. While its engine code is open-source and Public Domain, the automated test code isn't. Tests are paramount in ensuring reliability and performance of database engines. Since SQLite [has 711 times as much test code than engine code](https://www.sqlite.org/testing.html), competition is strongly discouraged in face of the daunting task.

## Patents

Patents apply to inventions, not creative works. Having said that, in general it seems that one can retain Patent rights even after licensing their work as Public Domain:

* [CC0 1.0 Universal - Public Domain Dedication] license contains:

> "No trademark or patent rights held by Affirmer are waived, abandoned, surrendered, licensed or otherwise affected by this document."

## Popular Public Domain "equivalent" licenses

* [CC0](https://creativecommons.org/publicdomain/zero/1.0/legalcode) - According to [Stanford University definition of Public Domain](https://fairuse.stanford.edu/overview/public-domain/welcome/) this is not a true Public Domain license because if reserves rights of Patents to the author.

## License

This Gist is licensed as Public Domain.