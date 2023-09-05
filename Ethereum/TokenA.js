import web3 from "./web3";
import Contract from '../build/contracts/TokenA.json'
const Instance = new web3.eth.Contract(Contract.abi, '0x46e9c6e9732FD819D37Fee83355374Fe1fdDB10B');

export default Instance;



