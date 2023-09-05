import web3 from "./web3";
import Contract from '../build/contracts/TokenLP.json'
const Instance = new web3.eth.Contract(Contract.abi, '0x9d7d245a941D52420983133871fcD9d1E8b649b6');

export default Instance;



