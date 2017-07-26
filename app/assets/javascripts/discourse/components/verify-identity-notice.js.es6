import computed from 'ember-addons/ember-computed-decorators';
import { observes } from 'ember-addons/ember-computed-decorators';
import { userPath } from 'discourse/lib/url';

export default Ember.Component.extend({
  classNameBindings: ['hidden:hidden',':verify-identity-notice'],

  enabled: false,

  init() {
    this._super();
    if (this.get('shouldSee')) {
      this.set('enabled', true);
    }
  },

  @computed()
  shouldSee() {
    const user = this.currentUser;
    return user && !user.get('verified')
  },

  @computed('enabled', 'shouldSee')
  hidden() {
    return !this.get('enabled') || !this.get('shouldSee');
  },

  @computed()
  message() {
    const user = this.currentUser;
    let path = userPath(`${user.username_lower}/preferences/identity`);

    return new Handlebars.SafeString(I18n.t('verify_identity_notice', {
      url: path
    }));
  }
});
