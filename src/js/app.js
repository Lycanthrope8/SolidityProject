App = {
  webProvider: null,
  contracts: {},
  account: '0x0',

  init: function () {
    return App.initWeb();
  },

  initWeb: function () {
    // if an ethereum provider instance is already provided by metamask
    const provider = window.ethereum;
    if (provider) {
      // currently window.web3.currentProvider is deprecated for known security issues.
      // Therefore it is recommended to use window.ethereum instance instead
      App.webProvider = provider;
    } else {
      $("#loader-msg").html('No metamask ethereum provider found');
      console.log('No Ethereum provider');
      // specify default instance if no web3 instance provided
      App.webProvider = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
    }

    return App.initContract();
  },

  initContract: function () {
    $.getJSON("PatientManagement.json", function (patientmanagement) {
      // instantiate a new truffle contract from the artifact
      App.contracts.PatientManagement = TruffleContract(patientmanagement);

      // connect provider to interact with contract
      App.contracts.PatientManagement.setProvider(App.webProvider);

      return App.render();
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
        App.account = accounts[0];
        $("#accountAddress").html("Your Account: " + App.account);
      } catch (error) {
        if (error.code === 4001) {
          // User rejected request
          console.warn('User rejected');
        }
        $("#accountAddress").html("Your Account: Not Connected");
        console.error(error);
      }
    }

    App.contracts.PatientManagement.deployed()
      .then(function (instance) {
        return instance.admin();
      })
      .then(function (adminAddress) {
        if (adminAddress.toLowerCase() === App.account.toLowerCase()) {
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

  console.log("Initializing contract instance...");
  App.contracts.PatientManagement.deployed()
      
      .then(function (instance) {
          console.log('Calling addPatient...');
          return instance.addPatient(name, age, gender, vaccineStatus, district, symptomsDetails, {
              from: App.account,
              gas: '500000', // Adjust gas limit as needed
          });
      })
      .then(function (result) {
          console.log('Transaction Hash:', result.tx);
          alert('Patient information added successfully');
      })
      .catch(function (error) {
          console.error(error);
          alert('Error adding patient information');
      });
},



  patientSignin: function () {
    console.log(App.contracts.PatientManagement)
    App.contracts.PatientManagement.deployed()
      .then(function (instance) {
        return instance.admin();
      })
      .then(function(adminAddress){
        console.log(App.account, adminAddress)
        if (adminAddress.toLowerCase()!==App.account.toLowerCase()){
          return window.ethereum.request({ method: 'eth_sendTransaction', params:[{
            from: App.account,
            to: adminAddress,
            gas: '50000',
            value:'0',
            description: 'Patient Sign In',
          }] });
        }else{
          alert("Admin cannot sign in as a patient")
          exit() ///Wrong approach
        }
      })
      .then(function(txHash){
        window.location.href="patientDashboard.html";
        
        console.log(txHash)
      }).catch(function (error) {
        console.error(error);
      });
  },

  adminSignin: function () {
    App.contracts.PatientManagement.deployed()
      .then(function (instance) {
        return instance.admin();
      })
      .then(function (adminAddress) {
        console.log(App.account, adminAddress)
        if (adminAddress.toLowerCase() === App.account.toLowerCase()) {
          return window.ethereum.request({ method: 'eth_sendTransaction', params:[{
            from: App.account,
            to: adminAddress,
            gas: '50000',
            value:'0',
            description: 'Admin Sign In',
          }] });
        } else {
          alert('You are not authorized to sign in as admin.');
          exit() ///Wrong approard
        }
      })
      .then(function(txHash){
        window.location.href="adminDashboard.html";
        console.log(txHash)
      })
      .catch(function (error) {
        console.error(error);
      });
  },

  logout: function () {
    // Clear the current user account and redirect to index.html
    App.account = '0x0';
    window.location.href = 'index.html';
  },

 
  AllPatients: async function() {
    try {
        const instance = await App.contracts.PatientManagement.deployed();
  
        const patientCount = await instance.patientCount();
  
        const allPatients = [];
        for (let i = 1; i <= patientCount; i++) {
            const patientValues = await instance.patients(i);
  
            const patient = {
                id: patientValues[0].toNumber(),
                patientAddress: patientValues[1],
                name: patientValues[2],
                age: patientValues[3].toNumber(),
                gender: patientValues[4],
                vaccineStatus: patientValues[5].toNumber(),
                district: patientValues[6],
                symptomsDetails: patientValues[7],
                isDead: patientValues[8],
                hasAddedInfo: patientValues[9]
            };
  
            allPatients.push(patient);
            console.log(allPatients)
        }
  
        // Display patients in the HTML table
        const table = document.getElementById('patientTable');
        for (const patient of allPatients) {
            const row = table.insertRow();
            const cellId = row.insertCell(0);
            const cellName = row.insertCell(1);
            const cellAge = row.insertCell(2);
            const cellGender = row.insertCell(3);
            const cellVaccineStatus = row.insertCell(4);
            const cellDistrict = row.insertCell(5);
            const cellSymptoms = row.insertCell(6);
            
            cellId.innerHTML = patient.id;
            cellName.innerHTML = patient.name;
            cellAge.innerHTML = patient.age;
            cellGender.innerHTML = patient.gender;
            cellVaccineStatus.innerHTML = patient.vaccineStatus;
            cellDistrict.innerHTML = patient.district;
            cellSymptoms.innerHTML = patient.symptomsDetails;
        }
  
    } catch (error) {
        console.error(error);
    }
  }
  











// // Call the function when the page is ready
// $(function () {
//     $(window).load(function () {
//         getAllPatients();
//     });
// });




  // Other functions...

};

$(function () {
  $(window).load(function () {
    App.init();
  });
});


