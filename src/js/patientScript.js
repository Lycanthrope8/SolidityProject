App2 = {
    webProvider: null,
    contracts: {},
    account: '0x0',
  
    init: function () {
      return App2.initWeb();
    },
  
    initWeb:function() {
      // if an ethereum provider instance is already provided by metamask
      const provider = window.ethereum
      if( provider ){
        // currently window.web3.currentProvider is deprecated for known security issues.
        // Therefore it is recommended to use window.ethereum instance instead
        App2.webProvider = provider;
      }
      else{
        $("#loader-msg").html('No metamask ethereum provider found')
        console.log('No Ethereum provider')
        // specify default instance if no web3 instance provided
        App2.webProvider = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
      }
   
   
      return App2.initContract();
    },
    initContract: function () {
      $.getJSON("PatientManagement.json", function (patientManagement) {
        App2.contracts.PatientManagement = TruffleContract(patientManagement);
        App2.contracts.PatientManagement.setProvider(App2.webProvider);
        return App2.render();
      });
    },
  
    render: async function () {
      const loader = $("#loader");
      const content = $("#content");
  
      loader.show();
      content.hide();
  
      if (window.ethereum) {
        try {
          const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
          App2.account = accounts[0];
          $("#accountAddress").html("Your Account: " + App2.account);
        } catch (error) {
          if (error.code === 4001) {
            // User rejected request
            console.warn('User rejected');
          }
          $("#accountAddress").html("Your Account: Not Connected");
          console.error(error);
        }
      }
  
      App2.contracts.PatientManagement.deployed()
        .then(function (instance) {
          return instance.admin();
        })
        .then(function (adminAddress) {
          if (adminAddress.toLowerCase() === App2.account.toLowerCase()) {
            // Show admin view
            $("#adminView").show();
            $("#patientView").hide();
          } else {
            // Show patient view
            $("#adminView").hide();
            $("#patientView").show();
          }
  
          loader.hide();
          content.show();
        })
        .catch(function (error) {
          console.warn(error);
        });
    },

    submitPatientInfo: function () {
        console.log('Submitting patient info...');
        const name = document.getElementById('name').value;
        const age = parseInt(document.getElementById('age').value);
        const gender = document.getElementById('gender').value;
        const vaccineStatus = parseInt(document.getElementById('vaccineStatus').value);
        const district = document.getElementById('district').value;
        const symptomsDetails = document.getElementById('symptomsDetails').value;
      
        // Ensure the contract instance is initialized
        App2.initContract()
          .then(function () {
            // Get the initialized contract instance
            const contract = App2.contracts.PatientManagement;
      
            // Interact with the contract to add patient information
            return contract.deployed()
              .then(function (instance) {
                return instance.addPatient(name, age, gender, vaccineStatus, district, symptomsDetails);
              })
              .then(function (transaction) {
                console.log('Transaction Hash:', transaction.tx);
                alert('Patient information added successfully');
              })
              .catch(function (error) {
                console.error(error);
                alert('Error adding patient information');
              });
          });
      },
      

};

$(function () {
  $(window).load(function () {
      App2.init();
  });
});