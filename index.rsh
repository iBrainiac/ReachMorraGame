'reach 0.1';
 
const Player = {
  ...hasRandom,
  getNumber: Fun([], UInt),
  getGuessTotal: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
  informTimeout: Fun([], Null),
};

const winner = (numberAlice,numberBob,guessAlice,guessBob) => {
  const totalNumber=numberAlice+numberBob;
  if(guessAlice==guessBob)
  {
  return 1;
  }
  else
  {
    if(totalNumber==guessAlice)
    {   
      return 0;
    }else{
      if(totalNumber==guessBob)
      {
     
        return 2;
      }
      else
      {
       
        return 1;
      }
    }
  }
  
}

export const main = Reach.App(() => {

  const Alice = Participant('Alice', {
    ...Player,      // Specify Alice's interact interface here
    wager:UInt,
    deadline:UInt,
  })

  const Bob = Participant('Bob', {
    ...Player,              // Specify Bob's interact interface here
     acceptWager:Fun([UInt],Null)
  });
  init();

 const informTimeout=()=> {
  each([Alice,Bob],()=>{
  interact.informTimeout();
  }) 
  }
   
  Alice.only (()=>{
   const amount = declassify(interact.wager);
    const deadline = declassify(interact.deadline);
    const _numberAlice = interact.getNumber();
    const _guessAlice = interact.getGuessTotal();
    const [_commitAlice, _saltAlice] = makeCommitment(interact, _numberAlice);
    const [_commitAlice2,_saltAlice2] = makeCommitment (interact, _guessAlice);
    const commitAlice = declassify(_commitAlice);
    const commitAlice2=declassify(_commitAlice2);
    });

  //Alice.publish(handAlice,amount)

    Alice.publish(commitAlice,commitAlice2,amount,deadline )
    .pay(amount);
  commit();

 // unknowable(Bob,Alice(_handAlice,_saltAlice)); //check to make sure Bob doesn.t know about Alice's value
  unknowable(Bob, Alice(_numberAlice, _saltAlice ,_guessAlice,_saltAlice2));

    Bob.only(() => {
      interact.acceptWager(amount);
      const numberBob = declassify(interact.getNumber());
      const guessBob = declassify(interact.getGuessTotal());
  });

   Bob.publish(numberBob,guessBob)
   .pay(amount)
   .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));
   commit();


   Alice.only(() => {
    const saltAlice = declassify(_saltAlice);
    const saltAlice2 = declassify(_saltAlice2);
    const numberAlice = declassify(_numberAlice);
    const guessAlice = declassify(_guessAlice);
  });

  Alice.publish(saltAlice,saltAlice2, numberAlice, guessAlice)
    .timeout(relativeTime(deadline), () => closeTo(Bob, informTimeout));
 
    checkCommitment(commitAlice, saltAlice, numberAlice);
   checkCommitment(commitAlice2, saltAlice2, guessAlice);
  //  const outcome = (handAlice + (4 - handBob)) % 3;
 
  const outcome = winner(numberAlice, numberBob,guessAlice,guessBob);

  const[forAlice,forBob]=
    outcome==2?[(2*amount),0]:
     outcome==0?[0,(2*amount)]:
    [amount,amount];

  transfer(forAlice).to(Alice);
  transfer(forBob).to(Bob);
  commit();

  each([Alice, Bob], () => {
    interact.seeOutcome(outcome);
  });

});



  // write your program here
  //exit();