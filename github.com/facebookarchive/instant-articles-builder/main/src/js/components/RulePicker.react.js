/**
 * Copyright 2017-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @flow
 */

const React = require('react');
const PropertyPicker = require('./PropertyPicker.react.js');
const SelectorPicker = require('./SelectorPicker.react');
const LabelIconRequired = require('./common/LabelIcon/LabelIconRequired.react.js');
const LabelIconValid = require('./common/LabelIcon/LabelIconValid.react.js');
const classNames = require('classnames');
const RuleActions = require('../data/RuleActions');

import type { Rule } from '../models/Rule';
import type { Props as BaseProps } from '../containers/AppContainer.react';
import { RuleUtils } from '../utils/RuleUtils';

type Props = BaseProps & { rule: Rule };

type State = {
  collapsed: boolean,
};

class RulePicker extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      collapsed: RuleUtils.isValid(props.rule),
    };
  }

  handleRemove = (event: Event) => {
    event.preventDefault();
    RuleActions.removeRule(this.props.rule);
  };

  handleToggle = () => {
    this.setState((prevState, props) => ({
      collapsed: !prevState.collapsed,
    }));
  };

  render() {
    const toggler = this.state.collapsed
      ? '\u25B6' // right triangle
      : '\u25BC'; // down triangle
    const label = 'Selector';
    return (
      <div
        className={classNames({
          'selectors-form': true,
          collapsed: !!this.state.collapsed,
          valid: RuleUtils.isValid(this.props.rule),
          hidden: !this.props.editor.categories.contains(
            this.props.rule.definition.category
          ),
        })}
      >
        <h2
          className="rule-header"
          role="presentation"
          onClick={this.handleToggle}
        >
          {toggler} {this.props.rule.definition.displayName}
        </h2>

        <button className="btn-close" onClick={this.handleRemove}>
          &#10006;
        </button>

        <div className="rule-settings">
          <div
            className={classNames({
              'field-line': true,
              'single-element-found':
                this.props.editor.elementCounts.get(this.props.rule.selector) ==
                1,
              'multiple-elements-found':
                (this.props.editor.elementCounts.get(
                  this.props.rule.selector
                ) || 0) > 1,
              active: this.props.editor.focusedField == this.props.rule,
              multiple: !this.props.rule.definition.unique,
              valid: this.props.rule.selector != '',
            })}
          >
            {this.props.rule.selector != '' ? (
              <LabelIconValid>{label}</LabelIconValid>
            ) : (
              <LabelIconRequired>{label}</LabelIconRequired>
            )}
            <SelectorPicker {...this.props} field={this.props.rule} />
          </div>
          {this.props.rule.properties
            .sortBy(property => !property.definition.required)
            .valueSeq()
            .map((property, name) => (
              <PropertyPicker {...this.props} key={name} property={property} />
            ))}
        </div>
      </div>
    );
  }
}

module.exports = RulePicker;
