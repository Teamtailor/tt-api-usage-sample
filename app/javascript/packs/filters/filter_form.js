class ToolbarForm {
  constructor(formNode) {
    this.formNode = formNode;
    this.downloadButtonNode = formNode.querySelector('.download-button')
    this.setInitialValues();
    this.addListeners();
  }

  addListeners() {
    const selectNodes = this.formNode.querySelectorAll("select")
    selectNodes.forEach((selectNode) => {
      selectNode.addEventListener('change', event => this.submitForm('Filter'));
    })
    this.downloadButtonNode.addEventListener('click', event => this.submitForm('Export'))
  }

  setInitialValues(){
    const curentUrl = new URL(window.location);
    curentUrl.searchParams.forEach((value, key) => {
      this.formNode.querySelector(`*[name="${key}"]`).value = value
    })
  }

  submitForm(commitValue){
    const hiddenInput = this.formNode.querySelector('#commit');

    hiddenInput.value = commitValue
    this.formNode.submit()
  }
}

document.addEventListener("DOMContentLoaded", function(event) {
  const formNode = document.querySelector(".toolbar-form");

  if (formNode) {
    new ToolbarForm(formNode)
  }
});