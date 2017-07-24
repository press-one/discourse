import PreferencesTabController from "discourse/mixins/preferences-tab-controller";
import { popupAjaxError } from 'discourse/lib/ajax-error';

export default Ember.Controller.extend(PreferencesTabController, {

  saveAttrNames: [
    'id_card_front',
    'id_card_back',
    'id_card_with_person'
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
