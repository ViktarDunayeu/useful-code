/*
* Получать информацию по динамическому полю из объекта
* relatedObject - имя динамического поля объекта companyData
*/
const relatedObject = event.target.dataset.name;
const recordToEditIndex = this.companyData[relatedObject].findIndex(recordToedit => recordToedit.Id == relatedRecordIdToEdit);