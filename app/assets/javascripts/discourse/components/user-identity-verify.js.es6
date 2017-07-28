export default Ember.Component.extend({
  init() {
    this._super(...arguments);

    const status = this.get('status')
    switch (status) {
      case 1:
        this.set('isValidating', true);
        break;
      case 2:
        this.set('isValidateFail', true);
        break;
      case 3:
        this.set('isValidateSuccess', true);
        break;
      default:
        break;
    }
  }
});
