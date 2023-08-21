// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/Strings.sol";

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
        uint deathDate;
    }

    address public admin;
    mapping(address => Patient) public patients;
    uint public patientCount;
    uint public deathCount;
    address[] public patientAddresses;

    /////////////////// For district Calculations

    mapping(string => uint) districtCounts;
    string mostPatientsDistrict;
    uint mostPatientsCount;

    /////////////////




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
        hasInfo: true,
        deathDate: 0
    });

    patientAddresses.push(msg.sender); // Add the patient's address to the array
    
    // Updating district counts
    districtCounts[_district]++;
    
    if (districtCounts[_district] > mostPatientsCount) {
        mostPatientsCount = districtCounts[_district];
        mostPatientsDistrict = _district;
    }
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
        bool _hasInfo,
        uint _deathDate
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
        patient.deathDate = _deathDate;
        
        if (_deathDate>0 && _isDead == true){
            deathCount++;
        }
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

/////////////////////////////Average Death Rate 

    function averageDeathRate() public view returns (string memory) {
    if (deathCount > 0) {
        uint totalDays = 0;
        uint totalDeaths = 0;
        uint currentDay = 0;

        for (uint i = 0; i < patientAddresses.length; i++) {
            if (patients[patientAddresses[i]].isDead && patients[patientAddresses[i]].deathDate > 0) {
                // totalDays += (block.timestamp - patients[patientAddresses[i]].deathDate) / 1 days;
                if (patients[patientAddresses[i]].deathDate!=currentDay){
                    totalDays+=1;
                    currentDay=patients[patientAddresses[i]].deathDate;
                }
                totalDeaths++;
            }
        }

        if (totalDeaths > 0) {
            return division(2,totalDeaths,totalDays);
        }
    }
    return '0';
}

/////////////////////Highest patient District

    function getDistrictWithMostPatients() public view returns (string memory) {
        return mostPatientsDistrict;
    }


////////////////////////Age Percentages 

    using Strings for uint256;
    function division(uint256 decimalPlaces, uint256 numerator, uint256 denominator) public pure returns(string memory result) {
        uint quotient;
        uint remainder;
        uint256 factor = 10**decimalPlaces;
        quotient  = numerator / denominator;
        bool rounding = 2 * ((numerator * factor) % denominator) >= denominator;
        remainder = (numerator * factor / denominator) % factor;
        if (rounding) {
            remainder += 1;
        }
        result = string(abi.encodePacked(quotient.toString(), '.', remainder.toString()));
        // return result
        return result;
    }

function agePercentages() public view returns (string memory) {
    uint childrenCount = 0;
    uint teenagersCount = 0;
    uint youngCount = 0;
    uint elderCount = 0;

    for (uint i = 0; i < patientAddresses.length; i++) {
        uint age = patients[patientAddresses[i]].age;

        if (age < 13) {
            childrenCount++;
        } else if (age >= 13 && age < 20) {
            teenagersCount++;
        } else if (age >= 20 && age < 50) {
            youngCount++;
        } else if (age >= 50) {
            elderCount++;
        }
    }

    uint totalCount = patientAddresses.length;

    string memory childrenPercentage = division(2, childrenCount*100, totalCount);
    string memory teenagersPercentage = division(2, teenagersCount*100, totalCount);
    string memory youngPercentage = division(2, youngCount*100, totalCount);
    string memory elderPercentage = division(2, elderCount*100, totalCount);
    string memory percentages = string(
        abi.encodePacked(
            "Children: ", childrenPercentage, " %, ",
            "Teenagers: ", teenagersPercentage, " %, ",
            "Young: ", youngPercentage, " %, ",
            "Elder: ", elderPercentage, " %"
        )
    );

    return percentages;
}



}
