import { LightningElement, api, track } from "lwc";
import retriveSearchData from "@salesforce/apex/ReusableMultiSelectLookupController.retriveSearchData";

export default class ReusableMultiSelectLookup extends LightningElement {
  @api objectname = "Contact";
  @api fieldnames = "Id, Name, Email";
  @api lookupfilter = "Email != null";
  @api label;
  @api helptext;
  @api inputfieldname;
  @track searchRecords = [];
  @track selectedRecords = [];
  @api iconName = "standard:contact";
  @track messageFlag = false;
  @track isSearchLoading = false;
  @api placeholder = "Search..";
  @track searchKey;
  delayTimeout;

  searchField() {
    var selectedRecordIds = [];

    this.selectedRecords.forEach((ele) => {
      selectedRecordIds.push(ele.Id);
    });

    retriveSearchData({
      ObjectName: this.objectname,
      fieldName: this.fieldnames,
      value: this.searchKey,
      selectedRecId: selectedRecordIds,
      lookupFilter: this.lookupfilter
    })
      .then((result) => {
        this.searchRecords = result;
        this.isSearchLoading = false;
        const lookupInputContainer = this.template.querySelector(
          ".lookupInputContainer"
        );
        const clsList = lookupInputContainer.classList;
        clsList.add("slds-is-open");

        if (this.searchKey.length > 0 && result.length == 0) {
          this.messageFlag = true;
        } else {
          this.messageFlag = false;
        }
      })
      .catch((error) => {
        console.log("error occured while searching lookup data: ", error);
      });
  }

  // update searchKey property on input field change
  handleKeyChange(event) {
    // Do not update the reactive property as long as this function is
    this.isSearchLoading = true;
    window.clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    this.delayTimeout = setTimeout(() => {
      this.searchKey = searchKey;
      this.searchField();
    }, 300);
  }

  // method to toggle lookup result section on UI
  toggleResult(event) {
    const lookupInputContainer = this.template.querySelector(
      ".lookupInputContainer"
    );
    const clsList = lookupInputContainer.classList;
    const whichEvent = event.target.getAttribute("data-source");

    switch (whichEvent) {
      case "searchInputField":
        clsList.add("slds-is-open");
        this.searchField();
        break;
      case "lookupContainer":
        clsList.remove("slds-is-open");
        break;
    }
  }

  setSelectedRecord(event) {
    var recId = event.target.dataset.id;
    var selectName = event.currentTarget.dataset.name;
    let newsObject = this.searchRecords.find((data) => data.Id === recId);
    this.selectedRecords.push(newsObject);
    this.template
      .querySelector(".lookupInputContainer")
      .classList.remove("slds-is-open");
    let selRecords = this.selectedRecords;
    this.template.querySelectorAll("lightning-input").forEach((each) => {
      each.value = "";
    });

    const selectedEvent = new CustomEvent("selected", {
      detail: { selRecords }
    });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  removeRecord(event) {
    let selectRecId = [];
    for (let i = 0; i < this.selectedRecords.length; i++) {
      if (event.detail.name !== this.selectedRecords[i].Id)
        selectRecId.push(this.selectedRecords[i]);
    }

    this.selectedRecords = [...selectRecId];
    let selRecords = this.selectedRecords;
    const selectedEvent = new CustomEvent("selected", {
      detail: { selRecords }
    });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }
}
