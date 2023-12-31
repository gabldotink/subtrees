---
draft: false
aliases: ["/ml/"]
---

# പരമ്പരാഗത കമ്മിറ്റുകൾ 1.0.0

## സംഗ്രഹം

കമ്മിറ്റ് സന്ദേശങ്ങൾക്ക് മുകളിലുള്ള ഒരു ഭാരം കുറഞ്ഞ കൺവെൻഷനാണ് കൺവെൻഷണൽ കമ്മിറ്റ്സ് സ്പെസിഫിക്കേഷൻ.
വ്യക്തമായ പ്രതിബദ്ധതയുള്ള ചരിത്രം സൃഷ്‌ടിക്കുന്നതിന് ഇത് എളുപ്പമുള്ള ഒരു കൂട്ടം നിയമങ്ങൾ നൽകുന്നു;
ഇത് മുകളിൽ ഓട്ടോമേറ്റഡ് ടൂളുകൾ എഴുതുന്നത് എളുപ്പമാക്കുന്നു.
ഈ കൺവെൻഷൻ [SemVer](http://semver.org),
കമ്മിറ്റ് സന്ദേശങ്ങളിൽ വരുത്തിയ സവിശേഷതകൾ, പരിഹാരങ്ങൾ, ബ്രേക്കിംഗ് മാറ്റങ്ങൾ എന്നിവ വിവരിച്ചുകൊണ്ട്.

പ്രതിബദ്ധത സന്ദേശം ഇനിപ്പറയുന്ന രീതിയിൽ ക്രമീകരിക്കണം:

---

```
<type>[ഓപ്ഷണൽ സ്കോപ്പ്]: <വിവരണം>

[ഓപ്ഷണൽ ബോഡി]

[ഓപ്ഷണൽ അടിക്കുറിപ്പ്(കൾ)]
```
---

<br />
കമ്മിറ്റിൽ ഇനിപ്പറയുന്ന ഘടനാപരമായ ഘടകങ്ങൾ അടങ്ങിയിരിക്കുന്നു, ഉദ്ദേശ്യം ആശയവിനിമയം നടത്തുന്നതിന്
നിങ്ങളുടെ ലൈബ്രറിയുടെ ഉപഭോക്താക്കൾ:

1. ** പരിഹരിക്കുക:** നിങ്ങളുടെ കോഡ്‌ബേസിലെ ഒരു ബഗ് പാച്ചുചെയ്യുന്ന _type_ `fix` (ഇത് സെമാന്റിക് പതിപ്പിംഗിലെ [`PATCH`](http://semver.org/#summary) മായി ബന്ധപ്പെട്ടിരിക്കുന്നു).
1. **feat:** _type_ `feat` ന്റെ ഒരു പ്രതിബദ്ധത കോഡ്ബേസിലേക്ക് ഒരു പുതിയ സവിശേഷത അവതരിപ്പിക്കുന്നു (ഇത് സെമാന്റിക് വേർഷനിംഗിലെ [`MINOR`](http://semver.org/#summary) എന്നതുമായി ബന്ധപ്പെട്ടിരിക്കുന്നു).
1. **ബ്രേക്കിംഗ് മാറ്റം:** 'BREAKING CHANGE:' എന്ന അടിക്കുറിപ്പുള്ള ഒരു പ്രതിബദ്ധത, അല്ലെങ്കിൽ തരം/സ്കോപ്പിന് ശേഷം `!` ചേർക്കുക, ഒരു ബ്രേക്കിംഗ് API മാറ്റം അവതരിപ്പിക്കുന്നു ([`MAJOR`](http:/ /semver.org/#summary) സെമാന്റിക് പതിപ്പിൽ).
ഒരു ബ്രേക്കിംഗ് മാറ്റം ഏത് _തരം
1. `fix:`, `feat:` എന്നിവ ഒഴികെയുള്ള _types_ അനുവദനീയമാണ്, ഉദാഹരണത്തിന് [@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional) ([കോണീയ കൺവെൻഷൻ](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)) ശുപാർശ ചെയ്യുന്നത് `build:`, `chore: `,
  `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:` എന്നിവയും മറ്റുള്ളവയും.
1. `BREAKING CHANGE: <description>` ഒഴികെയുള്ള _footers_ നൽകുകയും സമാനമായ ഒരു കൺവെൻഷൻ പിന്തുടരുകയും ചെയ്യാം
  [git ട്രെയിലർ ഫോർമാറ്റ്](https://git-scm.com/docs/git-interpret-trailers).

അധിക തരങ്ങൾ കൺവെൻഷണൽ കമ്മിറ്റ് സ്‌പെസിഫിക്കേഷൻ നിർബന്ധമാക്കിയിട്ടില്ല, കൂടാതെ സെമാന്റിക് വേർഷനിംഗിൽ (അവയിൽ ഒരു ബ്രേക്കിംഗ് മാറ്റം ഉൾപ്പെടുത്തിയില്ലെങ്കിൽ) പ്രത്യക്ഷമായ ഫലമൊന്നുമില്ല.
<br /><br />
കൂടുതൽ സാന്ദർഭിക വിവരങ്ങൾ നൽകുന്നതിന് ഒരു കമ്മിറ്റിന്റെ തരത്തിന് ഒരു സ്കോപ്പ് നൽകാം, അത് പരാൻതീസിസിൽ അടങ്ങിയിരിക്കുന്നു, ഉദാ., `ഫീറ്റ്(പാഴ്സർ): അറേകൾ പാഴ്‌സ് ചെയ്യാനുള്ള കഴിവ് ചേർക്കുക`.

## ഉദാഹരണങ്ങൾ

### വിവരണവും ബ്രേക്കിംഗ് മാറ്റ ഫൂട്ടറും സഹിതമുള്ള കമ്മിറ്റ് സന്ദേശം
```
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

### മാറ്റത്തെ തകർക്കുന്നതിലേക്ക് ശ്രദ്ധ ആകർഷിക്കാൻ `!` എന്ന സന്ദേശം നൽകൂ
```
feat!: send an email to the customer when a product is shipped
```

### വ്യാപ്തിയുള്ള സന്ദേശം കമ്മിറ്റ് ചെയ്‌ത് മാറ്റത്തിലേക്ക് ശ്രദ്ധ ആകർഷിക്കാൻ `!`
```
feat(api)!: send an email to the customer when a product is shipped
```

### `!` എന്നതും ബ്രേക്കിംഗ് മാറ്റുക അടിക്കുറിപ്പും ഉപയോഗിച്ച് കമ്മിറ്റ് സന്ദേശം
```
chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

### ശരീരമില്ലാതെ കമ്മിറ്റ് സന്ദേശം
```
docs: correct spelling of CHANGELOG
```

### സ്കോപ്പുള്ള സന്ദേശം കമ്മിറ്റ് ചെയ്യുക
```
feat(lang): add polish language
```

### മൾട്ടി-പാരഗ്രാഫ് ബോഡിയും ഒന്നിലധികം ഫൂട്ടറുകളും ഉള്ള കമ്മിറ്റ് സന്ദേശം
```
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.

Reviewed-by: Z
Refs: #123
```

## Specification

"നിർബന്ധം"(“MUST”), "ആവശ്യമില്ല" (“MUST NOT”), "ആവശ്യമുള്ളത്" (“REQUIRED”), "ചെയ്യും" (“SHALL”), "ചെയില്ല"(“SHALL NOT”), "വേണം" (“SHOULD”), "ചെയ്യരുത്" (“SHOULD NOT”), "ശുപാർശ ചെയ്യുന്നു" (“RECOMMENDS”), ഒരുപക്ഷേ ("MAY"), "ഓപ്ഷണൽ" (“OPTIONAL”)എന്നീ പ്രധാന വാക്കുകൾ ഈ പ്രമാണത്തിൽ വിവരിച്ചിരിക്കുന്നതുപോലെ വ്യാഖ്യാനിക്കേണ്ടതാണ് [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

1. കമ്മിറ്റുകൾ ഒരു നാമം, `feat`,` ഫിക്സ്` മുതലായവ അടങ്ങുന്ന ഒരു തരം പ്രിഫിക്‌സിൽ ആരംഭിക്കണം, തുടർന്ന് ഓപ്‌ഷണൽ സ്കോപ്പ്, `!` ഓപ്‌ഷണൽ, ഒരു കോളനും ആവശ്യമായ സ്‌പെയ്‌സും.
2. ഒരു കമ്മിറ്റ് ആപ്ലിക്കേഷനിലേക്കോ ലൈബ്രറിയിലേക്കോ പുതിയ പ്രവർത്തനം ചേർക്കുമ്പോൾ `feat` തരം ഉപയോഗിക്കണം.
3. കമ്മിറ്റ് ആപ്ലിക്കേഷൻ കോഡിലെ (ബഗ്) ഒരു പിശകിന്റെ തിരുത്തലിനെ പ്രതിനിധീകരിക്കുമ്പോൾ `fix` തരം ഉപയോഗിക്കണം.
4. ഒരു തരത്തിന് ശേഷം ഒരു സ്കോപ്പ് ചേർക്കാം. ഒരു സ്കോപ്പിൽ പരാൻതീസിസിൽ ഉൾപ്പെടുത്തിയിരിക്കുന്ന കോഡ് ബേസിന്റെ ഒരു വിഭാഗത്തെ വിവരിക്കുന്ന ഒരു നാമം അടങ്ങിയിരിക്കണം, ഉദാ, `fix(parser):`.
5. ഒരു വിവരണം ഉടൻ തന്നെ ടൈപ്പ് / സ്കോപ്പ് പ്രിഫിക്‌സിന്റെ അർദ്ധവിരാമവും സ്ഥലവും പിന്തുടരേണ്ടതാണ്. കോഡിൽ വരുത്തിയ മാറ്റങ്ങളുടെ ഒരു ഹ്രസ്വ സംഗ്രഹമാണ് വിവരണം, ഉദാ, _fix: string-ൽ ഒന്നിലധികം സ്‌പെയ്‌സുകൾ ഉള്ളപ്പോൾ അറേ പാഴ്‌സിംഗ് പ്രശ്‌നം._.
6. കോഡ് മാറ്റങ്ങളെക്കുറിച്ചുള്ള കൂടുതൽ സാന്ദർഭിക വിവരങ്ങൾ നൽകിക്കൊണ്ട് ഹ്രസ്വ വിവരണത്തിന് ശേഷം ദൈർഘ്യമേറിയ പ്രതിബദ്ധതയുള്ള ബോഡി ചേർക്കാവുന്നതാണ്. വിവരണത്തിന് ശേഷം ഒരു ശൂന്യമായ വരയ്ക്ക് ശേഷം ബോഡി ആരംഭിക്കണം.
7. ഒരു കമ്മിറ്റ് ബോഡി ഒരു സ്വതന്ത്ര രൂപമാണ്, കൂടാതെ ഒരു പുതിയ വരിയാൽ വേർതിരിക്കുന്ന എത്ര ഖണ്ഡികകളും അടങ്ങിയിരിക്കാം.
8. ഒന്നോ അതിലധികമോ അടിക്കുറിപ്പുകൾ ബോഡിക്ക് ശേഷം ഒരു ശൂന്യമായ വരി ചേർക്കാം. ഓരോ അടിക്കുറിപ്പിലും ഒരു ടോക്കൺ വാക്ക് ഉണ്ടായിരിക്കണം, അതിന് ശേഷം `: <space>` അല്ലെങ്കിൽ `<space> #` സെപ്പറേറ്റർ, തുടർന്ന് ഒരു സ്ട്രിംഗ് മൂല്യം (ഇത് [git ട്രെയിലർ കൺവെൻഷൻ] (https://git) പ്രചോദിപ്പിച്ചതാണ് -scm.com/docs/git-interpret-trailers)).
9. ഒരു അടിക്കുറിപ്പ് ടോക്കൺ വാക്ക് വൈറ്റ്‌സ്‌പേസ് പ്രതീകങ്ങൾക്ക് പകരം `-` ഉപയോഗിക്കണം, ഉദാ,`Acked-by` (ഒരു മൾട്ടി-പാരഗ്രാഫ് ബോഡിയിൽ നിന്ന് അടിക്കുറിപ്പ് വിഭാഗത്തെ വേർതിരിക്കാൻ ഇത് സഹായിക്കുന്നു) . `BREAKING CHANGE` എന്നതിനായി ഒരു അപവാദം ഉണ്ടാക്കിയിരിക്കുന്നു, അത് ഒരു ടോക്കൺ പദമായും ഉപയോഗിക്കാം.
10. ഒരു അടിക്കുറിപ്പിൽ സ്‌പെയ്‌സുകളും ബ്ലാങ്ക് ലൈനുകളും അടങ്ങിയിരിക്കാം, അടുത്ത സെപ്പറേറ്റർ / ടാബ് നിരീക്ഷിക്കുമ്പോൾ പാഴ്‌സിംഗ് അവസാനിക്കണം.
11. ബ്രേക്ക് മാറ്റങ്ങൾ ഒരു കമ്മിറ്റിന്റെ തരം/സ്കോപ്പ് പ്രിഫിക്‌സിലോ അടിക്കുറിപ്പിലെ എൻട്രിയായോ സൂചിപ്പിക്കണം.
12. ഒരു അടിക്കുറിപ്പായി ഉൾപ്പെടുത്തിയാൽ, ബ്രേക്ക് മാറ്റത്തിൽ വലിയക്ഷര വാചകം BREAKING CHANGE ഉണ്ടായിരിക്കണം, തുടർന്ന് ഒരു കോളനും ഒരു വിവരണവും, ഉദാ, _BREAKING CHANGE: എൻവയോൺമെന്റ് വേരിയബിളുകൾ ഇപ്പോൾ കോൺഫിഗറേഷൻ ഫയലുകളേക്കാൾ മുൻഗണന നൽകുന്നു_.
13. തരം / സ്കോപ്പ് പ്രിഫിക്സിൽ ഉൾപ്പെടുത്തിയിട്ടുണ്ടെങ്കിൽ, ബ്രേക്ക് മാറ്റങ്ങൾ `:` എന്നതിന് തൊട്ടുപിന്നാലെ ഒരു `!` കൊണ്ട് സൂചിപ്പിക്കണം. `!` ഉപയോഗിക്കുകയാണെങ്കിൽ, `BREAKING CHANGE:` അടിക്കുറിപ്പ് വിഭാഗത്തിൽ നിന്ന് ഒഴിവാക്കിയേക്കാം, കൂടാതെ ബ്രേക്ക് മാറ്റത്തെ വിവരിക്കാൻ പ്രതിബദ്ധത വിവരണം ഉപയോഗിക്കണം.
14. കമ്മിറ്റ് സന്ദേശങ്ങളിൽ `feat`,`fix` എന്നിവ ഒഴികെയുള്ള തരങ്ങൾ ഉപയോഗിക്കാം, ഉദാ _docs: updated ref docs._.
15. കൺവെൻഷണൽ കമ്മിറ്റുകൾ ഉണ്ടാക്കുന്ന ഇൻഫർമേഷൻ യൂണിറ്റുകളെ കേസ് സെൻസിറ്റീവ് ഇംപ്ലിമെന്ററുകളായി കണക്കാക്കരുത്, ബ്രേക്കിംഗ് ചേഞ്ച് ഒഴികെ, അത് വലിയക്ഷരത്തിലായിരിക്കണം.
16. ഒരു അടിക്കുറിപ്പിൽ ഉപയോഗിക്കുമ്പോൾ BREAKING CHANGE എന്നത് BREAKING-CHANGE MUST എന്നതിന്റെ  പര്യായമായിരിക്കണം.

## എന്തിനാണ് പരമ്പരാഗത കമ്മിറ്റുകൾ ഉപയോഗിക്കുന്നത്?

* സ്വയമേവ മാറ്റങ്ങൾ സൃഷ്ടിക്കുന്നു.
* സ്വയമേവ ഒരു സെമാന്റിക് പതിപ്പ് ബമ്പ് നിർണ്ണയിക്കുന്നു (കമ്മിറ്റുകളുടെ തരങ്ങളെ അടിസ്ഥാനമാക്കി).
* ടീമംഗങ്ങളോടും പൊതുജനങ്ങളോടും മറ്റ് പങ്കാളികളോടും മാറ്റങ്ങളുടെ സ്വഭാവം ആശയവിനിമയം നടത്തുക.
* ബിൽഡ്, പ്രസിദ്ധീകരണ പ്രക്രിയകൾ ട്രിഗർ ചെയ്യുന്നു.
* പര്യവേക്ഷണം ചെയ്യാൻ ആളുകളെ അനുവദിച്ചുകൊണ്ട് നിങ്ങളുടെ പ്രോജക്‌ടുകളിലേക്ക് സംഭാവന നൽകുന്നത് എളുപ്പമാക്കുന്നു
   കൂടുതൽ ഘടനാപരമായ പ്രതിബദ്ധതയുള്ള ചരിത്രം.

## FAQ (പതിവുചോദ്യങ്ങൾ)

### പ്രാരംഭ വികസന ഘട്ടത്തിൽ കമ്മിറ്റ് സന്ദേശങ്ങൾ ഞാൻ എങ്ങനെ കൈകാര്യം ചെയ്യണം?

നിങ്ങൾ ഇതിനകം ഉൽപ്പന്നം പുറത്തിറക്കിയതുപോലെ തുടരാൻ ഞങ്ങൾ ശുപാർശ ചെയ്യുന്നു. സാധാരണ *somebody*, അത് നിങ്ങളുടെ സഹ സോഫ്റ്റ്‌വെയർ ഡെവലപ്പർമാർ ആണെങ്കിൽ പോലും, നിങ്ങളുടെ സോഫ്റ്റ്‌വെയർ ഉപയോഗിക്കുന്നു. എന്താണ് ശരിയാക്കിയത്, എന്താണ് തകരുന്നത് തുടങ്ങിയവ അറിയാൻ അവർ ആഗ്രഹിക്കും.

### കമ്മിറ്റ് തലക്കെട്ടിലെ തരങ്ങൾ വലിയക്ഷരമാണോ ചെറിയക്ഷരമാണോ?

ഏത് കേസിംഗും ഉപയോഗിക്കാം, പക്ഷേ സ്ഥിരത പുലർത്തുന്നതാണ് നല്ലത്.

### പ്രതിബദ്ധത ഒന്നിലധികം കമ്മിറ്റ് തരങ്ങളുമായി പൊരുത്തപ്പെടുന്നെങ്കിൽ ഞാൻ എന്തുചെയ്യും?

തിരികെ പോയി സാധ്യമാകുമ്പോഴെല്ലാം ഒന്നിലധികം പ്രതിബദ്ധതകൾ ഉണ്ടാക്കുക. കൂടുതൽ സംഘടിത കമ്മിറ്റുകളും PR-കളും ഉണ്ടാക്കാൻ ഞങ്ങളെ പ്രേരിപ്പിക്കാനുള്ള കഴിവാണ് പരമ്പരാഗത കമ്മിറ്റുകളുടെ പ്രയോജനത്തിന്റെ ഭാഗം.

### ഇത് ദ്രുതഗതിയിലുള്ള വികസനത്തെയും വേഗത്തിലുള്ള ആവർത്തനത്തെയും നിരുത്സാഹപ്പെടുത്തുന്നില്ലേ?

ഇത് ക്രമരഹിതമായ രീതിയിൽ വേഗത്തിൽ നീങ്ങുന്നത് നിരുത്സാഹപ്പെടുത്തുന്നു. വ്യത്യസ്‌ത സംഭാവകർക്കൊപ്പം ഒന്നിലധികം പ്രോജക്‌റ്റുകളിലുടനീളം വേഗത്തിൽ ദീർഘകാലത്തേക്ക് നീങ്ങാൻ ഇത് നിങ്ങളെ സഹായിക്കുന്നു.

### കൺവെൻഷണൽ കമ്മിറ്റുകൾ ഡെവലപ്പർമാരെ അവർ ചെയ്യുന്ന തരത്തിലുള്ള പ്രതിബദ്ധതകൾ പരിമിതപ്പെടുത്താൻ ഇടയാക്കുമോ, കാരണം അവർ നൽകിയിരിക്കുന്ന തരത്തിൽ ചിന്തിക്കും?

പരിഹാരങ്ങൾ പോലുള്ള ചില പ്രത്യേക കമ്മിറ്റുകൾ കൂടുതൽ ചെയ്യാൻ പരമ്പരാഗത കമ്മിറ്റുകൾ ഞങ്ങളെ പ്രോത്സാഹിപ്പിക്കുന്നു. അതുകൂടാതെ, പരമ്പരാഗത കമ്മിറ്റുകളുടെ വഴക്കം നിങ്ങളുടെ ടീമിനെ അവരുടേതായ തരങ്ങളുമായി വരാനും കാലക്രമേണ ആ തരങ്ങൾ മാറ്റാനും അനുവദിക്കുന്നു.

### ഇത് SemVer-മായി എങ്ങനെ ബന്ധപ്പെട്ടിരിക്കുന്നു?

പ്രതിബദ്ധത തരം `fix` എന്നത് ഒരു`PATCH` പതിപ്പ് മാറ്റത്തിലേക്ക് വിവർത്തനം ചെയ്യുന്നു. പ്രതിബദ്ധത തരം `feat` എന്നത് ഒരു`MINOR` പതിപ്പ് മാറ്റത്തിലേക്ക് വിവർത്തനം ചെയ്യുന്നു. `BREAKING CHANGE` എന്ന ടെക്‌സ്‌റ്റുള്ള പ്രതിബദ്ധതകൾ, അവയുടെ തരം പരിഗണിക്കാതെ തന്നെ, ഒരു `MAJOR` പതിപ്പ് മാറ്റത്തിലേക്ക് വിവർത്തനം ചെയ്യപ്പെടും.

### എന്റെ വിപുലീകരണങ്ങൾ പരമ്പരാഗത കമ്മിറ്റ് സ്പെസിഫിക്കേഷനിലേക്ക് എങ്ങനെ പതിപ്പിക്കണം, ഉദാ. `@ jameswomack / conventional-commit-spec`?

ഈ സ്‌പെക്കിലേക്ക് നിങ്ങളുടെ സ്വന്തം വിപുലീകരണം റിലീസ് ചെയ്യാൻ SemVer ഉപയോഗിക്കാൻ ഞങ്ങൾ ശുപാർശ ചെയ്യുന്നു (കൂടാതെ ഈ വിപുലീകരണം നടത്താൻ ഞങ്ങൾ നിങ്ങളെ പ്രോത്സാഹിപ്പിക്കുന്നു!)

### ഞാൻ അബദ്ധവശാൽ തെറ്റായ കമ്മിറ്റ് തരം ഉപയോഗിച്ചാൽ ഞാൻ എന്തുചെയ്യും?

#### നിങ്ങൾ സ്പെസിഫിക്കേഷനുള്ളതും എന്നാൽ ശരിയായ തരമല്ലാത്തതുമായ ഒരു തരം ഉപയോഗിക്കുമ്പോൾ, ഉദാ. `feat` എന്നതിന് പകരം `fix`

തെറ്റ് ലയിപ്പിക്കുന്നതിനോ പുറത്തുവിടുന്നതിനോ മുമ്പ്, കമ്മിറ്റ് ഹിസ്റ്ററി എഡിറ്റ് ചെയ്യാൻ `git rebase -i` ഉപയോഗിക്കാൻ ഞങ്ങൾ ശുപാർശ ചെയ്യുന്നു. റിലീസിന് ശേഷം, നിങ്ങൾ ഉപയോഗിക്കുന്ന ഉപകരണങ്ങളും പ്രക്രിയകളും അനുസരിച്ച് വൃത്തിയാക്കൽ വ്യത്യസ്തമായിരിക്കും.

#### നിങ്ങൾ സ്‌പെക്കിന്റെ *not* എന്ന തരം ഉപയോഗിക്കുമ്പോൾ, ഉദാ. `feat` എന്നതിന് പകരം `feet`

ഏറ്റവും മോശം സാഹചര്യത്തിൽ, ഒരു കമ്മിറ്റ് കൺവെൻഷണൽ കമ്മിറ്റ് സ്പെസിഫിക്കേഷൻ പാലിക്കുന്നില്ലെങ്കിൽ അത് ലോകാവസാനമല്ല. സ്‌പെക്കിനെ അടിസ്ഥാനമാക്കിയുള്ള ടൂളുകളാൽ പ്രതിബദ്ധത നഷ്‌ടമാകുമെന്നാണ് ഇതിനർത്ഥം.

### എന്റെ എല്ലാ സംഭാവകരും പരമ്പരാഗത കമ്മിറ്റ് സ്പെസിഫിക്കേഷൻ ഉപയോഗിക്കേണ്ടതുണ്ടോ?

ഇല്ല! നിങ്ങൾ Git-ൽ സ്ക്വാഷ് അധിഷ്‌ഠിത വർക്ക്‌ഫ്ലോ ഉപയോഗിക്കുകയാണെങ്കിൽ ലീഡ് മെയിന്റനർമാർക്ക് കമ്മിറ്റ് മെസേജുകൾ ലയിപ്പിക്കുമ്പോൾ അവ വൃത്തിയാക്കാൻ കഴിയും-കാഷ്വൽ കമ്മിറ്ററുകളിൽ ജോലിഭാരം ചേർക്കുന്നില്ല.
ഒരു പുൾ അഭ്യർത്ഥനയിൽ നിന്ന് നിങ്ങളുടെ ജിറ്റ് സിസ്റ്റം സ്വയമേവ സ്ക്വാഷ് ചെയ്യപ്പെടുകയും ലയനത്തിനായി ശരിയായ ജിറ്റ് കമ്മിറ്റ് സന്ദേശം നൽകുന്നതിന് ലീഡ് മെയിന്റനർക്കായി ഒരു ഫോം അവതരിപ്പിക്കുകയും ചെയ്യുക എന്നതാണ് ഇതിനുള്ള ഒരു പൊതു വർക്ക്ഫ്ലോ.

### കൺവെൻഷണൽ കമ്മിറ്റുകൾ എങ്ങനെയാണ് റിവർട്ട് കമ്മിറ്റുകൾ കൈകാര്യം ചെയ്യുന്നത്?

കോഡ് പഴയപടിയാക്കുന്നത് സങ്കീർണ്ണമായേക്കാം: നിങ്ങൾ ഒന്നിലധികം കമ്മിറ്റുകൾ പഴയപടിയാക്കുകയാണോ? നിങ്ങൾ ഒരു ഫീച്ചർ പഴയപടിയാക്കുകയാണെങ്കിൽ, അടുത്ത റിലീസ് ഒരു പാച്ച് ആയിരിക്കണമോ?

പരമ്പരാഗത കമ്മീഷനുകൾ വിപരീത സ്വഭാവം നിർവചിക്കുന്നതിന് വ്യക്തമായ ശ്രമം നടത്തുന്നില്ല. പകരം, ഞങ്ങൾ അത് ടൂളിങ്ങിന് വിടുന്നു
റിവേർട്ടുകൾ കൈകാര്യം ചെയ്യുന്നതിനുള്ള യുക്തി വികസിപ്പിക്കുന്നതിന് രചയിതാക്കൾ _types_, _footers_ എന്നിവയുടെ വഴക്കം ഉപയോഗിക്കുന്നു.

ഒരു ശുപാർശ, `റീവർട്ട്` തരവും പഴയപടിയാക്കപ്പെടുന്ന പ്രതിബദ്ധതയുള്ള SHA-കളെ പരാമർശിക്കുന്ന ഒരു അടിക്കുറിപ്പും ഉപയോഗിക്കുക എന്നതാണ്:

```
revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```
