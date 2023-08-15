// contract PatientManagement {
//     enum VaccineStatus { NotVaccinated, OneDose, TwoDose }
    
//     struct Patient {
//         uint256 id;
//         address patientAddress; // Added patient address
//         string name;
//         uint256 age;
//         string gender;
//         VaccineStatus vaccineStatus;
//         string district;
//         string symptomsDetails;
//         bool isDead;
//         bool hasAddedInfo;
//     }
    
//     address public admin;
//     mapping(address => Patient) public patients;
//     uint256 public patientCount;
    
//     modifier onlyAdmin() {
//         require(msg.sender == admin, "Only admin can perform this action");
//         _;
//     }
    
//     constructor() {
//         admin = msg.sender; // The first account of Ganache becomes the admin
//     }
    
//     function adminSignin() public view returns (bool) {
//         return msg.sender == admin;
//     }
    
//     function patientSignin() public view returns (bool) {
//         return patients[msg.sender].id != 0;
//     }
    
    
    
//     function addPatient(
//     string memory _name,
//     uint256 _age,
//     string memory _gender,
//     VaccineStatus _vaccineStatus,
//     string memory _district,
//     string memory _symptomsDetails
//     ) public {
//         require(bytes(_name).length > 0, "Name must not be empty");

//         patientCount++;

//         patients[msg.sender] = Patient(
//             patientCount,
//             msg.sender,
//             _name,
//             _age,
//             _gender,
//             _vaccineStatus,
//             _district,
//             _symptomsDetails,
//             false,
//             true
//         );
//     }





//     function updatePatient(address _patientAddress, uint256 _age, string memory _gender, VaccineStatus _vaccineStatus, string memory _district, string memory _symptomsDetails, bool _isDead) public onlyAdmin {
//         require(_age > 0, "Age must be greater than zero");
//         require(bytes(_gender).length > 0, "Gender must not be empty");
//         require(uint256(_vaccineStatus) <= uint256(VaccineStatus.TwoDose), "Invalid vaccine status");
        
//         patients[_patientAddress].age = _age;
//         patients[_patientAddress].gender = _gender;
//         patients[_patientAddress].vaccineStatus = _vaccineStatus;
//         patients[_patientAddress].district = _district;
//         patients[_patientAddress].symptomsDetails = _symptomsDetails;
//         patients[_patientAddress].isDead = _isDead;
//     }

    
//     function getAllPatients() public view  returns (Patient[] memory) {
//         Patient[] memory allPatients = new Patient[](patientCount);
        
//         for (uint256 i = 0; i < patientCount; i++) {
//             allPatients[i] = patients[patients[msg.sender].patientAddress];
//         }
//         return allPatients;
//     }
// }

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract PatientManagement {
    enum VaccineStatus { NotVaccinated, OneDose, TwoDose }

    struct Patient {
        uint256 id;
        address patientAddress;
        string name;
        uint256 age;
        string gender;
        VaccineStatus vaccineStatus;
        string district;
        string symptomsDetails;
        bool isDead;
        bool hasAddedInfo;
    }

    address public admin;
    mapping(address => Patient) public patients;
    uint256 public patientCount;

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
        uint256 _age,
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
            hasAddedInfo: true
        });
    }

    function updatePatient(
        uint256 _age,
        string memory _gender,
        VaccineStatus _vaccineStatus,
        string memory _district,
        string memory _symptomsDetails,
        bool _isDead
    ) public onlyAdmin {
        require(_age > 0, "Age must be greater than zero");
        require(
            uint256(_vaccineStatus) <= uint256(VaccineStatus.TwoDose),
            "Invalid vaccine status"
        );

        Patient storage patient = patients[msg.sender];
        patient.age = _age;
        patient.gender = _gender;
        patient.vaccineStatus = _vaccineStatus;
        patient.district = _district;
        patient.symptomsDetails = _symptomsDetails;
        patient.isDead = _isDead;
    }

    function getAllPatients() public view onlyAdmin returns (Patient[] memory) {
        Patient[] memory allPatients = new Patient[](patientCount);

        for (uint256 i = 1; i <= patientCount; i++) {
            Patient storage patient = patients[msg.sender];
            allPatients[i - 1] = patient;
        }
        return allPatients;
    }
}

