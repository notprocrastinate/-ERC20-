import web3 from "./web3";
import Contract from '../build/contracts/Curve.json'
const Instance = new web3.eth.Contract(Contract.abi, '0x3b04E238Ed617deF1f02995A0597Aa03947b6598');

export default Instance;



