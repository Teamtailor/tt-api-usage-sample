class SelectLocations {
  constructor(selectNode) {
    this.selectNode = selectNode;
    this.addListeners()
  }

  addListeners() {
    this.selectNode.addEventListener('click', event => this.renderOptions(), { once: true} );
  }

  async renderOptions() {
    const locations = await this.fetchData()
    const htmlOptions = this.addOptionsToSelect(locations)
  }


  async fetchData() {
    const response = await fetch('/locations')
    return response.json()
  }

  addOptionsToSelect(locations){
    locations.map((location) => {
      const option = document.createElement('option');
      option.value = location.id
      option.innerHTML = `${location.attributes.city} (${location.attributes.address} ${location.attributes.country})`
      this.selectNode.appendChild(option)
    })
  }
}

document.addEventListener("DOMContentLoaded", function(event) {
  const selectNode = document.querySelector("#location_id");

  if (selectNode) {
    new SelectLocations(selectNode)
  }
});

