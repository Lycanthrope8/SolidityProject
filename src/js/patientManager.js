// patientManager.js

const addPatient = async (name, age, gender, vaccineStatus, district, symptomsDetails) => {
    try {
        const contract = await App.contracts.PatientManagement.deployed();
        const transaction = await contract.addPatient(name, age, gender, vaccineStatus, district, symptomsDetails);
        console.log("Transaction Hash:", transaction.tx);
        return transaction;
    } catch (error) {
        console.error(error);
        throw error;
    }
};

