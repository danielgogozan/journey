import dataStore from 'nedb-promise';

export class PoiStore {
  constructor({ filename, autoload }) {
    this.store = dataStore({ filename, autoload });
  }
  
  async find(props) {
    return this.store.find(props);
  }
  
  async findOne(props) {
    return this.store.findOne(props);
  }
  
  async insert(poi) {
    let poiName = poi.name;
    if (!poiName) { // validation
      throw new Error('Missing poi name property')
    }
    return this.store.insert(poi);
  };
  
  async update(props, poi) {
    return this.store.update(props, poi);
  }
  
  async remove(props) {
    return this.store.remove(props);
  }
}

export default new PoiStore({ filename: './db/pois.json', autoload: true });