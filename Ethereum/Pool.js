import web3 from "./web3";
import Contract from '../build/contracts/Pool.json'
const Instance = new web3.eth.Contract(Contract.abi, '0x856359AC2029005C708Ad12bF522ea70E8eF714E');

export default Instance;



