import { LightningElement } from 'lwc';
import createField from '@salesforce/apex/CreateField.createField';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateField extends LightningElement {

    handleClick(){
        createField().then((success) =>{
            console.log('Success createField',success);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Field created successfully!',
                    variant: 'success'
                })
            );
        }).catch(error => {
            console.log('Error==> createField',error);
        })
    }
}