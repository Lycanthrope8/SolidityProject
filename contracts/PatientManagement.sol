// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PatientManagement {
    enum VaccineStatus { NotVaccinated, OneDose, TwoDose }

    event AverageDeathRateChanged(string newAverageDeathRate);
    event AgePercentagesChanged(string newAgePercentages);
    event DistrictWithMostPatientsChanged(string newDistrictWithMostPatients);

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
    mapping(address => bool) public doctors; // Added mapping to track doctors
    mapping(address => Patient) public patients;
    uint public patientCount;
    uint public deathCount;
    address[] public patientAddresses;
    mapping(string => uint) districtCounts;
    string mostPatientsDistrict;
    uint mostPatientsCount;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor(address[] memory initialDoctors) {
        admin = msg.sender; // The first account of Ganache becomes the admin
        for (uint i = 0; i < initialDoctors.length; i++) {
            doctors[initialDoctors[i]] = true;
        }
        nextAppointmentId = 1;
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

        patientAddresses.push(msg.sender);
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
        require(patients[_patientAddress].id != 0, "Patient not found");
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

        if (_deathDate > 0 && _isDead == true) {
            deathCount++;
            emit AverageDeathRateChanged(averageDeathRate());
            emit AgePercentagesChanged(agePercentages());
            emit DistrictWithMostPatientsChanged(getDistrictWithMostPatients());
        }
    }

    function deletePatient(string memory _patientAddressString) public onlyAdmin {
        address patientAddress = address(bytes20(bytes(_patientAddressString)));
        delete patients[patientAddress];
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

    function averageDeathRate() public view returns (string memory) {
        if (deathCount > 0) {
            uint totalDays = 0;
            uint totalDeaths = 0;
            uint currentDay = 0;

            for (uint i = 0; i < patientAddresses.length; i++) {
                if (patients[patientAddresses[i]].isDead && patients[patientAddresses[i]].deathDate > 0) {
                    if (patients[patientAddresses[i]].deathDate != currentDay) {
                        totalDays += 1;
                        currentDay = patients[patientAddresses[i]].deathDate;
                    }
                    totalDeaths++;
                }
            }

            if (totalDeaths > 0) {
                return division(2, totalDeaths, totalDays);
            }
        }
        return '0';
    }

    function getDistrictWithMostPatients() public view returns (string memory) {
        return mostPatientsDistrict;
    }

    function division(uint256 decimalPlaces, uint256 numerator, uint256 denominator) public pure returns(string memory) {
    uint quotient = numerator / denominator;
    uint remainder = (numerator * (10**decimalPlaces)) / denominator % (10**decimalPlaces);
    bool rounding = 2 * (remainder % denominator) >= denominator;
    if (rounding) {
        remainder += 1;
    }
    return string(abi.encodePacked(toString(quotient), '.', toString(remainder)));
}

function toString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
        return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
        digits++;
        temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
        digits -= 1;
        buffer[digits] = bytes1(uint8(48 + value % 10));
        value /= 10;
    }
    return string(buffer);
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
        string memory childrenPercentage = division(2, childrenCount * 100, totalCount);
        string memory teenagersPercentage = division(2, teenagersCount * 100, totalCount);
        string memory youngPercentage = division(2, youngCount * 100, totalCount);
        string memory elderPercentage = division(2, elderCount * 100, totalCount);
        return string(abi.encodePacked(
            "Children: ", childrenPercentage, " %, ",
            "Teenagers: ", teenagersPercentage, " %, ",
            "Young: ", youngPercentage, " %, ",
            "Elder: ", elderPercentage, " %"
        ));
    }

struct Appointment {
        uint256 id;
        address patient;
        address doctor;  // In this context, doctor refers to an admin.
        uint256 dateTime;
        bool confirmed;
    }

    uint256 public nextAppointmentId;
    mapping(uint256 => Appointment) public appointments;
    mapping(address => uint256[]) private doctorAppointments;

    event AppointmentBooked(uint256 indexed id, address indexed patient, address indexed doctor, uint256 dateTime);



    function bookAppointment(address doctor, uint256 dateTime) external payable {
        require(msg.value == 1 ether, "Booking requires exactly 1 ETH");
        appointments[nextAppointmentId] = Appointment(nextAppointmentId, msg.sender, doctor, dateTime, false);
        doctorAppointments[doctor].push(nextAppointmentId);
        emit AppointmentBooked(nextAppointmentId, msg.sender, doctor, dateTime);
        nextAppointmentId++;
    }

 function getAppointmentsByDoctor(address doctor) public view returns (uint256[] memory, address[] memory, uint256[] memory) {
    uint256[] memory ids = new uint256[](doctorAppointments[doctor].length);
    address[] memory doctorAddresses = new address[](doctorAppointments[doctor].length); // Renamed to avoid shadowing
    uint256[] memory dateTimes = new uint256[](doctorAppointments[doctor].length);

    for (uint i = 0; i < doctorAppointments[doctor].length; i++) {
        Appointment storage appointment = appointments[doctorAppointments[doctor][i]];
        ids[i] = appointment.id;
        doctorAddresses[i] = appointment.patient; // Use new variable name
        dateTimes[i] = appointment.dateTime;
    }

    return (ids, patientAddresses, dateTimes);
}




    function getAllAppointments() external view returns (Appointment[] memory) {
        Appointment[] memory allAppointments = new Appointment[](nextAppointmentId - 1);
        for (uint256 i = 1; i < nextAppointmentId; i++) {
            allAppointments[i - 1] = appointments[i];
        }
        return allAppointments;
    }
}
