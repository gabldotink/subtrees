"use strict";(self.webpackChunkrecoil=self.webpackChunkrecoil||[]).push([[1204],{3905:function(e,t,n){n.d(t,{Zo:function(){return p},kt:function(){return m}});var r=n(7294);function a(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function i(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function o(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?i(Object(n),!0).forEach((function(t){a(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):i(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function s(e,t){if(null==e)return{};var n,r,a=function(e,t){if(null==e)return{};var n,r,a={},i=Object.keys(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||(a[n]=e[n]);return a}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}var c=r.createContext({}),l=function(e){var t=r.useContext(c),n=t;return e&&(n="function"==typeof e?e(t):o(o({},t),e)),n},p=function(e){var t=l(e.components);return r.createElement(c.Provider,{value:t},e.children)},u={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},d=r.forwardRef((function(e,t){var n=e.components,a=e.mdxType,i=e.originalType,c=e.parentName,p=s(e,["components","mdxType","originalType","parentName"]),d=l(n),m=a,h=d["".concat(c,".").concat(m)]||d[m]||u[m]||i;return n?r.createElement(h,o(o({ref:t},p),{},{components:n})):r.createElement(h,o({ref:t},p))}));function m(e,t){var n=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var i=n.length,o=new Array(i);o[0]=d;var s={};for(var c in t)hasOwnProperty.call(t,c)&&(s[c]=t[c]);s.originalType=e,s.mdxType="string"==typeof e?e:a,o[1]=s;for(var l=2;l<i;l++)o[l]=n[l];return r.createElement.apply(null,o)}return r.createElement.apply(null,n)}d.displayName="MDXCreateElement"},486:function(e,t,n){n.r(t),n.d(t,{frontMatter:function(){return s},contentTitle:function(){return c},metadata:function(){return l},toc:function(){return p},default:function(){return d}});var r=n(7462),a=n(3366),i=(n(7294),n(3905)),o=["components"],s={title:"URL Persistence",sidebar_label:"URL Persistence"},c=void 0,l={unversionedId:"recoil-sync/url-persistence",id:"recoil-sync/url-persistence",title:"URL Persistence",description:"One of the built-in external store syncing mechanisms provided with the recoil-sync package is URL persistence.  This enables users to easily initialize atoms based on the URL, update the URL when atoms mutate, and subscribe to URL changes (such as the back button).  Atom state changes can be configured to either replace the current URL or push a new entry in the browser history stack.",source:"@site/docs/recoil-sync/url-persistence.md",sourceDirName:"recoil-sync",slug:"/recoil-sync/url-persistence",permalink:"/docs/recoil-sync/url-persistence",editUrl:"https://github.com/facebookexperimental/Recoil/edit/docs/docs/docs/recoil-sync/url-persistence.md",tags:[],version:"current",frontMatter:{title:"URL Persistence",sidebar_label:"URL Persistence"},sidebar:"recoil-sync",previous:{title:"Implementing a Store",permalink:"/docs/recoil-sync/implement-store"},next:{title:"<RecoilSync>",permalink:"/docs/recoil-sync/api/RecoilSync"}},p=[{value:"Example",id:"example",children:[],level:2},{value:"URL Encodings",id:"url-encodings",children:[{value:"State Serialization",id:"state-serialization",children:[],level:3},{value:"Part of the URL",id:"part-of-the-url",children:[],level:3}],level:2},{value:"Push vs Replace",id:"push-vs-replace",children:[],level:2},{value:"Multiple Encodings",id:"multiple-encodings",children:[],level:2}],u={toc:p};function d(e){var t=e.components,n=(0,a.Z)(e,o);return(0,i.kt)("wrapper",(0,r.Z)({},u,n,{components:t,mdxType:"MDXLayout"}),(0,i.kt)("p",null,"One of the built-in external store syncing mechanisms provided with the ",(0,i.kt)("a",{parentName:"p",href:"/docs/recoil-sync/introduction"},(0,i.kt)("inlineCode",{parentName:"a"},"recoil-sync"))," package is URL persistence.  This enables users to easily initialize atoms based on the URL, update the URL when atoms mutate, and subscribe to URL changes (such as the back button).  Atom state changes can be configured to either replace the current URL or push a new entry in the browser history stack."),(0,i.kt)("h2",{id:"example"},"Example"),(0,i.kt)("p",null,"Here is a simple example of a specifying that an atom should sync with the URL:"),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-jsx"},"const currentUserState = atom<number>({\n  key: 'CurrentUser',\n  default: 0,\n  effects: [syncEffect({ refine: number() })],\n});\n")),(0,i.kt)("p",null,"Then, at the root of your application, simply include ",(0,i.kt)("a",{parentName:"p",href:"/docs/recoil-sync/api/RecoilURLSyncJSON"},(0,i.kt)("inlineCode",{parentName:"a"},"<RecoilURLSyncJSON>"))," to sync all of those tagged atoms with the URL"),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-jsx"},"function MyApp() {\n  return (\n    <RecoilRoot>\n      <RecoilURLSyncJSON location={{part: 'queryParams'}}>\n        ...\n      </RecoilURLSyncJSON>\n    </RecoilRoot>\n  )\n}\n")),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-jsx"},"https://test.com/myapp?CurrentUser=123\n")),(0,i.kt)("h2",{id:"url-encodings"},"URL Encodings"),(0,i.kt)("h3",{id:"state-serialization"},"State Serialization"),(0,i.kt)("p",null,"There are two built-in mechanisms available to encode state in the URL:"),(0,i.kt)("ul",null,(0,i.kt)("li",{parentName:"ul"},(0,i.kt)("strong",{parentName:"li"},"JSON")," - Use ",(0,i.kt)("a",{parentName:"li",href:"/docs/recoil-sync/api/RecoilURLSyncJSON"},(0,i.kt)("inlineCode",{parentName:"a"},"<RecoilURLSyncJSON>")),".  ",(0,i.kt)("a",{parentName:"li",href:"https://en.wikipedia.org/wiki/JSON"},"JSON encoding")," is simple and easy to read.  However it does not support custom user classes or containers such as ",(0,i.kt)("inlineCode",{parentName:"li"},"Map()")," and ",(0,i.kt)("inlineCode",{parentName:"li"},"Set()"),".  It will work with ",(0,i.kt)("inlineCode",{parentName:"li"},"Date")," objects if you use the ",(0,i.kt)("a",{parentName:"li",href:"/docs/refine/api/Primitive_Checkers#jsondate"},(0,i.kt)("inlineCode",{parentName:"a"},"jsonDate()"))," checker from Refine."),(0,i.kt)("li",{parentName:"ul"},(0,i.kt)("strong",{parentName:"li"},"Transit")," - Use ",(0,i.kt)("a",{parentName:"li",href:"/docs/recoil-sync/api/RecoilURLSyncTransit"},(0,i.kt)("inlineCode",{parentName:"a"},"<RecoilURLSyncTransit>")),".  ",(0,i.kt)("a",{parentName:"li",href:"https://github.com/cognitect/transit-js"},"Transit encoding")," is a bit more verbose, but it does support ",(0,i.kt)("inlineCode",{parentName:"li"},"Map()")," and ",(0,i.kt)("inlineCode",{parentName:"li"},"Set()")," containers, and can be extended to encode your own classes by providing custom handlers.")),(0,i.kt)("p",null,"You can also use the base ",(0,i.kt)("a",{parentName:"p",href:"/docs/recoil-sync/api/RecoilURLSync"},(0,i.kt)("inlineCode",{parentName:"a"},"<RecoilURLSync>"))," implementation and provide your own ",(0,i.kt)("inlineCode",{parentName:"p"},"serialize()")," and ",(0,i.kt)("inlineCode",{parentName:"p"},"deserialize()")," implementations."),(0,i.kt)("h3",{id:"part-of-the-url"},"Part of the URL"),(0,i.kt)("p",null,"It is configurable which part of the URL your state will sync with.  The ",(0,i.kt)("a",{parentName:"p",href:"/docs/recoil-sync/api/RecoilURLSync#url-location"},(0,i.kt)("inlineCode",{parentName:"a"},"location"))," prop can specify this such as ",(0,i.kt)("inlineCode",{parentName:"p"},"{part: 'hash'}")," to store in the anchor tag, ",(0,i.kt)("inlineCode",{parentName:"p"},"{part: 'queryParams'}")," to store as individual query params, or ",(0,i.kt)("inlineCode",{parentName:"p"},"{part: 'queryParams', param: 'myParam'}")," to encode in a single query param.  The library will attempt to coexist and not remove other query params from the URL."),(0,i.kt)("h2",{id:"push-vs-replace"},"Push vs Replace"),(0,i.kt)("p",null,"By default, any atom mutations will replace the current URL in the browser with the updated state.  You can also use the ",(0,i.kt)("a",{parentName:"p",href:"/docs/recoil-sync/api/urlSyncEffect"},(0,i.kt)("inlineCode",{parentName:"a"},"urlSyncEffect()"))," effect instead of ",(0,i.kt)("inlineCode",{parentName:"p"},"syncEffect()")," to specify additional options such as if changes to this state should cause a new URL to be pushed on the browser history stack.  This allows the browser's back button to be used to undo those state changes."),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-jsx"},"const currentViewState = atom<string>({\n  key: 'CurrentView',\n  default: 'index',\n  effects: [urlSyncEffect({ refine: number(), history: 'push' })],\n});\n")),(0,i.kt)("h2",{id:"multiple-encodings"},"Multiple Encodings"),(0,i.kt)("p",null,"Remember that you can mix-and-match different atoms with different stores.  So, you could encode some atoms as their own query parameters so they are easy to read and parse, while placing the rest of your state in a single query parameter that uses Transit to encode user classes:"),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-jsx"},"class ViewState {\n  active: boolean;\n  pos: [number, number];\n  constructor(active, pos) {\n    this.active = active;\n    this.pos = pos;\n  }\n  ...\n};\nconst viewStateChecker = custom(x => x instanceof ViewState ? x : null);\n\nfunction MyApp() {\n  return (\n    <RecoilRoot>\n      <RecoilURLSyncJSON storeKey=\"json-url\" location={{part: 'queryParams'}}>\n        <RecoilURLSyncTransit\n          storeKey=\"transit-url\"\n          location={{part: 'queryParam', param: 'state'}}\n          handlers={[\n            {\n              tag: 'VS',\n              class: ViewState,\n              write: x => [x.active, x.pos],\n              read: ([active, pos]) => new ViewState(active, pos),\n            },\n          ]}\n        />\n          ...\n        </RecoilURLSyncTransit>\n      </RecoilURLSyncJSON>\n    </RecoilRoot>\n  )\n}\n\nconst currentUserState = atom<number>({\n  key: 'CurrentUser',\n  default: 0,\n  effects: [syncEffect({ storeKey: 'json-url', refine: number() })],\n});\n\nconst ViewState = atom<ViewState>({\n  key: 'ViewState',\n  default: new ViewState(),\n  effects: [syncEffect({ storeKey: 'transit-url', refine: viewStateChecker() })],\n});\n")))}d.isMDXComponent=!0}}]);