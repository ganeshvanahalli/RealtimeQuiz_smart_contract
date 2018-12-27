pragma solidity ^0.4.22;

/// @title Quiz

contract Quiz {
    
    // This Quiz asks integer type questions
    // There are 4 questions and answer to each question is an integer

    
    address public beneficiary;
    uint public quizTime;
    address[] public participants;
    uint pFee; // Participation Fee 
    uint tFee; // Total Fee collected by the contract
    uint delay; // Time to start first question

    // This declares a new type for
    // Participants of the Quiz
    struct participantStruct {
        bool isRegistered;
        bool[4] asked; // if true, that person already asked
        bool[4] submit; // if true, that person not already answered
        bytes32[4] answer;// Holds the answer to the question as hash(keccak256 output of the answer
        uint[4] answerTime;
    }
    
    struct question{    
        string ques;
        bytes32 ans;
        bool isDisplayed;
    }
        
    question[] ques;
    mapping(address => participantStruct) public participantStructs;    
    
    // Create a simple Quiz with '_quizTime' as the
    // duration of quiz
    constructor() public {
        beneficiary = msg.sender;
    }
    
    function sendParams(uint _quizTime,uint _pFee,uint _d,string _ques1,string _ans1,string _ques2,string _ans2,string _ques3,string _ans3,string _ques4,string _ans4) public returns (bool) {
        pFee = _pFee;
        quizTime = _quizTime;
        delay = _d;
        ques.push(question({
            ques: _ques1,
            ans: keccak256(keccak256(_ans1)),
            isDisplayed: false
        }));
        
        ques.push(question({
            ques: _ques2,
            ans: keccak256(keccak256(_ans2)),
            isDisplayed: false
        }));
        
        ques.push(question({
            ques: _ques3,
            ans: keccak256(keccak256(_ans3)),
            isDisplayed: false
        }));
        
        ques.push(question({
            ques: _ques4,
            ans: keccak256(keccak256(_ans4)),
            isDisplayed: false
        }));
        return true;
    }
    
    function beneficiaryExists() public view returns(address){
        return beneficiary;
    }
    /// Register to play the quiz 
    /// Participation fee is pFee
    function register() public payable{
        address player = msg.sender;
        
        require(
            !participantStructs[player].isRegistered,
            "not already registerd"
        );
        
        require(
            msg.value >= pFee,
            "pFee is participation fee"
        );
        
    
        participants.push(player);
        participantStructs[player].isRegistered = true;
        participantStructs[player].asked[0] = false;
        participantStructs[player].asked[1] = false;
        participantStructs[player].asked[2] = false;
        participantStructs[player].asked[3] = false;
        participantStructs[player].submit[0] = true;
        participantStructs[player].submit[1] = true;
        participantStructs[player].submit[2] = true;
        participantStructs[player].submit[3] = true;
        tFee += msg.value;

        
    }
    function playerExists(address player) public view returns(bool){
        return participantStructs[player].isRegistered;
    }

    function getTfee() public view returns(uint){
        return tFee;
    }

    uint prize = 3*(tFee/16);
    
    uint[4]  startTime;
    uint[4]  endTime;
    
    function startQuiz() public{
        
        require(
            msg.sender == beneficiary
        );
        
        startTime[0] = block.number + delay;
        endTime[0] = startTime[0] + quizTime;
        
        for(uint i=1;i<4;i++){
            startTime[i] = endTime[i-1] + delay; 
            endTime[i] = startTime[i] + quizTime; 
        }
    }
    
    function quizStarted() public view returns(string) {
        if(block.number + delay >= startTime[0])
            return "The quiz will begin in a few minutes";
        else
            return "not started yet";
    }

    function increaseBlocks() public payable returns(bool){
        return true;
    }
    // quiz question
    function getQuestion() public view returns (string){
        
        require(
            participantStructs[msg.sender].isRegistered
        );
        
        
        
       if (block.number >= startTime[0] && block.number <= endTime[0]){
           require(
                !participantStructs[msg.sender].asked[0]
           );
           participantStructs[msg.sender].asked[0] = true;
           return ques[0].ques;
       }
       
       else if (block.number >= startTime[1] && block.number <= endTime[1]){
           require(
                !participantStructs[msg.sender].asked[1]
           );
           participantStructs[msg.sender].asked[1] = true;
           return ques[1].ques;
       }
       
       else if (block.number >= startTime[2] && block.number <= endTime[2]){
           require(
                !participantStructs[msg.sender].asked[2]
           );
           participantStructs[msg.sender].asked[2] = true;
           return ques[2].ques;
       }
       
       else if (block.number >= startTime[3] && block.number <= endTime[3]){
           require(
                !participantStructs[msg.sender].asked[3]
           );
           participantStructs[msg.sender].asked[3] = true;
           return ques[3].ques;
       }
       
       else return "Sorry!! quiz ended";
        
    }
    
    event Payment(
        address _from,
        address _to,
        uint amount
    );

    function hasSubmitted(uint ques) public view returns(bool){
        return !participantStructs[msg.sender].submit[ques-1];
    }
    // u can submit the answer only ones so the stakes are block.number really really high play safe
    function submitAnswer(bytes32 ansHash) public payable returns (string){
        
        require(
            participantStructs[msg.sender].isRegistered
        );
        
       if (block.number >= startTime[0] && block.number <= endTime[0]){
           require(
                participantStructs[msg.sender].submit[0]
           );
           participantStructs[msg.sender].submit[0] = false;
           if(keccak256(abi.encodePacked(ansHash)) == ques[0].ans){
               msg.sender.transfer(prize);
               emit Payment(beneficiary, msg.sender, prize);
               endTime[0] = startTime[0];
               return "Winner Winner Ether Dinner";
           }
       }
       
       else if (block.number >= startTime[1] && block.number <= endTime[1]){
           require(
                participantStructs[msg.sender].submit[1]
           );
           participantStructs[msg.sender].submit[1] = false;
           if(keccak256(abi.encodePacked(ansHash)) == ques[1].ans){
               msg.sender.transfer(prize);
               emit Payment(beneficiary, msg.sender, prize);
               endTime[1] = startTime[1];
               return "Winner Winner Ether Dinner";
           }
       }
       
       else if (block.number >= startTime[2] && block.number <= endTime[2]){
           require(
                participantStructs[msg.sender].submit[2]
           );
           participantStructs[msg.sender].submit[2] = false;
           if(keccak256(abi.encodePacked(ansHash)) == ques[2].ans){
               msg.sender.transfer(prize);
               emit Payment(beneficiary, msg.sender, prize);
               endTime[2] = startTime[2];
               return "Winner Winner Ether Dinner";
           }
       }
       
       else if (block.number >= startTime[3] && block.number <= endTime[3]){
           require(
                participantStructs[msg.sender].submit[3]
           );
           participantStructs[msg.sender].submit[3] = false;
           if(keccak256(abi.encodePacked(ansHash)) == ques[3].ans){
               msg.sender.transfer(prize);
               emit Payment(beneficiary, msg.sender, prize);
               endTime[3] = startTime[3];
               return "Winner Winner Ether Dinner";   
           }
       }
       else{
           return "Thankyou your answer will be looked into";
       }    
    }
}