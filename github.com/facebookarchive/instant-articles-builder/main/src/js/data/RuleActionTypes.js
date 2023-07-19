/**
 * Copyright 2017-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @flow
 */

const RuleActionTypes = {
  ADD_RULE: 'ADD_RULE',
  REMOVE_RULE: 'REMOVE_RULE',
  EDIT_FIELD: 'EDIT_FIELD',
  REMOVE_ALL_RULES: 'REMOVE_ALL_RULES',
  CHANGE_ORDER: 'CHANGE_ORDER',
};

export type RuleActionType = $Values<typeof RuleActionTypes>;

export default RuleActionTypes;
