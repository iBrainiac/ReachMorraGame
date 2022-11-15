import {loadStdlib, ask} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib();

const isAlice=await ask.ask(
    "Are you Alice",
    ask.yesno
);

const player=isAlice?'Alice':'Bob';

console.log(`Starting Rock, Paper, Scissors with ${player}`);

let acct=null;
const createAcc=await ask.ask(
    'Would you like to create an account',
    ask.yesno
)

if (createAcc)
{
    acct=await stdlib.newTestAccount(stdlib.parseCurrency(1000))
}
else 
{
    const secret=await ask.ask(
   'What is your accouunt secret',
   (x=>x)
);
acct=await stdlib.newAccountFromSecret(secret);
}

let ctc=null;
if (isAlice){
    ctc=acct.contract(backend);
    ctc.getInfo().then((info)=>{
        console.log(`The contract is deployed as=${JSON.stringify(info)}`)
    })
}
else {
    const info=await ask.ask(
        `Please paste the contract information`,
        JSON.parse
    );
    ctc =acct.contract(backend,info)
}

const fmt=(x)=>stdlib.formatCurrency(x,4);
const getBalance=async()=>fmt(await stdlib.balanceOf(acct))
 
const startingBalance=await getBalance();
console.log(`Your balance is ${startingBalance}  `)

const interact={...stdlib.hasRandom}; 
interact.informTimeout=()=>{
    console.log(`There was a timeout`);
    process.exit(1)
};

if (isAlice){
    const amt=await ask.ask(
        `How much do you wantb to wager?`,
        stdlib.parseCurrency
    );
    interact.wager=amt;
    interact.deadline={ETH:100,ALGO:100,CFX:1000}[stdlib.connector]
}
 else {
    interact.acceptWager=async (amt)=>{
        const accepted=await ask.ask(
            `Do you accept the wager of ${fmt(amt)}?`,
            ask.yesno
        );
        if(!accepted){
            process.exit(0);
        }
    }
}

const HAND=['ROCK',"PAPER",'SCISSORS'];
const HANDS={
    'Rock':0,'R':0,'r':0,
    "Paper":1,"P":1,'p':1,
    "Scissors":2,"S":2,"s":2
}

interact.getHand=async()=>{
    const hand=await ask.ask(`What handwill you play`,
    (x)=>{const hand=HANDS[x]
    if (hand===undefined){
        throw Error(`Not a valid ${hand}`);
    }
    return hand;
    });
    console.log(`You played ${HAND[hand]}`)
    return hand; 
};

const OUTCOME=['Bob wins',"Draw", "Alice wins"];
interact.seeOutcome=async (outcome)=>{
    console.log(`The outcome is ${OUTCOME[outcome]}`)
};

const part=isAlice?ctc.p.Alice:ctc.p.Bob;
await part(interact);

const closingbalance=await getBalance();
console.log(`Your balance is${closingbalance} `)

ask.done();