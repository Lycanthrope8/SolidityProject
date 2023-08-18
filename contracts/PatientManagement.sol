// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract PatientManagement {
    enum VaccineStatus { NotVaccinated, OneDose, TwoDose }

    struct Patient {
        uint id;
        address patientAddress;
        string name;
        uint age;
        string gender;
        VaccineStatus vaccineStatus;
        string district;
        string symptomsDetails;
        bool isDead;
        bool hasInfo;
    }

    address public admin;
    mapping(address => Patient) public patients;
    uint public patientCount;
    address[] public patientAddresses;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender; // The first account of Ganache becomes the admin
    }

    function adminSignin() public view returns (bool) {
        return msg.sender == admin;
    }

    function patientSignin() public view returns (bool) {
        return patients[msg.sender].id != 0;
    }

    function addPatient(
        string memory _name,
        uint _age,
        string memory _gender,
        VaccineStatus _vaccineStatus,
        string memory _district,
        string memory _symptomsDetails
    ) public {
        require(bytes(_name).length > 0, "Name must not be empty");

        patientCount++;

        patients[msg.sender] = Patient({
            id: patientCount,
            patientAddress: msg.sender,
            name: _name,
            age: _age,
            gender: _gender,
            vaccineStatus: _vaccineStatus,
            district: _district,
            symptomsDetails: _symptomsDetails,
            isDead: false,
            hasInfo: true
        });

        patientAddresses.push(msg.sender); // Add the patient's address to the array
    
    }

    function updatePatient(
        address _patientAddress,
        string memory _name,
        uint _age,
        string memory _gender,
        uint _vaccineStatus,
        string memory _district,
        string memory _symptomsDetails,
        bool _isDead,
        bool _hasInfo
    ) public onlyAdmin {
        // address patientAddress = address(bytes20(bytes(_patientAddress)));
        require(patients[_patientAddress].id != 0, "Patient not found");

        // Update patient data in the patients mapping
        Patient storage patient = patients[_patientAddress];
        patient.name = _name;
        patient.age = _age;
        patient.gender = _gender;
        patient.vaccineStatus = VaccineStatus(_vaccineStatus);
        patient.district = _district;
        patient.symptomsDetails = _symptomsDetails;
        patient.isDead = _isDead;
        patient.hasInfo = _hasInfo;

    }
    

    function deletePatient(string memory _patientAddressString) public onlyAdmin {
        address patientAddress = address(bytes20(bytes(_patientAddressString)));
        // Deleting patient data from the patients mapping
        delete patients[patientAddress];
        // Deleting patient address from the patientAddresses array
        for (uint i = 0; i < patientAddresses.length; i++) {
            if (patientAddresses[i] == patientAddress) {
                for (uint j = i; j < patientAddresses.length - 1; j++) {
                    patientAddresses[i] = patientAddresses[i + 1];
                }
                patientAddresses.pop();
            }
        }
            patientCount--;
        }


    function getAllPatientAddresses() public view returns (address[] memory) {
        return patientAddresses;
}

    function getAllPatients() public view onlyAdmin returns (Patient[] memory) {
    Patient[] memory allPatients = new Patient[](patientCount);

    for (uint i = 0; i < patientCount; i++) {
        address patientAddress = patientAddresses[i];
        allPatients[i] = patients[patientAddress];
    }
    return allPatients;
}

}
