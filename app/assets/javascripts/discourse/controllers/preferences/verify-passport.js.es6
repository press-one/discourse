import PreferencesTabController from "discourse/mixins/preferences-tab-controller";
import { popupAjaxError } from 'discourse/lib/ajax-error';

export default Ember.Controller.extend(PreferencesTabController, {

  saveAttrNames: [
    'passport_cover',
    'passport_content',
    'passport_with_person',
    'passport_country',
    'passport_number',
    'passport_name'
  ],

  actions: {
    save() {
      this.set('saved', false);

      const model = this.get('model');

      return model.save(this.get('saveAttrNames')).then(() => {
        this.set('saved', true);
      }).catch(popupAjaxError);
    }
  }
});
