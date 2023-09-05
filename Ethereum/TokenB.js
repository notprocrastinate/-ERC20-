import web3 from "./web3";
import Contract from '../build/contracts/TokenB.json'
const Instance = new web3.eth.Contract(Contract.abi, '0x86e6E3fEf2d50CADb5F4280e979eff74A7518864');

export default Instance;
