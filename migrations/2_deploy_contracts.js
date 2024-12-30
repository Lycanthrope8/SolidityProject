// requiring the contract
const PatientManagement = artifacts.require("../contracts/PatientManagement.sol");

 module.exports = function (deployer) {
   deployer.deploy(PatientManagement);
 };

