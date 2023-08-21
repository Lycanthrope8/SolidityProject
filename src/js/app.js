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
      // console.log('Received contract data:', patientmanagement);
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
          const signUpForm = document.getElementById('patientForm');
          signUpForm.style.display = 'none'; // Hide the form
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
      })
      .catch(function (error) {
        console.error(error);
      });
  },

  // showInfo: async function() {
  //   const ini = await App.init()
  //   .then(function(ini){
  //     console.log("Before Deploying...")
  //     App.contracts.PatientManagement.deployed()
  //     console.log("After Deploying...")

  //   })
  // },  
  
  
  


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

        const vaccine = [
            "NotVaccinated",
            "OneDose",
            "TwoDose"
        ];

        const table = document.getElementById('patientTable');
        const tbody = table.getElementsByTagName('tbody')[0];
        tbody.innerHTML = ''; // Clear the table body before populating

        for (let i = 0; i < patientCount; i++) {
              //All the patients addresses are in patientAddresses Array
            const patientAddress = await instance.patientAddresses(i);
              //Collecting the data from patients struct through patientAdress
            const patientValues = await instance.patients(patientAddress);
              //storing them into the variables to show in the html table 
            const id = patientValues[0].toNumber();
            const address = patientValues[1];
            const name = patientValues[2];
            const age = patientValues[3].toNumber();
            const gender = patientValues[4];
            const vaccineStatus = vaccine[patientValues[5].toNumber()];
            const district = patientValues[6];
            const symptomsDetails = patientValues[7];
            const isDead = patientValues[8];
            const hasInfo = patientValues[9];
              //Cells
              const row = tbody.insertRow();
              const cellId = row.insertCell(0);
              const cellAddress = row.insertCell(1);
              const cellName = row.insertCell(2);
              const cellAge = row.insertCell(3);
              const cellGender = row.insertCell(4);
              const cellVaccineStatus = row.insertCell(5);
              const cellDistrict = row.insertCell(6);
              const cellSymptoms = row.insertCell(7);
              const cellIsDead = row.insertCell(8);
              const cellHasInfo = row.insertCell(9);
              const cellUpdate = row.insertCell(10); // cell for update button
              const cellDelete = row.insertCell(11); // cell for delete button

              // Creating update button
            const updateButton = document.createElement('button');
            updateButton.innerHTML = 'Update';
            updateButton.addEventListener('click', () => this.UpdatePatient(id,address,name,age,gender,patientValues[5].toNumber(),district,symptomsDetails,isDead,hasInfo));

            // Creating delete button
            const deleteButton = document.createElement('button');
            deleteButton.innerHTML = 'Delete';
            deleteButton.addEventListener('click', () => this.DeletePatient(address));
            
            // Append buttons to respective cells
            cellUpdate.appendChild(updateButton);
            cellDelete.appendChild(deleteButton);

              //Writing through HTMl
            cellId.innerHTML = id;
            cellAddress.innerHTML = address;
            cellName.innerHTML = name;
            cellAge.innerHTML = age;
            cellGender.innerHTML = gender;
            cellVaccineStatus.innerHTML = vaccineStatus;
            cellDistrict.innerHTML = district;
            cellSymptoms.innerHTML = symptomsDetails;
            cellIsDead.innerHTML = isDead ? 'Yes' : 'No';
            cellHasInfo.innerHTML = hasInfo ? 'Yes' : 'No';
        }
    } catch (error) {
        console.error(error);
    }
},

UpdatePatient: async function(id,patientAddress,name,age,gender,vaccineStatus,district,symptomsDetails,isDead,hasInfo) {
  const updateForm = document.getElementById('updateForm');
  updateForm.style.display = 'block'; // Show the update form
  patientAddressForHeader.innerHTML = `${patientAddress}` ; //Displaying public address of the updating patient

  console.log("Filling the input fields with existing values");
  console.log(vaccineStatus)
  document.getElementById('updateName').value = name;
  document.getElementById('updateAge').value = age;
  document.getElementById('updateGender').value = gender;
  document.getElementById('updateVaccineStatus').value = vaccineStatus;
  document.getElementById('updateDistrict').value = district;
  document.getElementById('updateSymptoms').value = symptomsDetails;
  document.getElementById('updateDead').checked = isDead;
  document.getElementById('updateHasInfo').checked = hasInfo;
  console.log("Information Filled")


  // Handle form submission
  const updatePatientForm = document.getElementById('updatePatientForm');
  updatePatientForm.onsubmit = async function(event) {
      event.preventDefault(); 
      const updatedName = document.getElementById('updateName').value;
      const updatedAge = document.getElementById('updateAge').value;
      const updatedGender = document.getElementById('updateGender').value;
      const updatedVaccineStatus = document.getElementById('updateVaccineStatus').value;
      const updatedDistrict = document.getElementById('updateDistrict').value;
      const updatedSymptoms = document.getElementById('updateSymptoms').value;
      const updatedDead = document.getElementById('updateDead').checked;
      const updatedHasInfo = document.getElementById('updateHasInfo').checked;
      let deathDate = 0;
      if (updatedDead==true){
          // Date object
            const date = new Date();
            let currentDay= String(date.getDate()).padStart(2, '0');
            let currentMonth = String(date.getMonth()+1).padStart(2,"0");
            let currentYear = date.getFullYear();
            let currentDate = `${currentDay}${currentMonth}${currentYear}`; // displaying the date as DDMMYYYY 
            deathDate = parseInt(currentDate);
      };

      console.log('Updating patient', patientAddress);
      console.log('DeathDate:' ,deathDate)
      App.contracts.PatientManagement.deployed()
        .then(function (instance) {
            console.log('Updating Patient...');
            return instance.updatePatient(patientAddress,updatedName,updatedAge,
                              updatedGender,updatedVaccineStatus,updatedDistrict,
                              updatedSymptoms,updatedDead,updatedHasInfo,deathDate,{
                from: App.account,
                gas: '500000', // Adjust gas limit as needed
            });
        })
        .then(function (result) {
            console.log('Transaction Hash:', result.tx);
            alert('Patient updated successfully');
        })
        .catch(function (error) {
            console.error(error);
            alert('Error updating patient information');
        });
    
      // Hide the update form and refresh patient data
      updateForm.style.display = 'none';
      App.AllPatients();
  };
},


DeletePatient: async function(patientAddress){
    console.log('Delete clicked for patient:', patientAddress);
    App.contracts.PatientManagement.deployed()
      .then(function (instance) {
          console.log('Deleting Patient...');
          return instance.deletePatient(patientAddress,{
              from: App.account,
              gas: '500000', // Adjust gas limit as needed
          });
      })
      .then(function (result) {
          console.log('Transaction Hash:', result.tx);
          alert('Patient deleted successfully');
      })
      .catch(function (error) {
          console.error(error);
          alert('Error deleting patient information');
      });
},

showAverageDeathRate: function () {
  App.contracts.PatientManagement.deployed()
    .then(function (instance) {
      return instance.averageDeathRate();
    })
    .then(function (result) {
      console.log("Average Death Rate:", result);
      // You can update the UI here with the result
    })
    .catch(function (error) {
      console.error(error);
    });
},

showHighestDistrictPatients: function () {
  App.contracts.PatientManagement.deployed()
    .then(function (instance) {
      return instance.getDistrictWithMostPatients();
    })
    .then(function (result) {
      console.log("Highest District Patients:", result);
      // You can update the UI here with the result
    })
    .catch(function (error) {
      console.error(error);
    });
},


showAgePercentages: function () {
  App.contracts.PatientManagement.deployed()
    .then(function (instance) {
      return instance.agePercentages();
    })
    .then(function (result) {
      console.log("Age Percentages:", result);
      // You can update the UI here with the result
    })
    .catch(function (error) {
      console.error(error);
    });
},















};

$(function () {
  $(window).load(function () {
    App.init();
  });

});


