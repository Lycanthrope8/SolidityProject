// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract Election {

   event votedEvent( uint indexed _candidateId );
   // model a candidate
   struct Candidate {
       uint id;
       string name;
       uint voteCount;
   }
   // Store accounts that have voted
   mapping( address => bool ) public voters;


   // Read/write candidates
   mapping( uint => Candidate ) public candidates;


   // store candidates count
   uint public candidatesCount;


   // Constructor
   constructor() {
       addCandidate( "Candidate 1" );
       addCandidate( "Candidate 2" );
   }


   // adding candidates
   function addCandidate( string memory _name ) private {
       candidatesCount++;
       candidates[ candidatesCount ] = Candidate( candidatesCount, _name, 0 );
   }


   // cast vote
   function vote( uint _candidateId ) public {
       // require that the current voter haven't voted before
       require( !voters[ msg.sender ]);


       // candidate should be valid
       require( _candidateId > 0 && _candidateId <= candidatesCount );


       // record voters vote
       voters[ msg.sender ] = true;


       // update candidates vote count
       candidates[ _candidateId ].voteCount++;
       
       /// emit the event
	emit votedEvent( _candidateId );
              }
       
}
