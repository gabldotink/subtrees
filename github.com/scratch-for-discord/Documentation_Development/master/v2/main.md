# Main

## Milestone

{% embed url="https://github.com/scratch-for-discord/Web-Application_Frontend/milestone/5" %}

## Programming Language

[**`TypeScript` - `.ts`**](https://www.typescriptlang.org)

This is a [`TypeScript` - `*.ts`](https://www.typescriptlang.org/) release.\
No `JavaScript` - `*.js` file should populate it.

## Running & Building

_`package.json` summary:_

* **Run the Website** : `npm run dev`
* **Build for Production** : `npm run build`
* **Run the Preview** (not much used) : `npm run preview`

## Project Management

The goal of this new release is to keep the build time minimal and keep the project organized and easy to read.\
This piece of documentation will guide you through organizing the files and the project structure.

## Custom Blocks

Custom blocks are using the [blockly 9 API](https://developers.google.com/blockly/guides/configure/advanced/using\_blockly\_apis)

### Links

* [**S4D Exemple Files**](https://github.com/scratch-for-discord/Web-Application\_Frontend/tree/release/2/master/src/blocks)
* [**Blockly Custom Block API Documentation**](https://developers.google.com/blockly/guides/create-custom-blocks/define-blocks)

### Blocks Organisation

* One file for each toolbox category
* Name the file according to its category name
* Blocks inside the file should be put in order of appearance in the toolbox
* A comment must be put on top of each block definition

## Create Components

Vue components are created in the [components directory (`src/components`)](https://github.com/scratch-for-discord/Web-Application\_Frontend/tree/release/2/master/src/components).

### Guidelines

* Always comment your development
* Try to make one component for one functionality (example: `NavBar.vue` only contains navbar code ; `FNAF.vue` only contains the fnaf game)

## Styling

All the Global CSS styles or CSS classes used are in the [`src/styles`](https://github.com/scratch-for-discord/Web-Application\_Frontend/tree/release/2/master/src/styles) directory

If a Vue component has too much styling you can create a CSS file for the component with the component's name inside the [`src/styles`](https://github.com/scratch-for-discord/Web-Application\_Frontend/tree/release/2/master/src/styles) directory, then import it inside the component with `@import './file_path'` ([documentation](https://developer.mozilla.org/en-US/docs/Web/CSS/@import))
