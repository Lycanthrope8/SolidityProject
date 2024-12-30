// requiring the contract
const PatientManagement = artifacts.require("../contracts/PatientManagement.sol");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(PatientManagement, [accounts[1], accounts[2]]);
};
