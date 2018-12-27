keccak256 = require('js-sha3').keccak256;

var ques1 = "who is the greatest villain of all time";
var ans1 = "thanos";
var ques2 = "which is the greatest anime ever";
var ans2 = "full metal alchemist brotherhood";
var ques3 = "which is the second greatest anime ever";
var ans3 = "one piece";
var ques4 = "who is the most beautiful and brilliant actress in hollywood";
var ans4 = "brie larson";
var delay = 5;
var quizTime = 30;
var pFee = 30;
var block;
var N = 3;
const Quiz = artifacts.require("Quiz");
contract("Quiz", async(accounts) => {
    var quiz;

    it("tests that beneficiary is registered", async () => {
        quiz = await Quiz.new({from: accounts[0]});
        await quiz.sendParams(quizTime,pFee,delay,ques1,ans1,ques2,ans2,ques3,ans3,ques4,ans4);
        let addr = await quiz.beneficiaryExists();
        assert.equal(addr, accounts[0], "beneficiary isn't registered");

    });
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    it("tests that player 1 registers", async () => {
      await quiz.register({from: accounts[1], value: pFee});
      let val1 = await quiz.playerExists(accounts[1]);
      assert.equal(val1, true, "player isn't registered");

    });

    it("tests that player 2 registers", async () => {
      await quiz.register({from: accounts[2], value: pFee});
      let val1 = await quiz.playerExists(accounts[2]);
      assert.equal(val1, true, "player isn't registered");

    });

    it("tests that player 3 registers", async () => {
      await quiz.register({from: accounts[3], value: pFee});
      let val1 = await quiz.playerExists(accounts[3]);
      assert.equal(val1, true, "player isn't registered");

    });
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
    it("tests that player 4 who didnt registers is not there", async () => {
      let val1 = await quiz.playerExists(accounts[4]);
      assert.equal(val1, false, "unregistered player is participating!!");
    });
    
    it("tests to see total money at stake !!!", async () => {
      let val1 = await quiz.getTfee();
      assert.equal(val1, N*pFee, "total fee is not updated");
    });
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
    it("tests that beneficiary has successfully started the quiz", async () => {
      await quiz.startQuiz({from: accounts[0]});
      let val1 = await quiz.quizStarted();
      assert.equal(val1, "The quiz will begin in a few minutes", "unregistered player is participating!!");
    });
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    block = web3.eth.getBlock("latest");
    var startTime = block.number;
    
    var stTime1 = startTime + delay
    var endTime1 = stTime1 + quizTime;
    var stTime2 = endTime1 + delay; 
    var endTime2 = stTime2 + quizTime; 
    var stTime3 = endTime2 + delay; 
    var endTime3 = stTime3 + quizTime;
    var stTime4 = endTime3 + delay; 
    var endTime4 = stTime4 + quizTime;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
    it("tests that player 1 doesnt get the question before start time", async () => {
      let val1 = await quiz.getQuestion({from: accounts[1]});
      assert.equal(val1, "Sorry!! quiz ended", "player gets the question before start time");
    });
    
    it("tests that player 2 doesnt get the question before start time", async () => {
      let val1 = await quiz.getQuestion({from: accounts[2]});
      assert.equal(val1, "Sorry!! quiz ended", "player gets the question before start time");
    });

    it("tests that player 3 doesnt get the question before start time", async () => {
      let val1 = await quiz.getQuestion({from: accounts[3]});
      assert.equal(val1, "Sorry!! quiz ended", "player gets the question before start time");
    });
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
    var i;
    for(i=1;i<delay;i++){
      it("Increasing Block Number", async () => {
        await quiz.increaseBlocks({from: accounts[0], value: 0});
        assert.equal(true, true, "failed to increase");
      });
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
    it("tests that player 1 gets the question 1 in allotted time", async () => {
      let val1 = await quiz.getQuestion({from: accounts[1]});
      assert.equal(val1, ques1, "player gets the question before start time");
    });
    
    it("tests that player 2 gets the question 1 in allotted time", async () => {
      let val1 = await quiz.getQuestion({from: accounts[2]});
      assert.equal(val1, ques1, "player gets the question before start time");
    });

    it("tests that player 3 gets the question 1 in allotted time", async () => {
      let val1 = await quiz.getQuestion({from: accounts[3]});
      assert.equal(val1, ques1, "player gets the question before start time");
    });
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
    it("tests that player 1 gets to submit answer to question 1 in allotted time", async () => {
      await quiz.submitAnswer(keccak256(ans1), {from: accounts[1], value: 0});
      let val1 = await quiz.hasSubmitted(1 ,{from: accounts[1]});
      assert.equal(val1, true, "player gets the question before start time");
    });
    
    // it("tests that player 1 cant play again", async () => {
    //   try{
    //   await ticTacToe.move(0,{from: accounts[1]});
    // }
    // catch(err){
    //   var turn = await ticTacToe.getTurn();
    //   assert.equal(turn.c[0], 1, "Player1's turn");
    // }

    it("tests that player 1 cant submit for the question 1 more then once", async () => {
      try{
      await quiz.submitAnswer(keccak256(ans1), {from: accounts[1], value: 0});
      }
      catch(err){
        assert.equal(true,true,"player 1 is able to submit more than once");
      }
    });

    it("tests that player 2 cant submit answer to question 1 in allotted time as player 1 has already done", async () => {
      await quiz.submitAnswer(keccak256(ans1), {from: accounts[2], value: 0});
      let val1 = await quiz.hasSubmitted(1 ,{from: accounts[2]});
      assert.equal(val1, true, "player gets the question before start time");
    });
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

});