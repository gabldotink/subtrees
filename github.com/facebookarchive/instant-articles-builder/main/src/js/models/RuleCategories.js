/**
 * Copyright 2017-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @flow
 */

/**
 * This can be used as a enum.
 */
const RuleCategories: { [string]: RuleCategory } = {
  BASIC: 'Basic',
  TEXT: 'Text',
  MEDIA: 'Media',
  ADVANCED: 'Advanced',
  WIDGETS: 'Widgets',
};

export type RuleCategory = $Values<typeof RuleCategories>;

export default RuleCategories;
